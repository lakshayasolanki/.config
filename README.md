# .config

My macOS environment config. Allowlist-only: see `.gitignore`.

## Tools

| Use case | Tool | Folder |
|---|---|---|
| Tiling window manager | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `aerospace/` |
| Window borders | [JankyBorders](https://github.com/FelixKratz/JankyBorders) | `borders/` |
| Menu bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | `sketchybar/` |
| Shell prompt | [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (p10k) | `p10k/` |
| Smarter `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | none (no config) |

- `aerospace/`: config at `aerospace/aerospace.toml`, which AeroSpace reads natively
- `borders/`: JankyBorders helper script (the borders launch args live in the AeroSpace config)
- `sketchybar/`: menu bar config and plugins
- `p10k/`: prompt config at `p10k/p10k.zsh`. p10k expects `~/.p10k.zsh`, so symlink it:
  `ln -s ~/.config/p10k/p10k.zsh ~/.p10k.zsh`
- zoxide: nothing to track. Install it (`brew install zoxide`) and add this to `~/.zshrc`:
  `eval "$(zoxide init zsh)"`. Use `z foo` to jump, `zi` to pick interactively.

## Plan: one-command theme switch (todo)

Goal: change the wallpaper, re-theme the whole environment with one command.

1. **Generate colors** from the wallpaper with a palette tool (pywal, wallust, matugen or tinct).
2. **Render templates** for each app from that palette: Ghostty, SketchyBar, borders, and tmux or herdr.
3. **Reload everything** with a script: `cmd+shift+,` for Ghostty, `sketchybar --reload`, `borders ...`.

Prerequisite: move SketchyBar's hard-coded colors into a single `colors.sh` that every plugin reads.
