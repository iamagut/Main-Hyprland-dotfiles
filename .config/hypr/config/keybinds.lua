-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                         Keybinds                              ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

-- Import variables (Hyprland scopes each file separately)
local v = require("config.variables")
local mainMod = v.mainMod
local terminal = v.terminal
local fileManager = v.fileManager
local browser = v.browser
local editor = v.editor
local scrPath = v.scrPath
local home = os.getenv("HOME")

-- ── Application launchers ────────────────────────────────────────
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wlogout.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(home .. "/.local/bin/wallpaper-picker.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + U", hl.dsp.window.pseudo()) -- dwindle pseudo-tile
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- ── Notifications / bars ─────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/waybar.sh"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/layouts.sh"))

-- ── Clipboard / screenshot / colour picker ───────────────────────
hl.bind(mainMod .. " + CTRL + ALT + V", hl.dsp.exec_cmd("cliphist wipe"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename - --copy-command wl-copy'))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -an"))

-- ── Rofi & utility scripts ───────────────────────────────────────
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh d"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh w"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh f"))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/emoji-picker.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh c"))

-- ── Focus (arrow keys) ───────────────────────────────────────────
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- ── Move active window ───────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- ── Cycle through windows
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top (only for floating windows)
end)

-- ── Resize (keyboard) ────────────────────────────────────────────
hl.bind("ALT + R", hl.dsp.submap("resize"))

-- Start a submap called "resize".
hl.define_submap("resize", function()
	-- Set repeating binds for resizing the active window.
	hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })

	-- Use `reset` to go back to the global submap
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- ── Workspaces ───────────────────────────────────────────────────
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- ── Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ── Move/resize with mouse drag ──────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- ── Groups ───────────────────────────────────────────────────────
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
-- NOTE: ALT+Tab was bound to both cyclenext and changegroupactive in the
-- original conf — pick one and remove the other.
hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprctl dispatch changegroupactive"))
-- hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))

-- ── Media / volume / brightness ──────────────────────────────────
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- ── Requires playerctl ───────────────────────────────────────────
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ── Layout Switching ─────────────────────────────────────────────
hl.bind(mainMod .. " + Y", function()
	local layouts = { "scrolling", "dwindle", "master" }
	local workspace = hl.get_active_workspace()
	if hl.get_active_special_workspace() then
		workspace = hl.get_active_special_workspace()
	end

	local next_layout = "dwindle"

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	if workspace.special then
		hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
	else
		hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
	end
end)
