#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
MANIFEST_PATH="${WEZTERM_TYPES_MANIFEST:-$ROOT_DIR/metadata/plugins.json}"
README_PATH="${WEZTERM_TYPES_README:-$ROOT_DIR/README.md}"
PAGE_TEMPLATE_PATH="${WEZTERM_TYPES_PAGE_TEMPLATE:-$ROOT_DIR/scripts/templates/plugin-maintenance-page.html.tmpl}"
REDIRECT_TEMPLATE_PATH="${WEZTERM_TYPES_REDIRECT_TEMPLATE:-$ROOT_DIR/scripts/templates/plugin-maintenance-redirect.html.tmpl}"
BUILD_DIR="${PLUGIN_MAINTENANCE_BUILD_DIR:-${PLUGIN_DRIFT_BUILD_DIR:-$ROOT_DIR/.tmp/plugin-maintenance}}"
SYNC_PATH="${PLUGIN_MAINTENANCE_SYNC_PATH:-${PLUGIN_DRIFT_SYNC_PATH:-$BUILD_DIR/report.json}}"
PAGES_DIR="${PLUGIN_MAINTENANCE_PAGES_DIR:-${PLUGIN_DRIFT_PAGES_DIR:-$BUILD_DIR/pages}}"
START_MARKER="<!-- plugin-table:start -->"
END_MARKER="<!-- plugin-table:end -->"

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

main_usage() {
  printf 'Usage: %s {table|validate|sync|review|render-pages} ...\n' "$0"
}

table_usage() {
  printf 'Usage: %s table [--check|--stdout]\n' "$0"
}

repo_slug() {
  local remote

  if [[ -n "${WEZTERM_TYPES_PAGES_REPO:-}" ]]; then
    printf '%s\n' "${WEZTERM_TYPES_PAGES_REPO}"
    return
  fi

  if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
    printf '%s\n' "${GITHUB_REPOSITORY}"
    return
  fi

  remote=$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)
  [[ -n "$remote" ]] || die "Unable to determine repository slug"

  remote=${remote#https://github.com/}
  remote=${remote#git@github.com:}
  remote=${remote%.git}
  printf '%s\n' "$remote"
}

pages_base_url() {
  local slug owner repo

  if [[ -n "${WEZTERM_TYPES_PAGES_BASE_URL:-}" ]]; then
    printf '%s\n' "${WEZTERM_TYPES_PAGES_BASE_URL%/}"
    return
  fi

  slug=$(repo_slug)
  owner=${slug%/*}
  repo=${slug#*/}
  printf 'https://%s.github.io/%s\n' "$owner" "$repo"
}

badge_url() {
  local slug=$1
  local endpoint encoded

  endpoint="$(pages_base_url)/plugin-maintenance/badges/${slug}.json"
  encoded=$(jq -rn --arg value "$endpoint" '$value | @uri')
  printf 'https://img.shields.io/endpoint?url=%s\n' "$encoded"
}

report_url() {
  local slug=$1

  printf '%s/plugin-maintenance/#%s\n' "$(pages_base_url)" "$slug"
}

repo_branch() {
  if [[ -n "${WEZTERM_TYPES_REPO_BRANCH:-}" ]]; then
    printf '%s\n' "${WEZTERM_TYPES_REPO_BRANCH}"
    return
  fi

  printf 'main\n'
}

base64_decode() {
  if base64 --decode >/dev/null 2>&1 <<<""; then
    base64 --decode
    return
  fi

  base64 -D
}

json_list_from_find() {
  local path=$1
  shift

  find "$path" "$@" -print |
    sed "s#^$ROOT_DIR/##" |
    LC_ALL=C sort |
    jq -Rsc 'split("\n") | map(select(length > 0))'
}

compare_lists() {
  local label=$1
  local expected=$2
  local actual=$3

  if [[ "$expected" == "$actual" ]]; then
    return
  fi

  printf '%s manifest mismatch\n' "$label" >&2
  diff -u \
    <(jq -r '.[]' <<<"$expected") \
    <(jq -r '.[]' <<<"$actual") || true
  exit 1
}

validate_port() {
  local port=$1

  [[ "$port" =~ ^[0-9]+$ ]] || die "Invalid port: $port"
  ((port >= 1 && port <= 65535)) || die "Invalid port: $port"
}

require_sync_report() {
  [[ -f "$SYNC_PATH" ]] || die "Missing sync report: $SYNC_PATH. Run '$0 sync' first."
}

tracked_ref_text() {
  local kind=$1
  local value=$2

  if [[ "$kind" == "commit" ]]; then
    printf '%s:%s\n' "$kind" "${value:0:7}"
    return
  fi

  printf '%s:%s\n' "$kind" "$value"
}

dash_line() {
  local width=$1

  printf '%*s' "$width" '' | tr ' ' '-'
}

render_table_block() {
  local -a plugin_cells=() docs_cells=() help_cells=() status_cells=()
  local plugin_width docs_width help_width status_width

  plugin_width=6
  docs_width=13
  help_width=11
  status_width=6

  while IFS=$'\t' read -r slug readme_name repo docs_path vimdoc_path tracked_kind tracked_value; do
    local plugin_cell docs_cell help_cell status_cell tracked_text
    plugin_cell="[$readme_name](https://github.com/$repo)"
    docs_cell="[$docs_path](./$docs_path)"
    help_cell="[:h $(basename "$vimdoc_path")](./$vimdoc_path)"
    tracked_text=$(tracked_ref_text "$tracked_kind" "$tracked_value")
    status_cell="[![status]($(badge_url "$slug"))]($(report_url "$slug"))<br><code>${tracked_text}</code>"

    plugin_cells+=("$plugin_cell")
    docs_cells+=("$docs_cell")
    help_cells+=("$help_cell")
    status_cells+=("$status_cell")

    (( ${#plugin_cell} > plugin_width )) && plugin_width=${#plugin_cell}
    (( ${#docs_cell} > docs_width )) && docs_width=${#docs_cell}
    (( ${#help_cell} > help_width )) && help_width=${#help_cell}
    (( ${#status_cell} > status_width )) && status_width=${#status_cell}
  done < <(
    jq -r '
      sort_by(.readme_name | ascii_downcase)
      | .[]
      | [
          .slug,
          .readme_name,
          .repo,
          .docs_path,
          .vimdoc_path,
          .tracked_ref.kind,
          .tracked_ref.value
        ]
      | @tsv
    ' "$MANIFEST_PATH"
  )

  printf '| %-*s | %-*s | %-*s | %-*s |\n' \
    "$plugin_width" "Plugin" \
    "$docs_width" "Documentation" \
    "$help_width" "Neovim Help" \
    "$status_width" "Status"
  printf '|%s|%s|%s|%s|\n' \
    "$(dash_line $((plugin_width + 2)))" \
    "$(dash_line $((docs_width + 2)))" \
    "$(dash_line $((help_width + 2)))" \
    "$(dash_line $((status_width + 2)))"

  for i in "${!plugin_cells[@]}"; do
    printf '| %-*s | %-*s | %-*s | %-*s |\n' \
      "$plugin_width" "${plugin_cells[$i]}" \
      "$docs_width" "${docs_cells[$i]}" \
      "$help_width" "${help_cells[$i]}" \
      "$status_width" "${status_cells[$i]}"
  done
}

rewrite_readme_with_table() {
  local rendered tmp
  rendered=$(render_table_block)
  tmp=$(mktemp)

  awk -v start="$START_MARKER" -v end="$END_MARKER" -v block="$rendered" '
    BEGIN {
      in_block = 0
      saw_start = 0
      saw_end = 0
    }
    $0 == start {
      print
      print block
      in_block = 1
      saw_start = 1
      next
    }
    $0 == end {
      in_block = 0
      saw_end = 1
      print
      next
    }
    !in_block {
      print
    }
    END {
      if (!saw_start || !saw_end) {
        exit 3
      }
    }
  ' "$README_PATH" >"$tmp" || {
    rm -f "$tmp"
    die "README markers not found in $README_PATH"
  }

  printf '%s\n' "$tmp"
}

check_readme_table() {
  local generated
  generated=$(rewrite_readme_with_table)

  if cmp -s "$generated" "$README_PATH"; then
    rm -f "$generated"
    return
  fi

  diff -u "$README_PATH" "$generated" || true
  rm -f "$generated"
  die "README plugin table is out of date"
}

write_readme_table() {
  local generated
  generated=$(rewrite_readme_with_table)
  mv "$generated" "$README_PATH"
}

table() {
  local mode=${1:-write}

  if [[ $# -gt 1 ]]; then
    die "$(table_usage)"
  fi

  require_cmd jq
  [[ -f "$MANIFEST_PATH" ]] || die "Missing manifest: $MANIFEST_PATH"
  validate_manifest_schema

  case "$mode" in
  write)
    [[ -f "$README_PATH" ]] || die "Missing README: $README_PATH"
    write_readme_table
    ;;
  --check)
    [[ -f "$README_PATH" ]] || die "Missing README: $README_PATH"
    check_readme_table
    ;;
  --stdout)
    render_table_block
    ;;
  *)
    die "$(table_usage)"
    ;;
  esac
}

parse_serve_args() {
  local default_port=9999

  PLUGIN_MAINTENANCE_SHOULD_SERVE=0
  PLUGIN_MAINTENANCE_SERVE_PORT=$default_port

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --serve)
      PLUGIN_MAINTENANCE_SHOULD_SERVE=1
      if [[ $# -gt 1 && "$2" != --* ]]; then
        validate_port "$2"
        PLUGIN_MAINTENANCE_SERVE_PORT=$2
        shift
      fi
      ;;
    --serve=*)
      PLUGIN_MAINTENANCE_SHOULD_SERVE=1
      validate_port "${1#--serve=}"
      PLUGIN_MAINTENANCE_SERVE_PORT="${1#--serve=}"
      ;;
    *)
      die "$(main_usage)"
      ;;
    esac
    shift
  done
}

print_report_section() {
  local label=$1
  local header=$2
  local jq_filter=$3
  local rows

  rows=$(jq -r "$jq_filter" "$SYNC_PATH")

  printf '%s\n' "$label"
  if [[ -n "$rows" ]]; then
    rows=$(printf '%s\n%s\n' "$header" "$rows")
    if command -v column >/dev/null 2>&1; then
      printf '%s\n' "$rows" | column -t -s $'\t'
    else
      printf '%s\n' "$rows"
    fi
  else
    printf 'none\n'
  fi
  printf '\n'
}

serve_pages() {
  local port=$1
  local python_cmd=""

  if command -v python3 >/dev/null 2>&1; then
    python_cmd="python3"
  elif command -v python >/dev/null 2>&1; then
    python_cmd="python"
  fi

  if [[ -z "$python_cmd" ]]; then
    printf 'Rendered plugin maintenance pages at %s, but could not start a local server because neither python3 nor python is available.\n' \
      "$PAGES_DIR/plugin-maintenance"
    return 0
  fi

  printf 'Serving plugin maintenance report at http://localhost:%s/plugin-maintenance/\n' "$port"
  "$python_cmd" -m http.server -d "$PAGES_DIR" "$port"
}

normalize_error_text() {
  tr '\n' ' ' <"$1" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
}

emit_sync_error_record() {
  local manifest_json=$1
  local checked_at=$2
  local repo_url=$3
  local error_text=$4

  jq -nc \
    --argjson manifest "$manifest_json" \
    --arg checked_at "$checked_at" \
    --arg repo_url "$repo_url" \
    --arg status "error" \
    --arg error "$error_text" \
    '$manifest + {
      checked_at: $checked_at,
      repo_url: $repo_url,
      status: $status,
      error: $error
    }'
}

emit_sync_status_record() {
  local manifest_json=$1
  local checked_at=$2
  local repo_url=$3
  local status=$4
  local upstream_kind=$5
  local upstream_value=$6

  jq -nc \
    --argjson manifest "$manifest_json" \
    --arg checked_at "$checked_at" \
    --arg repo_url "$repo_url" \
    --arg status "$status" \
    --arg upstream_kind "$upstream_kind" \
    --arg upstream_value "$upstream_value" \
    '$manifest + {
      checked_at: $checked_at,
      repo_url: $repo_url,
      status: $status,
      upstream_ref: {
        kind: $upstream_kind,
        value: $upstream_value
      }
    }'
}

validate_manifest_schema() {
  jq -e '
    type == "array"
    and length > 0
    and ([.[].slug] | length == (unique | length))
    and ([.[].repo] | length == (unique | length))
    and all(
      .[];
      (.slug | type == "string" and length > 0)
      and (.repo | type == "string" and test("^[^/]+/[^/]+$"))
      and (.docs_path | type == "string" and startswith("docs/"))
      and (.lua_path | type == "string" and startswith("lua/"))
      and (.vimdoc_path | type == "string" and startswith("doc/"))
      and (.display_name | type == "string" and length > 0)
      and (.readme_name | type == "string" and length > 0)
      and (.tracked_ref | type == "object")
      and (
        .tracked_ref.kind == "release"
        or .tracked_ref.kind == "tag"
        or .tracked_ref.kind == "commit"
      )
      and (.tracked_ref.value | type == "string" and length > 0)
    )
  ' "$MANIFEST_PATH" >/dev/null || die "Manifest validation failed"
}

validate_inventory() {
  local manifest_docs manifest_lua manifest_vimdoc actual_docs actual_lua actual_vimdoc

  manifest_docs=$(jq -c '[.[].docs_path] | sort' "$MANIFEST_PATH")
  manifest_lua=$(jq -c '[.[].lua_path] | sort' "$MANIFEST_PATH")
  manifest_vimdoc=$(jq -c '[.[].vimdoc_path] | sort' "$MANIFEST_PATH")

  actual_docs=$(json_list_from_find "$ROOT_DIR/docs" -maxdepth 1 -type f -name '*.md' ! -name 'README.md')
  actual_lua=$(json_list_from_find "$ROOT_DIR/lua/wezterm/types/plugins" -maxdepth 1 -type f -name '*.lua')
  actual_vimdoc=$(json_list_from_find "$ROOT_DIR/doc" -maxdepth 1 -type f -name 'wezterm-types-plugin.*.txt')

  compare_lists "docs" "$manifest_docs" "$actual_docs"
  compare_lists "lua" "$manifest_lua" "$actual_lua"
  compare_lists "vimdoc" "$manifest_vimdoc" "$actual_vimdoc"

  while IFS= read -r path; do
    [[ -f "$ROOT_DIR/$path" ]] || die "Manifest path does not exist: $path"
  done < <(jq -r '.[] | .docs_path, .lua_path, .vimdoc_path' "$MANIFEST_PATH")
}

validate_readme() {
  check_readme_table
}

validate() {
  if [[ $# -gt 0 ]]; then
    die "$(main_usage)"
  fi

  require_cmd jq

  [[ -f "$MANIFEST_PATH" ]] || die "Missing manifest: $MANIFEST_PATH"
  [[ -f "$README_PATH" ]] || die "Missing README: $README_PATH"

  validate_manifest_schema
  validate_inventory
  validate_readme
}

sync() {
  local strict=0
  local checked_at repo_slug_value pages_base_url_value tmp tmp_err

  if [[ "${1:-}" == "--strict" ]]; then
    strict=1
  elif [[ $# -gt 0 ]]; then
    die "$(main_usage)"
  fi

  require_cmd gh
  require_cmd jq
  validate_manifest_schema

  mkdir -p "$BUILD_DIR"
  tmp=$(mktemp)
  tmp_err=$(mktemp)
  checked_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  repo_slug_value=$(repo_slug)
  pages_base_url_value=$(pages_base_url)

  jq -c 'sort_by(.readme_name | ascii_downcase)[]' "$MANIFEST_PATH" | while IFS= read -r entry; do
    local repo tracked_kind tracked_value repo_json release_json repo_url default_branch upstream_kind upstream_value status
    repo=$(jq -r '.repo' <<<"$entry")
    tracked_kind=$(jq -r '.tracked_ref.kind' <<<"$entry")
    tracked_value=$(jq -r '.tracked_ref.value' <<<"$entry")
    repo_url="https://github.com/$repo"

    if ! repo_json=$(gh api "repos/$repo" 2>"$tmp_err"); then
      emit_sync_error_record "$entry" "$checked_at" "$repo_url" "$(normalize_error_text "$tmp_err")" >>"$tmp"
      printf '\n' >>"$tmp"
      continue
    fi

    repo_url=$(jq -r '.html_url' <<<"$repo_json")
    default_branch=$(jq -r '.default_branch' <<<"$repo_json")

    if release_json=$(gh api "repos/$repo/releases/latest" 2>/dev/null); then
      upstream_kind="release"
      upstream_value=$(jq -r '.tag_name' <<<"$release_json")
    else
      upstream_value=$(gh api "repos/$repo/tags?per_page=1" --jq '.[0].name // empty' 2>/dev/null || true)
      if [[ -n "$upstream_value" ]]; then
        upstream_kind="tag"
      else
        if ! upstream_value=$(gh api "repos/$repo/commits/$default_branch" --jq '.sha' 2>"$tmp_err"); then
          emit_sync_error_record "$entry" "$checked_at" "$repo_url" "$(normalize_error_text "$tmp_err")" >>"$tmp"
          printf '\n' >>"$tmp"
          continue
        fi
        upstream_kind="commit"
      fi
    fi

    if [[ "$tracked_kind" == "$upstream_kind" && "$tracked_value" == "$upstream_value" ]]; then
      status="up_to_date"
    else
      status="outdated"
    fi

    emit_sync_status_record "$entry" "$checked_at" "$repo_url" "$status" "$upstream_kind" "$upstream_value" >>"$tmp"
    printf '\n' >>"$tmp"
  done

  jq -s \
    --arg checked_at "$checked_at" \
    --arg repo_slug "$repo_slug_value" \
    --arg pages_base_url "$pages_base_url_value" \
    --arg repo_branch "$(repo_branch)" \
    '{
      checked_at: $checked_at,
      repo_slug: $repo_slug,
      repo_branch: $repo_branch,
      pages_base_url: $pages_base_url,
      summary: {
        total: length,
        up_to_date: (map(select(.status == "up_to_date")) | length),
        outdated: (map(select(.status == "outdated")) | length),
        error: (map(select(.status == "error")) | length)
      },
      plugins: .
    }' "$tmp" >"$SYNC_PATH"

  rm -f "$tmp" "$tmp_err"

  if [[ $strict -eq 1 ]] && ! jq -e '.summary.outdated == 0 and .summary.error == 0' "$SYNC_PATH" >/dev/null; then
    die "Drift detected"
  fi
}

review() {
  if [[ $# -gt 0 ]]; then
    die "$(main_usage)"
  fi

  require_cmd jq
  require_sync_report

  printf 'Plugin maintenance report written to %s\n' "$SYNC_PATH"
  printf 'Checked at: %s\n' "$(jq -r '.checked_at' "$SYNC_PATH")"
  printf 'Summary: total=%s up_to_date=%s outdated=%s error=%s\n\n' \
    "$(jq -r '.summary.total' "$SYNC_PATH")" \
    "$(jq -r '.summary.up_to_date' "$SYNC_PATH")" \
    "$(jq -r '.summary.outdated' "$SYNC_PATH")" \
    "$(jq -r '.summary.error' "$SYNC_PATH")"

  print_report_section \
    "Outdated plugins:" \
    $'Plugin\tRepository\tTracked\tUpstream' \
    '
      .plugins[]
      | select(.status == "outdated")
      | [
          .readme_name,
          .repo,
          (if .tracked_ref.kind == "commit" then .tracked_ref.kind + ":" + .tracked_ref.value[0:7] else .tracked_ref.kind + ":" + .tracked_ref.value end),
          (if .upstream_ref.kind == "commit" then .upstream_ref.kind + ":" + .upstream_ref.value[0:7] else .upstream_ref.kind + ":" + .upstream_ref.value end)
        ]
      | @tsv
    '

  print_report_section \
    "Errors:" \
    $'Plugin\tRepository\tError' \
    '
      .plugins[]
      | select(.status == "error")
      | [.readme_name, .repo, .error]
      | @tsv
    '
}

render_pages() {
  local report_path repo_slug_value repo_branch_value plugin_rows summary_html page_template page_html redirect_template

  require_cmd jq
  require_sync_report
  report_path="$SYNC_PATH"
  [[ -f "$PAGE_TEMPLATE_PATH" ]] || die "Missing page template: $PAGE_TEMPLATE_PATH"
  [[ -f "$REDIRECT_TEMPLATE_PATH" ]] || die "Missing redirect template: $REDIRECT_TEMPLATE_PATH"

  repo_slug_value=$(jq -r '.repo_slug' "$report_path")
  repo_branch_value=$(jq -r '.repo_branch' "$report_path")

  rm -rf "$PAGES_DIR"
  mkdir -p "$PAGES_DIR/plugin-maintenance/badges"
  cp "$report_path" "$PAGES_DIR/plugin-maintenance/report.json"

  jq -c '.plugins[]' "$report_path" | while IFS= read -r plugin; do
    local slug status message color
    slug=$(jq -r '.slug' <<<"$plugin")
    status=$(jq -r '.status' <<<"$plugin")

    case "$status" in
    up_to_date)
      message="up to date"
      color="brightgreen"
      ;;
    outdated)
      message="outdated"
      color="yellow"
      ;;
    *)
      message="error"
      color="orange"
      ;;
    esac

    jq -nc \
      --arg label "maintenance" \
      --arg message "$message" \
      --arg color "$color" \
      '{schemaVersion: 1, label: $label, message: $message, color: $color}' \
      >"$PAGES_DIR/plugin-maintenance/badges/${slug}.json"
  done

  summary_html=$(jq -r '
    "<ul class=\"summary\">"
    + "<li><strong>Total:</strong> \(.summary.total)</li>"
    + "<li><strong>Up to date:</strong> \(.summary.up_to_date)</li>"
    + "<li><strong>Outdated:</strong> \(.summary.outdated)</li>"
    + "<li><strong>Errors:</strong> \(.summary.error)</li>"
    + "<li><strong>Checked at:</strong> <code>\(.checked_at)</code></li>"
    + "</ul>"
  ' "$report_path")

  plugin_rows=$(jq -r --arg repo_slug "$repo_slug_value" --arg repo_branch "$repo_branch_value" '
    .plugins[]
    | (
      if .status == "outdated" and .upstream_ref and .tracked_ref.value != .upstream_ref.value then
        "https://github.com/" + .repo + "/compare/" + .tracked_ref.value + "..." + .upstream_ref.value
      else
        ""
      end
    ) as $compare_url
    | (
      if .upstream_ref then
        if .upstream_ref.kind == "commit" then
          (.upstream_ref.kind + ":" + .upstream_ref.value[0:7])
        else
          (.upstream_ref.kind + ":" + .upstream_ref.value)
        end
      else
        "-"
      end
    ) as $upstream_text
    | (
      if .tracked_ref.kind == "commit" then
        (.tracked_ref.kind + ":" + .tracked_ref.value[0:7])
      else
        (.tracked_ref.kind + ":" + .tracked_ref.value)
      end
    ) as $tracked_text
    | (
      if .upstream_ref then
        "<code>" + ($upstream_text | @html) + "</code>"
      else
        "<code>-</code>"
      end
      + (
          if $compare_url != "" then
            "<div class=\"cell-action\"><a class=\"compare-link\" href=\"" + ($compare_url | @html) + "\">diff ↗</a></div>"
          else
            ""
          end
        )
    ) as $upstream_cell
    | "<tr id=\"\(.slug)\" data-status=\"\(.status | @html)\">"
      + "<td><a href=\"https://github.com/\(.repo)\">\(.readme_name | @html)</a></td>"
      + "<td><a href=\"https://github.com/\($repo_slug)/blob/\($repo_branch)/\(.docs_path)\">\(.docs_path | @html)</a></td>"
      + "<td><a href=\"https://github.com/\($repo_slug)/blob/\($repo_branch)/\(.vimdoc_path)\">\(.vimdoc_path | @html)</a></td>"
      + "<td>"
      + "<img alt=\"\(.status | @html)\" src=\"BADGE_URL:\(.slug)\" />"
      + "<br><code>\($tracked_text | @html)</code>"
      + "</td>"
      + "<td>" + $upstream_cell + "</td>"
      + "</tr>"
  ' "$report_path")

  while IFS= read -r slug; do
    plugin_rows=${plugin_rows//BADGE_URL:$slug/$(badge_url "$slug")}
  done < <(jq -r '.plugins[].slug' "$report_path")

  page_template=$(<"$PAGE_TEMPLATE_PATH")
  page_html=${page_template//__SUMMARY_HTML__/$summary_html}
  page_html=${page_html//__PLUGIN_ROWS__/$plugin_rows}
  printf '%s\n' "$page_html" >"$PAGES_DIR/plugin-maintenance/index.html"

  redirect_template=$(<"$REDIRECT_TEMPLATE_PATH")
  printf '%s\n' "$redirect_template" >"$PAGES_DIR/index.html"
}

main() {
  local command=${1:-}

  case "$command" in
  table)
    shift
    table "$@"
    ;;
  validate)
    shift
    validate "$@"
    ;;
  sync)
    shift
    sync "$@"
    ;;
  review)
    shift
    review "$@"
    ;;
  render-pages)
    shift
    parse_serve_args "$@"
    render_pages
    if [[ $PLUGIN_MAINTENANCE_SHOULD_SERVE -eq 1 ]]; then
      serve_pages "$PLUGIN_MAINTENANCE_SERVE_PORT"
    fi
    ;;
  *)
    die "$(main_usage)"
    ;;
  esac
}

main "$@"
