-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                        Decorations                            ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("config/colors")

-- ── General & Decoration ────────────────────────────────────────
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 7,

		border_size = 2,

		col = {
			active_border = colors.accent,
			inactive_border = 0x00000000,
		},

		resize_on_border = false,
		allow_tearing = false, -- see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
		layout = "scrolling",
	},

	dwindle = {
		preserve_split = true,
	},

	-- ── Master layout ────────────────────────────────────────────
	-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
	master = {
		new_status = "slave",
	},

	-- ── Scroll layout ────────────────────────────────────────────
	-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
	scrolling = {
		fullscreen_on_one_column = true,
		direction = "right",
		column_width = 0.5,
	},

	decoration = {
		rounding = 10,
		rounding_power = 4,

		active_opacity = 1.0,
		inactive_opacity = 0.8,

		shadow = {
			enabled = false,
			range = 7,
			render_power = 2,
			color = colors.background,
		},

		blur = {
			enabled = true,
			size = 7,
			passes = 2,
			vibrancy = 0.1696,
		},
	},

	-- ── Misc ─────────────────────────────────────────────────────
	misc = {
		force_default_wallpaper = -1, -- -1 keeps the default; 0/1 disables
		disable_hyprland_logo = false,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})

-- ── Animations ──────────────────────────────────────────────────
-- Based on end-4/dots-hyprland  https://github.com/end-4/dots-hyprland
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.config({ animations = { enabled = true } })

-- Bezier curves
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("crazyshot", { type = "bezier", points = { { 0.1, 1.5 }, { 0.76, 0.92 } } })
hl.curve("hyprnostretch", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("menu_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("menu_accel", { type = "bezier", points = { { 0.38, 0.04 }, { 1, 0.07 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("softAcDecel", { type = "bezier", points = { { 0.26, 0.26 }, { 0.15, 1 } } })
hl.curve("md2", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } }) -- use with 0.2 s duration

-- Animation config
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "md3_decel" })
-- hl.animation({ leaf = "layers",        enabled = true, speed = 2,   bezier = "md3_decel",  style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.6, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 4.5, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slide" })
-- hl.animation({ leaf = "workspaces",   enabled = true, speed = 2.5, bezier = "softAcDecel", style = "slide" })
-- hl.animation({ leaf = "workspaces",   enabled = true, speed = 7,   bezier = "menu_decel",  style = "slidefade 15%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidefadevert 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidevert" })

-- ── Smart gaps (no gaps with a single window) ── uncomment to use
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]"   }, border_size = 0, rounding = 0 })
