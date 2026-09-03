-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                         Variables                             ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- These are module-level values returned as a table so config files

local M = {
	mainMod = "SUPER",
	terminal = "kitty",
	fileManager = "thunar",
	menu = "rofi -show drun",
	browser = "zen-browser",
	editor = "codium --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland",
	scrPath = os.getenv("HOME") .. "/.config/hypr/scripts",
}

return M
