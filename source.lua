local HttpService = game:GetService("HttpService")
assert(HttpService.HttpEnabled, 'You must enable HttpService for the script to work')

local Version_UpdateError = true
local Version_Current = "1.5.0"
local function CheckScriptVersion()
	local Version_Updated = HttpService:GetAsync('https://raw.githubusercontent.com/puwgen/global-blacklist/refs/heads/main/version.json')
	local VersionMatching = HttpService:JSONDecode(Version_Updated).version == Version_Current
	if not VersionMatching then
		local Message = string.format(
			"\nYou are using an outdated version of the script.\n Newest version: %s. Script version: %s\n\nConsider updating the script: https://raw.githubusercontent.com/puwgen/global-blacklist/refs/heads/main/source.lua", 
			HttpService:JSONDecode(Version_Updated).version, 
			Version_Current
		)
		if Version_UpdateError then
			error(Message)
		else
			warn(Message)
		end
	end
end

CheckScriptVersion()
