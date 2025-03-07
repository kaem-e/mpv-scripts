-- Cycle between 1x speed and a secondary speed
-- The speed you set is determined by
local mp = require("mp")
local mp_options = require("mp.options")

---@class Options
---@field speed number The custom playback speed.
---@field key string The key to toggle between speeds.
---@field show_osd boolean Whether to display OSD messages.
local opts = {
  speed = 2.0, -- Any valid number
  key = "r", -- Any valid keybinding
  show_osd = true, -- Whether to show a message on the OSD
}

mp_options.read_options(opts, mp.get_script_name())

local function toggle_speed()
  local current_speed = mp.get_property_number("speed") or 1.0

  -- Toggle between 1.0 and opts.speed
  local new_speed = (current_speed == 1.0) and opts.speed or 1.0

  mp.set_property_number("speed", new_speed)

  if opts.show_osd then
    mp.osd_message("Speed: " .. new_speed)
  end
end

if opts.key then
  mp.add_key_binding(opts.key, "toggle_speed", toggle_speed)
end
