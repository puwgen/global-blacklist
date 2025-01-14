-- https://github.com/puwgen
-- https://github.com/puwgen/global-blacklist

-- WARNING: HttpService must be enabled in order for this script to work
local GlobalBlacklist = {
	Sources = { }, -- Do not touch
	Manual = { }, -- Do not touch
	Whitelist = { }, -- Do not touch
}


local GroupService = game:GetService("GroupService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

assert(HttpService.HttpEnabled, 'You must enable HttpService for the script to work')
print("running")
-- You are free to customize these functions!
-- Of course, if you know what you are doing

local Callbacks = { }

local Version_UpdateError = true -- Set to false if you want the script to not make an error when it's outdated
local Version_Current = "1.0.0" -- This must not be touched

local function ApplyChanges()
	-- This script automatically collects info from the github repository
	-- Using this, You won't have to constantly update the code that you have
	-- Makes request to site, collects info and replaces
	local BlacklistOffsite = HttpService:JSONDecode(HttpService:GetAsync('https://raw.githubusercontent.com/puwgen/global-blacklist/refs/heads/main/blacklist.json'))
	GlobalBlacklist.Sources = BlacklistOffsite.sources
	GlobalBlacklist.Manual = BlacklistOffsite.blacklist_v2
	GlobalBlacklist.Whitelist = BlacklistOffsite.whitelist
end

local function CheckScriptVersion()
	-- Validates the Script Version
	-- Makes an HTTP request to check if they match
	local Version_Updated = HttpService:GetAsync('https://raw.githubusercontent.com/puwgen/global-blacklist/refs/heads/main/version.json')
	local VersionMatching = HttpService:JSONDecode(Version_Updated).version == Version_Current
	if not VersionMatching then
		local Message = string.format(
			"\n\nYou are using an outdated version of the script.\n Newest version: %s. Script version: %s\n\nConsider updating the script: https://raw.githubusercontent.com/puwgen/global-blacklist/refs/heads/main/source.lua", 
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

local function ScanUser(id : number)
	local r = "innocent"
	for i, source in GlobalBlacklist.Sources do
		if r ~= "innocent" then
			break
		end
		print(source)
		local success, returned = pcall(function()
			local groups = GroupService:GetGroupsAsync(source)
			local followings = {}
			
		end)
		if not success then
			warn(string.format("An error occured with source %d. Skipping", source))
		end
		
	end
	return r
end


CheckScriptVersion()
ApplyChanges()
ScanUser(7856938931)
