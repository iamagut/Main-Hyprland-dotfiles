-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                           Monitor                             ║
-- ╚═══════════════════════════════════════════════════════════════╝
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60.00",
	position = "0x0",
	scale = 1.25,
})

for i = 1, 5 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", persistent = true })
end
