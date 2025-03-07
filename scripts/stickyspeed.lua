-- Cycle between 1x speed and your currently set speed,

-- This is mostly intended to replicate my setup with Video Speed Controller,
-- mpv's own `r cycle-values speed "2.0" "1.0"` command didnt really function the same way
-- it just cycled between 1x and 2x. a speed faster than or slower than 2x would not be remembered

local mp = require("mp")
local mp_options = require("mp.options")

---@class Options
---@field speed number The custom playback speed.
---@field key string The key to toggle between speeds.
---@field show_osd boolean Whether to display OSD messages.
local opts = {
	speed = 2.0,   -- Any valid number
	key = "r",     -- Any valid keybinding
	show_osd = true, -- Whether to show a message on the OSD
}

mp_options.read_options(opts, mp.get_script_name())

local function toggle_speed()
	local current_speed = mp.get_property_number("speed") or 1.0

	local new_speed = (current_speed == 1.0) and opts.speed or 1.0

	mp.set_property_number("speed", new_speed)

	if opts.show_osd then
		mp.osd_message("Speed: " .. new_speed)
	end
end

if opts.key then
	mp.add_key_binding(opts.key, "toggle_speed", toggle_speed)
end
