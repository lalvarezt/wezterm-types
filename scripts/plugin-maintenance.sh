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
  printf 'Usage: %s {table|validate|sync|review|accept|render-pages} ...\n' "$0"
}

table_usage() {
  printf 'Usage: %s table [--check|--stdout]\n' "$0"
}

accept_usage() {
  printf 'Usage: %s accept <slug> --from <none|kind:value> --to <kind:value>\n' "$0"
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

reviewed_ref_text() {
  local kind=$1
  local value=$2

  if [[ "$kind" == "none" ]]; then
    printf 'none\n'
    return
  fi

  if [[ "$kind" == "commit" ]]; then
    printf '%s:%s\n' "$kind" "${value:0:7}"
    return
  fi

  printf '%s:%s\n' "$kind" "$value"
}

render_table_block() {
  printf '| Plugin | Documentation | Neovim Help | Status |\n'
  printf '| --- | --- | --- | --- |\n'

  while IFS=$'\t' read -r slug readme_name repo docs_path vimdoc_path reviewed_kind reviewed_value; do
    local plugin_cell docs_cell help_cell status_cell reviewed_text
    plugin_cell="[$readme_name](https://github.com/$repo)"
    docs_cell="[$docs_path](./$docs_path)"
    help_cell="[:h $(basename "$vimdoc_path")](./$vimdoc_path)"
    reviewed_text=$(reviewed_ref_text "$reviewed_kind" "$reviewed_value")
    status_cell="[![status]($(badge_url "$slug"))]($(report_url "$slug"))<br><code>${reviewed_text}</code>"

    printf '| %s | %s | %s | %s |\n' \
      "$plugin_cell" "$docs_cell" "$help_cell" "$status_cell"
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
          (.reviewed_ref.kind // "none"),
          (.reviewed_ref.value // "")
        ]
      | @tsv
    ' "$MANIFEST_PATH"
  )
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
      error: $error,
      upstream_ref: null,
      compare_url: null
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
      },
      compare_url: (
        if $status == "review_required" then
          $repo_url + "/compare/" + $manifest.reviewed_ref.value + "..." + $upstream_value
        else
          null
        end
      )
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
      and has("reviewed_ref")
      and (
        .reviewed_ref == null
        or (
          (.reviewed_ref | type == "object")
          and (
            .reviewed_ref.kind == "release"
            or .reviewed_ref.kind == "tag"
            or .reviewed_ref.kind == "commit"
          )
          and (.reviewed_ref.value | type == "string" and length > 0)
        )
      )
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
    local repo reviewed_kind reviewed_value repo_json release_json repo_url default_branch upstream_kind upstream_value status
    repo=$(jq -r '.repo' <<<"$entry")
    reviewed_kind=$(jq -r '.reviewed_ref.kind // "none"' <<<"$entry")
    reviewed_value=$(jq -r '.reviewed_ref.value // ""' <<<"$entry")
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

    if [[ "$reviewed_kind" == "none" ]]; then
      status="unreviewed"
    elif [[ "$reviewed_kind" == "$upstream_kind" && "$reviewed_value" == "$upstream_value" ]]; then
      status="reviewed"
    else
      status="review_required"
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
      schema_version: 2,
      checked_at: $checked_at,
      repo_slug: $repo_slug,
      repo_branch: $repo_branch,
      pages_base_url: $pages_base_url,
      summary: {
        total: length,
        reviewed: (map(select(.status == "reviewed")) | length),
        review_required: (map(select(.status == "review_required")) | length),
        unreviewed: (map(select(.status == "unreviewed")) | length),
        error: (map(select(.status == "error")) | length)
      },
      plugins: .
    }' "$tmp" >"$SYNC_PATH"

  rm -f "$tmp" "$tmp_err"

  if [[ $strict -eq 1 ]] && ! jq -e '.summary.review_required == 0 and .summary.unreviewed == 0 and .summary.error == 0' "$SYNC_PATH" >/dev/null; then
    die "Plugin review required"
  fi
}

parse_ref_arg() {
  local value=$1
  local allow_none=${2:-0}

  if [[ "$value" == "none" && $allow_none -eq 1 ]]; then
    PARSED_REF_KIND="none"
    PARSED_REF_VALUE=""
    return
  fi

  [[ "$value" == *:* ]] || die "Invalid ref '$value'; expected kind:value"
  PARSED_REF_KIND=${value%%:*}
  PARSED_REF_VALUE=${value#*:}
  case "$PARSED_REF_KIND" in
  release | tag | commit) ;;
  *) die "Invalid ref kind: $PARSED_REF_KIND" ;;
  esac
  [[ -n "$PARSED_REF_VALUE" ]] || die "Ref value cannot be empty"
}

accept() {
  local slug=${1:-}
  local from_arg="" to_arg=""
  local from_kind from_value to_kind to_value manifest_count current_ref report_count report_status report_ref
  local report_kind report_value repo candidate_sha baseline_sha comparison merge_base_sha
  local tmp manifest_backup readme_backup

  [[ -n "$slug" ]] || die "$(accept_usage)"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --from)
      [[ $# -gt 1 ]] || die "$(accept_usage)"
      from_arg=$2
      shift 2
      ;;
    --to)
      [[ $# -gt 1 ]] || die "$(accept_usage)"
      to_arg=$2
      shift 2
      ;;
    *) die "$(accept_usage)" ;;
    esac
  done

  [[ -n "$from_arg" && -n "$to_arg" ]] || die "$(accept_usage)"
  require_cmd jq
  require_sync_report
  validate_manifest_schema

  parse_ref_arg "$from_arg" 1
  from_kind=$PARSED_REF_KIND
  from_value=$PARSED_REF_VALUE
  parse_ref_arg "$to_arg" 0
  to_kind=$PARSED_REF_KIND
  to_value=$PARSED_REF_VALUE

  manifest_count=$(jq --arg slug "$slug" '[.[] | select(.slug == $slug)] | length' "$MANIFEST_PATH")
  [[ "$manifest_count" == "1" ]] || die "Unknown or ambiguous plugin slug: $slug"

  current_ref=$(jq -r --arg slug "$slug" '
    .[] | select(.slug == $slug)
    | if .reviewed_ref == null then "none" else .reviewed_ref.kind + ":" + .reviewed_ref.value end
  ' "$MANIFEST_PATH")

  if [[ "$current_ref" == "$to_kind:$to_value" ]]; then
    printf '%s is already reviewed at %s\n' "$slug" "$current_ref"
    return
  fi

  [[ "$current_ref" == "$from_arg" ]] || die "Stale reviewed baseline for $slug: expected $from_arg, found $current_ref"

  report_count=$(jq --arg slug "$slug" '[.plugins[] | select(.slug == $slug)] | length' "$SYNC_PATH")
  [[ "$report_count" == "1" ]] || die "Plugin $slug is missing or duplicated in $SYNC_PATH"
  report_status=$(jq -r --arg slug "$slug" '.plugins[] | select(.slug == $slug) | .status' "$SYNC_PATH")
  [[ "$report_status" != "error" ]] || die "Cannot accept $slug because upstream resolution failed"
  report_ref=$(jq -r --arg slug "$slug" '
    .plugins[] | select(.slug == $slug)
    | if .upstream_ref == null then "none" else .upstream_ref.kind + ":" + .upstream_ref.value end
  ' "$SYNC_PATH")

  if [[ "$report_ref" != "$to_arg" ]]; then
    report_kind=${report_ref%%:*}
    report_value=${report_ref#*:}
    [[ "$to_kind" == "commit" && "$report_kind" == "commit" ]] \
      || die "Custom acceptance refs are only supported for commit-tracked plugins"
    [[ "$to_value" =~ ^[[:xdigit:]]{40}$ ]] \
      || die "Custom commit refs must use a full 40-character SHA"

    require_cmd gh
    repo=$(jq -r --arg slug "$slug" '.plugins[] | select(.slug == $slug) | .repo' "$SYNC_PATH")
    [[ "$repo" =~ ^[^/]+/[^/]+$ ]] || die "Invalid upstream repository for $slug: $repo"

    candidate_sha=$(gh api "repos/$repo/commits/$to_value" --jq '.sha') \
      || die "Cannot resolve candidate commit $to_value for $slug"
    candidate_sha=${candidate_sha,,}
    to_value=${to_value,,}
    [[ "$candidate_sha" == "$to_value" ]] || die "Candidate commit did not resolve exactly: $to_value"

    comparison=$(gh api "repos/$repo/compare/$candidate_sha...$report_value") \
      || die "Cannot compare candidate $candidate_sha with upstream $report_value"
    merge_base_sha=$(jq -r '.merge_base_commit.sha' <<<"$comparison")
    [[ "$merge_base_sha" == "$candidate_sha" ]] \
      || die "Candidate commit $candidate_sha is not an ancestor of upstream $report_value"

    if [[ "$current_ref" != "none" ]]; then
      [[ "$from_kind" == "commit" ]] \
        || die "Cannot accept an intermediate commit from a non-commit baseline"
      baseline_sha=$(gh api "repos/$repo/commits/$from_value" --jq '.sha') \
        || die "Cannot resolve reviewed baseline $from_value for $slug"
      comparison=$(gh api "repos/$repo/compare/$baseline_sha...$candidate_sha") \
        || die "Cannot compare reviewed baseline $baseline_sha with candidate $candidate_sha"
      merge_base_sha=$(jq -r '.merge_base_commit.sha' <<<"$comparison")
      [[ "$merge_base_sha" == "$baseline_sha" ]] \
        || die "Candidate commit $candidate_sha is not newer than reviewed baseline $baseline_sha"
    fi

    to_arg="commit:$candidate_sha"
  fi

  tmp=$(mktemp)
  manifest_backup=$(mktemp)
  readme_backup=$(mktemp)
  cp "$MANIFEST_PATH" "$manifest_backup"
  cp "$README_PATH" "$readme_backup"

  if ! (
    jq --arg slug "$slug" --arg kind "$to_kind" --arg value "$to_value" '
      map(if .slug == $slug then .reviewed_ref = {kind: $kind, value: $value} else . end)
    ' "$MANIFEST_PATH" >"$tmp"
    mv "$tmp" "$MANIFEST_PATH"
    write_readme_table
    validate
  ); then
    cp "$manifest_backup" "$MANIFEST_PATH"
    cp "$readme_backup" "$README_PATH"
    rm -f "$tmp" "$manifest_backup" "$readme_backup"
    die "Failed to accept $slug; restored manifest and README"
  fi

  rm -f "$tmp" "$manifest_backup" "$readme_backup"
  printf 'Accepted %s: %s -> %s\n' "$slug" "$from_arg" "$to_arg"
}

review() {
  if [[ $# -gt 0 ]]; then
    die "$(main_usage)"
  fi

  require_cmd jq
  require_sync_report

  printf 'Plugin maintenance report written to %s\n' "$SYNC_PATH"
  printf 'Checked at: %s\n' "$(jq -r '.checked_at' "$SYNC_PATH")"
  printf 'Summary: total=%s reviewed=%s review_required=%s unreviewed=%s error=%s\n\n' \
    "$(jq -r '.summary.total' "$SYNC_PATH")" \
    "$(jq -r '.summary.reviewed' "$SYNC_PATH")" \
    "$(jq -r '.summary.review_required' "$SYNC_PATH")" \
    "$(jq -r '.summary.unreviewed' "$SYNC_PATH")" \
    "$(jq -r '.summary.error' "$SYNC_PATH")"

  print_report_section \
    "Plugins requiring review:" \
    $'Plugin\tRepository\tReviewed\tUpstream\tDiff' \
    '
      .plugins[]
      | select(.status == "review_required")
      | [
          .readme_name,
          .repo,
          (if .reviewed_ref.kind == "commit" then .reviewed_ref.kind + ":" + .reviewed_ref.value[0:7] else .reviewed_ref.kind + ":" + .reviewed_ref.value end),
          (if .upstream_ref.kind == "commit" then .upstream_ref.kind + ":" + .upstream_ref.value[0:7] else .upstream_ref.kind + ":" + .upstream_ref.value end),
          .compare_url
        ]
      | @tsv
    '

  print_report_section \
    "Plugins not yet reviewed:" \
    $'Plugin\tRepository\tUpstream' \
    '
      .plugins[]
      | select(.status == "unreviewed")
      | [
          .readme_name,
          .repo,
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
  local report_path repo_slug_value repo_branch_value plugin_rows summary_html summary_tmp rows_tmp redirect_template

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
    reviewed)
      message="reviewed"
      color="brightgreen"
      ;;
    review_required)
      message="review required"
      color="yellow"
      ;;
    unreviewed)
      message="unreviewed"
      color="orange"
      ;;
    *)
      message="error"
      color="red"
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
    + "<li><strong>Reviewed:</strong> \(.summary.reviewed)</li>"
    + "<li><strong>Review required:</strong> \(.summary.review_required)</li>"
    + "<li><strong>Unreviewed:</strong> \(.summary.unreviewed)</li>"
    + "<li><strong>Errors:</strong> \(.summary.error)</li>"
    + "<li><strong>Checked at:</strong> <code>\(.checked_at)</code></li>"
    + "</ul>"
  ' "$report_path")

  plugin_rows=$(jq -r --arg repo_slug "$repo_slug_value" --arg repo_branch "$repo_branch_value" '
    .plugins[]
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
      if .reviewed_ref == null then
        "none"
      elif .reviewed_ref.kind == "commit" then
        (.reviewed_ref.kind + ":" + .reviewed_ref.value[0:7])
      else
        (.reviewed_ref.kind + ":" + .reviewed_ref.value)
      end
    ) as $reviewed_text
    | (
      if .upstream_ref == null then
        ""
      elif .upstream_ref.kind == "commit" then
        .repo_url + "/commit/" + .upstream_ref.value
      elif .upstream_ref.kind == "release" then
        .repo_url + "/releases/tag/" + .upstream_ref.value
      else
        .repo_url + "/tree/" + .upstream_ref.value
      end
    ) as $upstream_url
    | (
      "/accept " + .slug
    ) as $accept_command
    | (
      if .status == "review_required" then
        "<a class=\"compare-link\" href=\"" + (.compare_url | @html) + "\">Review diff ↗</a>"
      elif .status == "unreviewed" then
        "<a class=\"compare-link\" href=\"" + ($upstream_url | @html) + "\">Review upstream ↗</a>"
      else
        ""
      end
    ) as $review_link
    | (
      if .status == "review_required" or .status == "unreviewed" then
        "<div class=\"review-actions\">"
        + $review_link
        + "<button type=\"button\" class=\"copy-command\" data-command=\"" + ($accept_command | @html) + "\">Copy command</button>"
        + "</div>"
      else
        ""
      end
    ) as $actions_cell
    | "<tr id=\"\(.slug)\" data-status=\"\(.status | @html)\">"
      + "<td><a href=\"https://github.com/\(.repo)\">\(.readme_name | @html)</a></td>"
      + "<td><a href=\"https://github.com/\($repo_slug)/blob/\($repo_branch)/\(.docs_path)\">\(.docs_path | @html)</a></td>"
      + "<td><a href=\"https://github.com/\($repo_slug)/blob/\($repo_branch)/\(.vimdoc_path)\">\(.vimdoc_path | @html)</a></td>"
      + "<td><img alt=\"\(.status | @html)\" src=\"BADGE_URL:\(.slug)\" />"
      + (if .status == "error" then "<div class=\"error-text\">" + (.error | @html) + "</div>" else "" end)
      + "</td>"
      + "<td><code>\($reviewed_text | @html)</code></td>"
      + "<td><code>\($upstream_text | @html)</code></td>"
      + "<td>" + $actions_cell + "</td>"
      + "</tr>"
  ' "$report_path")

  while IFS= read -r slug; do
    plugin_rows=${plugin_rows//BADGE_URL:$slug/$(badge_url "$slug")}
  done < <(jq -r '.plugins[].slug' "$report_path")

  summary_tmp=$(mktemp)
  rows_tmp=$(mktemp)
  printf '%s\n' "$summary_html" >"$summary_tmp"
  printf '%s\n' "$plugin_rows" >"$rows_tmp"
  awk -v summary_file="$summary_tmp" -v rows_file="$rows_tmp" '
    $0 == "__SUMMARY_HTML__" {
      while ((getline line < summary_file) > 0) print line
      close(summary_file)
      next
    }
    $0 == "__PLUGIN_ROWS__" {
      while ((getline line < rows_file) > 0) print line
      close(rows_file)
      next
    }
    { print }
  ' "$PAGE_TEMPLATE_PATH" >"$PAGES_DIR/plugin-maintenance/index.html"
  rm -f "$summary_tmp" "$rows_tmp"

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
  accept)
    shift
    accept "$@"
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
