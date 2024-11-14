-- This script dynamically sets the MPV background color based on the system's color scheme

---@class Options
---@field dark_bg string
---@field light_bg string
---@field timer number
local opts = {
	dark_bg = "#000000",
	-- Any valid #rrggbb value

	light_bg = "#FFFFFF",
	-- Any valid #rrggbb value

	timer = 5
	-- Time Interval for each refresh (need to change this)
}
require("mp.options").read_options(opts)



---@alias Scheme
---| 'light'    # Light theme mode
---| 'dark'     # Dark theme mode

---@alias OS
---| 'windows'
---| 'macos'
---| 'linux'

--- Gets the system color scheme (light or dark) using lua ffi
---
--- @return Scheme|nil # The system color scheme ('light' or 'dark')
local function get_system_color_scheme()
	local ffi = require("ffi")
	---@type OS
	local os = ffi.os:lower()

	if os == 'windows' then
		ffi.cdef [[
			typedef void *HKEY;
			typedef unsigned long DWORD;
			typedef long LSTATUS;
			typedef const char *LPCSTR;
			typedef DWORD *LPDWORD;

			LSTATUS RegOpenKeyExA(
				HKEY hKey,
				LPCSTR lpSubKey,
				DWORD ulOptions,
				DWORD samDesired,
				HKEY* phkResult
			);

			LSTATUS RegQueryValueExA(
				HKEY hKey,
				LPCSTR lpValueName,
				void* lpReserved,
				LPDWORD lpType,
				void* lpData,
				LPDWORD lpcbData
			);

			LSTATUS RegCloseKey(HKEY hKey);
		]]

		local HKEY_CURRENT_USER = ffi.cast("void*", 0x80000001)
		local KEY_READ = 0x20019
		local REG_DWORD = 4

		local hKey = ffi.new("void*[1]")
		local status = ffi.C.RegOpenKeyExA(
			HKEY_CURRENT_USER,
			"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
			0,
			KEY_READ,
			hKey
		)

		-- fuck my stupid moe life
		if status == 0 then
			local type = ffi.new("DWORD[1]")
			local data = ffi.new("DWORD[1]")
			local dataSize = ffi.new("DWORD[1]", ffi.sizeof(data))

			status = ffi.C.RegQueryValueExA(
				hKey[0],
				"AppsUseLightTheme",
				nil,
				type,
				data,
				dataSize
			)

			ffi.C.RegCloseKey(hKey[0])

			if status == 0 and type[0] == REG_DWORD then
				if data[0] == 0 then
					return 'dark'
				else
					return 'light'
				end
			end
		end

		-- Return nil if registry access fails
		return nil
	elseif os == 'macos' then
		ffi.cdef [[
			typedef void* id;
			id objc_getClass(const char *name);
			id objc_msgSend(id self, const char *op, ...);
		]]

		local NSUserDefaults = ffi.C.objc_getClass("NSUserDefaults")
		local standardUserDefaults = ffi.C.objc_msgSend(NSUserDefaults, "standardUserDefaults")
		local value = ffi.C.objc_msgSend(
			standardUserDefaults,
			"stringForKey:",
			"AppleInterfaceStyle"
		)

		if value == nil then
			return 'light'
		else
			return 'dark'
		end
	elseif os == 'linux' then
		-- TODO: Implement linux
		return 'dark'
		-- error("Not yet implemented") -- disabling so that shit doesnt break completely on linux
	else
		return nil -- smth fucked up
	end
end

--- Sets the background color of MPV based on the provided [Scheme](lua://Scheme)
---
--- @param scheme Scheme The color scheme to use
local function set_background_color(scheme)
	if scheme == 'light' then
		mp.set_property("background-color", opts.light_bg)
	else
		mp.set_property("background-color", opts.dark_bg)
	end
end




-- TODO: Change this part to listen for system theme change events and use that to change the theme, not just continously check if the themes changed
mp.add_periodic_timer(opts.timer, function()
	local scheme = get_system_color_scheme()
	if scheme == nil then
		error('smth went wrong fr received nil')
	end
	set_background_color(scheme)

	-- -- Debug only
	-- print("---------")
	-- print("OS:" .. require("ffi").os:lower())
	-- print("Scheme:" .. get_system_color_scheme())
	-- print("---------")
end)
