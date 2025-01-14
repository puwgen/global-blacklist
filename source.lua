-- https://github.com/puwgen
-- https://github.com/puwgen/global-blacklist

-- WARNING: HttpService must be enabled in order for this script to work

local Version_UpdateError = true -- Set to false if you want the script to not make an error when it's outdated
local GlobalBlacklist = {
	Sources = { }, -- Do not touch
	Manual = { Users = {}; Groups = {} }, -- Do not touch
	Whitelist = { Users = {}; Groups = {} }, -- Do not touch
}


local GroupService = game:GetService("GroupService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

assert(HttpService.HttpEnabled, 'You must enable HttpService for the script to work')
-- You are free to customize these functions!
-- Of course, if you know what you are doing


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

local function ArrayMerge(t1, t2)
	local res = t1
	for _, v in t2 do
		table.insert(res, v)
	end
	return res
end

local function CoreKick(player : Player, reason)
	player:Kick(string.format(
		"\n\nYou are not allowed to join the experience\nReason: %s\n\n",
		reason
	))
end

local function ScanUser(id : number)
	local r = "innocent"
	local ingameInstance = Players:GetPlayerByUserId(id)
	
	local function TerminateSession()
		Players:BanAsync({
			UserIds = { id },
			Duration = -1,
			DisplayReason = 'Account involved in Terms of Service violation',
			PrivateReason = "UserBlacklisted"
		})
	end
	for i, source in GlobalBlacklist.Sources do
		if r ~= "innocent" then
			return r
		end
		local success, returned = pcall(function()
			local groups = {}
			for _,v in GroupService:GetGroupsAsync(source) do table.insert(groups, v.Id) end
			for _,v in GlobalBlacklist.Manual.Groups do table.insert(groups, v) end
			local followings = {}
			if table.find(GlobalBlacklist.Manual.Users, id) then
				task.spawn(TerminateSession)
				return r
			end
			
			do
				local followersPage = 100
				local followersLastPage = nil
				local followersNextPage = nil
				local followerCount = HttpService:JSONDecode(HttpService:GetAsync(string.format('https://friends.roproxy.com/v1/users/%d/followers/count',source))).count
				
				local iterations = math.clamp(math.floor(followerCount / followersPage), 1, math.huge)
				for i = 1, iterations do
					local url = ('https://friends.roproxy.com/v1/users/%d/followings?limit=%d&sortOrder=asc%s')
					local urlResult = string.format(url,
						source,
						followersPage,
						if followersNextPage then "&cursor="..followersNextPage else ""
					)
					local resultIteration = HttpService:JSONDecode(HttpService:GetAsync(urlResult))
					followersNextPage = resultIteration['nextPageCursor']
					for _, v in resultIteration['data'] do
						table.insert(followings, v.id)
						if id == v.id then
							TerminateSession()
							break
						end
					end
				end
			end
			
			for _, group in groups do
				local InGroup = ingameInstance:IsInGroup(group)
				local GroupInformation = GroupService:GetGroupInfoAsync(group)
				if InGroup and
					not table.find(GlobalBlacklist.Whitelist.Users, id) and 
					not table.find(GlobalBlacklist.Whitelist.Groups, group) and 
					not table.find(GlobalBlacklist.Sources, id) 
				then
					-- PLAYER IS INSIDE A TOS VIOLATING GROUP!!!!
					r="violation_group"
					if ingameInstance then
						CoreKick(ingameInstance, string.format(
							"Member of a Terms Of Service violating group.\nGroup ID: %d\nGroup Name: %s",
							group,
							GroupInformation.Name
						))
					end
					break
				end
			end
		end)
		if not success then
			warn(string.format("An error occured with source %d. Skipping", source))
			warn(returned)
		end
		
	end
	return r
end


CheckScriptVersion()
ApplyChanges()
if RunService:IsStudio() then
	for i,v in Players:GetPlayers() do
		task.spawn(ScanUser,v.UserId)
	end
end
Players.PlayerAdded:Connect(function(player)
	ScanUser(player.UserId)
end)
