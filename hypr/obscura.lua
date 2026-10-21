-- Obscura: sharp corners, flat surfaces, hairline borders.
-- Colors are NOT set here: Noctalia's hyprland template (noctalia.lua) paints the
-- borders from the current wallpaper, so everything follows when the wallpaper changes.

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        dim_special = 0.3,
        blur = { enabled = false },
        shadow = { enabled = false },
    },
})
