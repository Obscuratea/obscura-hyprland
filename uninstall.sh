#!/usr/bin/env bash
# Restore the files saved by the most recent ./install.sh
set -euo pipefail
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
bak="${XDG_DATA_HOME:-$HOME/.local/share}/obscura-hyprland/latest"
[ -d "$bak" ] || { echo "no backup found"; exit 1; }
state="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml"
[ -f "$bak/noctalia-state/settings.toml" ] && cp -a "$bak/noctalia-state/settings.toml" "$state"
rm -rf "$bak/noctalia-state.restored"; cp -a "$bak"/. "$cfg"/; rm -rf "$cfg/noctalia-state"
rm -f "$cfg/hypr/config/obscura.lua" "$cfg/hypr/noctalia.lua" "$cfg/alacritty/obscura.toml"
hyprctl reload >/dev/null 2>&1 || true
echo "restored from $(readlink -f "$bak")"
