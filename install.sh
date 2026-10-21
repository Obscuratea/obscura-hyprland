#!/usr/bin/env bash
# Obscura for Hyprland + Noctalia. Backs up what it touches, then applies. Undo with ./uninstall.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d-%H%M%S)"
bak="${XDG_DATA_HOME:-$HOME/.local/share}/obscura-hyprland/backup-$stamp"
mkdir -p "$bak"

save() { [ -e "$1" ] && mkdir -p "$bak/$(dirname "${1#$cfg/}")" && cp -a "$1" "$bak/${1#$cfg/}" || true; }
for f in hypr/hyprland.lua alacritty/alacritty.toml noctalia/config.toml; do save "$cfg/$f"; done
state="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml"
[ -f "$state" ] && { mkdir -p "$bak/noctalia-state"; cp -a "$state" "$bak/noctalia-state/"; }
echo "backup: $bak"
ln -sfn "$bak" "$(dirname "$bak")/latest"

echo "fonts"; bash "$here/tools/install-fonts.sh"

echo "hyprland"
install -Dm644 "$here/hypr/obscura.lua" "$cfg/hypr/config/obscura.lua"
grep -qF 'config.obscura' "$cfg/hypr/hyprland.lua" ||
    sed -i '/require("config.workspaces")/a require("config.obscura") -- Obscura: loads last so it overrides decorations' "$cfg/hypr/hyprland.lua"

echo "alacritty"
install -Dm644 "$here/alacritty/obscura.toml" "$cfg/alacritty/obscura.toml"
python3 - "$cfg/alacritty/alacritty.toml" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p).read()
# the main file wins over imports, so drop its hard-coded colors, font and opacity
s = re.sub(r'(?ms)^\[(colors(\.[a-z_.]+)?|font)\]\n.*?(?=^\[|\Z)', '', s)
s = re.sub(r'(?m)^opacity = .*\n', '', s)
if 'obscura.toml' not in s:
    s = re.sub(r'(?m)^import = \[(.*?)\]', lambda m: 'import = [%s, "~/.config/alacritty/obscura.toml"]' % m.group(1).strip(), s, count=1)
open(p, 'w').write(s)
PY

echo "noctalia"
python3 - "$cfg/noctalia/config.toml" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p).read()
if '"hyprland"' not in s:
    s = s.replace('builtin_ids = [ ', 'builtin_ids = [ "hyprland", ', 1)
s = re.sub(r'(radius_(?:top|bottom)_(?:left|right) = )\d+', r'\g<1>0', s)
open(p, 'w').write(s)
PY
# the GUI-managed state file overrides config.toml, so enable the template there too
[ -f "$state" ] && ! grep -q '"hyprland"' "$state" && sed -i 's/builtin_ids = \[ /builtin_ids = [ "hyprland", /' "$state"
noctalia msg config-reload >/dev/null 2>&1 || true
noctalia msg templates-apply >/dev/null 2>&1 || true
hyprctl reload >/dev/null 2>&1 || true
echo "done. Change wallpaper in Noctalia to recolor everything."
