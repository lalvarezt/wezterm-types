# wezterm-types

<p><a href="https://github.com/michaelbrusegard/awesome-wezterm"><img alt="Mentioned in Awesome WezTerm" src="https://awesome.re/mentioned-badge.svg" /></a><br /><a href="https://github.com/rockerBOO/awesome-neovim"><img alt="Mentioned in Awesome Neovim" src="https://awesome.re/mentioned-badge.svg" /></a></p>

<a href="#"><img alt="Showcase" src="https://github.com/DrKJeff16/wezterm-types/blob/main/assets/showcase.png" /></a>

This project aims to provide LuaCATS-like [LuaLS type annotations](https://luals.github.io/wiki/annotations/)
for your [WezTerm](https://github.com/wezterm/wezterm) config.

Example videos can be found in [EXAMPLES.md](https://github.com/DrKJeff16/wezterm-types/blob/main/EXAMPLES.md).

NOTE: For any missing or unclear types you should always double-check the [WezTerm Lua Reference](https://wezterm.org/config/lua/general.html).
If using an annotated plugin featured in this repository please refer to its author
for any unclear types.

## Features

- LuaCATS-like type annotations
- Built-in colorschemes included (`config.color_scheme`)
- Up-to-date descriptions
- Community plugin annotations
- Neovim support
  - Through lazydev.nvim
  - Through the built-in LSP API
- VSCode/VSCodium support by cloning this into `~/.config/wezterm`, then editing your config
  in that directory

---

## Table of Contents

- [Installation](#installation)
- [Featured Plugins](#featured-plugins)
- [Usage](#usage)

---

## Installation

### LuaRocks

You can install `wezterm-types` using LuaRocks:

```bash
luarocks install wezterm-types # Global install
luarocks install --local wezterm-types # Local install
```

To get it running in Neovim please refer to [this discussion](https://github.com/DrKJeff16/wezterm-types/discussions/93).

### Neovim

We recommend using [lazy.nvim](https://github.com/folke/lazy.nvim) as a package manager:

```lua
{
  'DrKJeff16/wezterm-types',
  version = false, -- Get the latest version
},
```

---

## Featured Plugins

This project also features type annotations for various WezTerm plugins.

**_If you want to add your plugin, please read [`CONTRIBUTING.md`](https://github.com/DrKJeff16/wezterm-types/blob/main/CONTRIBUTING.md#plugins)._**

<!-- plugin-table:start -->
| Plugin | Documentation | Neovim Help | &nbsp;Status&nbsp;/&nbsp;Current&nbsp; |
| --- | --- | --- | --- |
| [ai-commander.wezterm](https://github.com/dimao/ai-commander.wezterm) | [docs/ai-commander.md](./docs/ai-commander.md) | [:h wezterm-types-plugin.ai-commander.txt](./doc/wezterm-types-plugin.ai-commander.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fai-commander.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#ai-commander)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fai-commander-current.json%3Fv%3D1) |
| [ai-helper.wezterm](https://github.com/Michal1993r/ai-helper.wezterm) | [docs/ai-helper.md](./docs/ai-helper.md) | [:h wezterm-types-plugin.ai-helper.txt](./doc/wezterm-types-plugin.ai-helper.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fai-helper.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#ai-helper)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fai-helper-current.json%3Fv%3D1) |
| [bar.wezterm](https://github.com/adriankarlen/bar.wezterm) | [docs/bar.md](./docs/bar.md) | [:h wezterm-types-plugin.bar.txt](./doc/wezterm-types-plugin.bar.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fbar.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#bar)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fbar-current.json%3Fv%3D1) |
| [battery.wez](https://github.com/rootiest/battery.wez) | [docs/battery.md](./docs/battery.md) | [:h wezterm-types-plugin.battery.txt](./doc/wezterm-types-plugin.battery.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fbattery.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#battery)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fbattery-current.json%3Fv%3D1) |
| [chord.wz](https://github.com/sravioli/chord.wz) | [docs/chord.md](./docs/chord.md) | [:h wezterm-types-plugin.chord.txt](./doc/wezterm-types-plugin.chord.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fchord.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#chord)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fchord-current.json%3Fv%3D1) |
| [dev.wezterm](https://github.com/ChrisGVE/dev.wezterm) | [docs/dev.md](./docs/dev.md) | [:h wezterm-types-plugin.dev.txt](./doc/wezterm-types-plugin.dev.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fdev.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#dev)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fdev-current.json%3Fv%3D1) |
| [kanagawa.wz](https://github.com/sravioli/kanagawa.wz) | [docs/kanagawa.md](./docs/kanagawa.md) | [:h wezterm-types-plugin.kanagawa.txt](./doc/wezterm-types-plugin.kanagawa.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fkanagawa.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#kanagawa)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fkanagawa-current.json%3Fv%3D1) |
| [lantern.wz](https://github.com/sravioli/lantern.wz) | [docs/lantern.md](./docs/lantern.md) | [:h wezterm-types-plugin.lantern.txt](./doc/wezterm-types-plugin.lantern.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flantern.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#lantern)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flantern-current.json%3Fv%3D1) |
| [lib.wezterm](https://github.com/ChrisGVE/lib.wezterm) | [docs/lib.md](./docs/lib.md) | [:h wezterm-types-plugin.lib.txt](./doc/wezterm-types-plugin.lib.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flib.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#lib)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flib-current.json%3Fv%3D1) |
| [listeners.wezterm](https://github.com/ChrisGVE/listeners.wezterm) | [docs/listeners.md](./docs/listeners.md) | [:h wezterm-types-plugin.listeners.txt](./doc/wezterm-types-plugin.listeners.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flisteners.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#listeners)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flisteners-current.json%3Fv%3D1) |
| [log.wz](https://github.com/sravioli/log.wz) | [docs/log.md](./docs/log.md) | [:h wezterm-types-plugin.log.txt](./doc/wezterm-types-plugin.log.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flog.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#log)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Flog-current.json%3Fv%3D1) |
| [memo.wz](https://github.com/sravioli/memo.wz) | [docs/memo.md](./docs/memo.md) | [:h wezterm-types-plugin.memo.txt](./doc/wezterm-types-plugin.memo.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fmemo.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#memo)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fmemo-current.json%3Fv%3D1) |
| [modal.wezterm](https://github.com/MLFlexer/modal.wezterm) | [docs/modal.md](./docs/modal.md) | [:h wezterm-types-plugin.modal.txt](./doc/wezterm-types-plugin.modal.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fmodal.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#modal)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fmodal-current.json%3Fv%3D1) |
| [passrelay.wezterm](https://github.com/dfaerch/passrelay.wezterm) | [docs/passrelay.md](./docs/passrelay.md) | [:h wezterm-types-plugin.passrelay.txt](./doc/wezterm-types-plugin.passrelay.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpassrelay.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#passrelay)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpassrelay-current.json%3Fv%3D1) |
| [pinned-tabs.wezterm](https://github.com/selectnull/pinned-tabs.wezterm) | [docs/pinned-tabs.md](./docs/pinned-tabs.md) | [:h wezterm-types-plugin.pinned-tabs.txt](./doc/wezterm-types-plugin.pinned-tabs.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpinned-tabs.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#pinned-tabs)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpinned-tabs-current.json%3Fv%3D1) |
| [pivot_panes.wezterm](https://github.com/ChrisGVE/pivot_panes.wezterm) | [docs/pivot-panes.md](./docs/pivot-panes.md) | [:h wezterm-types-plugin.pivot-panes.txt](./doc/wezterm-types-plugin.pivot-panes.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpivot-panes.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#pivot-panes)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpivot-panes-current.json%3Fv%3D1) |
| [presentation.wez](https://github.com/xarvex/presentation.wez) | [docs/presentation.md](./docs/presentation.md) | [:h wezterm-types-plugin.presentation.txt](./doc/wezterm-types-plugin.presentation.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpresentation.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#presentation)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fpresentation-current.json%3Fv%3D1) |
| [quick_domains.wezterm](https://github.com/DavidRR-F/quick_domains.wezterm) | [docs/quick-domains.md](./docs/quick-domains.md) | [:h wezterm-types-plugin.quick-domains.txt](./doc/wezterm-types-plugin.quick-domains.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquick-domains.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#quick-domains)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquick-domains-current.json%3Fv%3D1) |
| [quickselect.wezterm](https://github.com/quantonganh/quickselect.wezterm) | [docs/quickselect.md](./docs/quickselect.md) | [:h wezterm-types-plugin.quickselect.txt](./doc/wezterm-types-plugin.quickselect.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquickselect.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#quickselect)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquickselect-current.json%3Fv%3D1) |
| [resurrect.wezterm](https://github.com/MLFlexer/resurrect.wezterm) | [docs/resurrect.md](./docs/resurrect.md) | [:h wezterm-types-plugin.resurrect.txt](./doc/wezterm-types-plugin.resurrect.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fresurrect.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#resurrect)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fresurrect-current.json%3Fv%3D1) |
| [ribbon.wz](https://github.com/sravioli/ribbon.wz) | [docs/ribbon.md](./docs/ribbon.md) | [:h wezterm-types-plugin.ribbon.txt](./doc/wezterm-types-plugin.ribbon.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fribbon.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#ribbon)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fribbon-current.json%3Fv%3D1) |
| [rosepine](https://github.com/neapsix/wezterm) | [docs/rosepine.md](./docs/rosepine.md) | [:h wezterm-types-plugin.rosepine.txt](./doc/wezterm-types-plugin.rosepine.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Frosepine.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#rosepine)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Frosepine-current.json%3Fv%3D1) |
| [sessionizer.wezterm](https://github.com/mikkasendke/sessionizer.wezterm) | [docs/sessionizer.md](./docs/sessionizer.md) | [:h wezterm-types-plugin.sessionizer.txt](./doc/wezterm-types-plugin.sessionizer.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsessionizer.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#sessionizer)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsessionizer-current.json%3Fv%3D1) |
| [sigil.wz](https://github.com/sravioli/sigil.wz) | [docs/sigil.md](./docs/sigil.md) | [:h wezterm-types-plugin.sigil.txt](./doc/wezterm-types-plugin.sigil.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsigil.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#sigil)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsigil-current.json%3Fv%3D1) |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | [docs/smart-splits.md](./docs/smart-splits.md) | [:h wezterm-types-plugin.smart-splits.txt](./doc/wezterm-types-plugin.smart-splits.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsmart-splits.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#smart-splits)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsmart-splits-current.json%3Fv%3D1) |
| [smart_workspace_switcher.wezterm](https://github.com/MLFlexer/smart_workspace_switcher.wezterm) | [docs/smart-workspace-switcher.md](./docs/smart-workspace-switcher.md) | [:h wezterm-types-plugin.smart-workspace-switcher.txt](./doc/wezterm-types-plugin.smart-workspace-switcher.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsmart-workspace-switcher.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#smart-workspace-switcher)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsmart-workspace-switcher-current.json%3Fv%3D1) |
| [stack.wez](https://github.com/bad-noodles/stack.wez) | [docs/stack.md](./docs/stack.md) | [:h wezterm-types-plugin.stack.txt](./doc/wezterm-types-plugin.stack.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fstack.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#stack)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fstack-current.json%3Fv%3D1) |
| [sync-panes.wez](https://github.com/annie444/sync-panes.wez) | [docs/sync-panes.md](./docs/sync-panes.md) | [:h wezterm-types-plugin.sync-panes.txt](./doc/wezterm-types-plugin.sync-panes.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsync-panes.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#sync-panes)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsync-panes-current.json%3Fv%3D1) |
| [tabline.wez](https://github.com/michaelbrusegard/tabline.wez) | [docs/tabline.md](./docs/tabline.md) | [:h wezterm-types-plugin.tabline.txt](./doc/wezterm-types-plugin.tabline.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftabline.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#tabline)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftabline-current.json%3Fv%3D1) |
| [tabsets.wezterm](https://github.com/srackham/tabsets.wezterm) | [docs/tabsets.md](./docs/tabsets.md) | [:h wezterm-types-plugin.tabsets.txt](./doc/wezterm-types-plugin.tabsets.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftabsets.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#tabsets)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftabsets-current.json%3Fv%3D1) |
| [toggle_terminal.wez](https://github.com/zsh-sage/toggle_terminal.wez) | [docs/toggle-terminal.md](./docs/toggle-terminal.md) | [:h wezterm-types-plugin.toggle-terminal.txt](./doc/wezterm-types-plugin.toggle-terminal.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftoggle-terminal.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#toggle-terminal)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Ftoggle-terminal-current.json%3Fv%3D1) |
| [warp.wz](https://github.com/sravioli/warp.wz) | [docs/warp.md](./docs/warp.md) | [:h wezterm-types-plugin.warp.txt](./doc/wezterm-types-plugin.warp.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwarp.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#warp)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwarp-current.json%3Fv%3D1) |
| [wez-pain-control](https://github.com/sei40kr/wez-pain-control) | [docs/wez-pain-control.md](./docs/wez-pain-control.md) | [:h wezterm-types-plugin.wez-pain-control.txt](./doc/wezterm-types-plugin.wez-pain-control.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwez-pain-control.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wez-pain-control)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwez-pain-control-current.json%3Fv%3D1) |
| [wez-tmux](https://github.com/sei40kr/wez-tmux) | [docs/wez-tmux.md](./docs/wez-tmux.md) | [:h wezterm-types-plugin.wez-tmux.txt](./doc/wezterm-types-plugin.wez-tmux.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwez-tmux.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wez-tmux)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwez-tmux-current.json%3Fv%3D1) |
| [wezterm-agent-deck](https://github.com/Eric162/wezterm-agent-deck) | [docs/agent-deck.md](./docs/agent-deck.md) | [:h wezterm-types-plugin.agent-deck.txt](./doc/wezterm-types-plugin.agent-deck.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fagent-deck.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#agent-deck)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fagent-deck-current.json%3Fv%3D1) |
| [wezterm-attention](https://github.com/pro-vi/wezterm-attention) | [docs/attention.md](./docs/attention.md) | [:h wezterm-types-plugin.attention.txt](./doc/wezterm-types-plugin.attention.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fattention.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#attention)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fattention-current.json%3Fv%3D1) |
| [wezterm-cmd-sender](https://github.com/aureolebigben/wezterm-cmd-sender) | [docs/cmd-sender.md](./docs/cmd-sender.md) | [:h wezterm-types-plugin.cmd-sender.txt](./doc/wezterm-types-plugin.cmd-sender.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fcmd-sender.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#cmd-sender)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fcmd-sender-current.json%3Fv%3D1) |
| [wezterm-cmdpicker](https://github.com/abidibo/wezterm-cmdpicker) | [docs/cmdpicker.md](./docs/cmdpicker.md) | [:h wezterm-types-plugin.cmdpicker.txt](./doc/wezterm-types-plugin.cmdpicker.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fcmdpicker.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#cmdpicker)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fcmdpicker-current.json%3Fv%3D1) |
| [wezterm-config.nvim](https://github.com/winter-again/wezterm-config.nvim) | [docs/wezterm-config.md](./docs/wezterm-config.md) | [:h wezterm-types-plugin.wezterm-config.txt](./doc/wezterm-types-plugin.wezterm-config.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-config.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wezterm-config)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-config-current.json%3Fv%3D1) |
| [wezterm-quota-limit](https://github.com/EdenGibson/wezterm-quota-limit) | [docs/quota-limit.md](./docs/quota-limit.md) | [:h wezterm-types-plugin.quota-limit.txt](./doc/wezterm-types-plugin.quota-limit.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquota-limit.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#quota-limit)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fquota-limit-current.json%3Fv%3D1) |
| [wezterm-replay](https://github.com/btrachey/wezterm-replay) | [docs/replay.md](./docs/replay.md) | [:h wezterm-types-plugin.replay.txt](./doc/wezterm-types-plugin.replay.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Freplay.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#replay)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Freplay-current.json%3Fv%3D1) |
| [wezterm-sessions](https://github.com/abidibo/wezterm-sessions) | [docs/wezterm-sessions.md](./docs/wezterm-sessions.md) | [:h wezterm-types-plugin.wezterm-sessions.txt](./doc/wezterm-types-plugin.wezterm-sessions.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-sessions.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wezterm-sessions)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-sessions-current.json%3Fv%3D1) |
| [wezterm-status](https://github.com/yriveiro/wezterm-status) | [docs/wezterm-status.md](./docs/wezterm-status.md) | [:h wezterm-types-plugin.wezterm-status.txt](./doc/wezterm-types-plugin.wezterm-status.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-status.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wezterm-status)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-status-current.json%3Fv%3D1) |
| [wezterm-sync](https://github.com/dfsramos/wezterm-sync) | [docs/sync.md](./docs/sync.md) | [:h wezterm-types-plugin.sync.txt](./doc/wezterm-types-plugin.sync.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsync.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#sync)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fsync-current.json%3Fv%3D1) |
| [wezterm-tabs](https://github.com/yriveiro/wezterm-tabs) | [docs/wezterm-tabs.md](./docs/wezterm-tabs.md) | [:h wezterm-types-plugin.wezterm-tabs.txt](./doc/wezterm-types-plugin.wezterm-tabs.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-tabs.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wezterm-tabs)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-tabs-current.json%3Fv%3D1) |
| [wezterm-theme-rotator](https://github.com/koh-sh/wezterm-theme-rotator) | [docs/wezterm-theme-rotator.md](./docs/wezterm-theme-rotator.md) | [:h wezterm-types-plugin.wezterm-theme-rotator.txt](./doc/wezterm-types-plugin.wezterm-theme-rotator.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-theme-rotator.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wezterm-theme-rotator)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwezterm-theme-rotator-current.json%3Fv%3D1) |
| [widgets.wez](https://github.com/usrivastava92/widgets.wez) | [docs/widgets.md](./docs/widgets.md) | [:h wezterm-types-plugin.widgets.txt](./doc/wezterm-types-plugin.widgets.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwidgets.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#widgets)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwidgets-current.json%3Fv%3D1) |
| [workspace-picker.wezterm](https://github.com/isseii10/workspace-picker.wezterm) | [docs/workspace-picker.md](./docs/workspace-picker.md) | [:h wezterm-types-plugin.workspace-picker.txt](./doc/wezterm-types-plugin.workspace-picker.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fworkspace-picker.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#workspace-picker)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fworkspace-picker-current.json%3Fv%3D1) |
| [workspacesionizer.wezterm](https://github.com/vieitesss/workspacesionizer.wezterm) | [docs/workspacesionizer.md](./docs/workspacesionizer.md) | [:h wezterm-types-plugin.workspacesionizer.txt](./doc/wezterm-types-plugin.workspacesionizer.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fworkspacesionizer.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#workspacesionizer)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fworkspacesionizer-current.json%3Fv%3D1) |
| [wsinit.wezterm](https://github.com/JuanraCM/wsinit.wezterm) | [docs/wsinit.md](./docs/wsinit.md) | [:h wezterm-types-plugin.wsinit.txt](./doc/wezterm-types-plugin.wsinit.txt) | [![status](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwsinit.json)](https://lalvarezt.github.io/wezterm-types/plugin-maintenance/#wsinit)<br>![Current](https://img.shields.io/endpoint?url=https%3A%2F%2Flalvarezt.github.io%2Fwezterm-types%2Fplugin-maintenance%2Fbadges%2Fwsinit-current.json%3Fv%3D1) |
<!-- plugin-table:end -->

---

## Usage

After installing the types, add the type annotations to `wezterm` and `config` respectively
when running `require("wezterm")` in your configuration.

A useful example:

```lua
local wezterm = require("wezterm") ---@type Wezterm
local config = wezterm.config_builder() ---@type Config

config.window_decorations = "RESIZE|MACOS_FORCE_DISABLE_SHADOW"

return config
```

These annotations enable the **Lua Language Server** to provide proper type checking
and autocompletion for WezTerm configuration options.

### Using lazydev.nvim

Install [lazydev.nvim](https://github.com/folke/lazydev.nvim) as suggested:

```lua
{
  'folke/lazydev.nvim',
  ft = 'lua',
  dependencies = { 'DrKJeff16/wezterm-types' },
  opts = {
    library = {
      -- Other library configs...
      { path = 'wezterm-types', mods = { 'wezterm' } },
    },
  },
}
```

If you download this repo under a diferent name, you can use the following instead:

```lua
{
  'folke/lazydev.nvim',
  ft = 'lua',
  dependencies = {
    {
      'DrKJeff16/wezterm-types',
      name = '<my_custom_name>', -- CUSTOM DIRECTORY NAME
    },
  },
  opts = {
    library = {
      -- MAKE SURE TO MATCH THE PLUGIN DIRECTORY'S NAME
      { path = '<my_custom_name>', mods = { 'wezterm' } },
    },
  },
}
```

### Using The Built-in Neovim LSP

Add the install path of `wezterm-types` in your `lua_ls` config.

```lua
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      workspace = {
        library = {
          -- Other library paths...
          '</path/to/wezterm-types>',
        },
      },
    },
  },
}
```

---

<picture>
  <source
  media="(prefers-color-scheme: dark)"
  srcset="https://api.star-history.com/svg?repos=DrKJeff16/wezterm-types&type=date&theme=dark&legend=bottom-right"
  />
  <source
  media="(prefers-color-scheme: light)"
  srcset="https://api.star-history.com/svg?repos=DrKJeff16/wezterm-types&type=date&legend=bottom-right"
  />
  <img
  alt="Star History Chart"
  src="https://api.star-history.com/svg?repos=DrKJeff16/wezterm-types&type=date&legend=bottom-right"
  />
</picture>

<!-- vim: set ts=2 sts=2 sw=2 et ai si sta: -->
