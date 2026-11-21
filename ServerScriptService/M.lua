local M = {}

local REPLICATED_STORAGE =	game:GetService("ReplicatedStorage")
local PLAYERS = 			game:GetService("Players")
local ServerStorage = 		game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--REPLICATED_STORAGE:WaitForChild("GameLoaded",100)

local BS =	require(script:WaitForChild("BS"))
local AC = nil

if ServerStorage:FindFirstChild("_MainG") or ServerStorage:GetAttribute("_MainG") == true then
	AC = require(script:WaitForChild("AC"))
end

local CLH =	require(script:WaitForChild("CLH"))

local repr = require(ServerScriptService.repr)
local modSettings = require(script.MSettings)

M.CheckPlayer = function(player,isAMod,checkAltThing)
	local isMenuPlace = ServerStorage:FindFirstChild("IsMenuPlace")
	
	if not isMenuPlace then -- can only run in the menu place
		return true,nil
	end

	local banObject = BS.new(player.UserId)
	--banObject:Ban(player.Name, "Reason", 100)

	local isBanned,banData,banType,modHistory,nBanData,isAltRestricted = banObject:CheckIfBanned(nil,nil,true)
	local silent
	
	if isBanned then
		silent = false
		if banData.Type == "shadow" then
			silent = true
		elseif banType == "anti" and banData.ShadowTime and banData.BanStartTime + banData.ShadowTime > os.time() then
			silent = true
		elseif banType == "timeout" then
			--silent = true
		end

		warn(player.Name .. " is banned",banType,silent)

		if modSettings.KickBanned then
			if not silent then
				player:Kick(banObject:GetBanMessage(banData,banType))
			else
				delay(math.random(120,500),function()
					player:Kick("Out of sync.")
				end)
			end
		end
	else
		--local gr = nil

		--for _,v in pairs(BS.BlacklistedGroups) do
		--	local ing
		--	pcall(function()
		--		ing = player:IsInGroup(v)
		--	end)

		--	if ing then
		--		gr = v
		--		break
		--	end
		--end

		--if gr then
		--	isBanned = true

		--	player:Kick("Found in exploiter group with id: " .. tostring(gr))
		--end

		if isAltRestricted and not isAMod and checkAltThing then
			player:Kick(banObject:GetBanMessage(banData,"altrestrict"))
			return false,{}
		end
	end

	banObject:Destroy()

	--delay(math.random(50,300),function()
	--	--kick
	--end)

	return not isBanned,nBanData--,silent
end

M.MonitorPlayer = function(player)

end

M.__newindex = function() : nil
	error("Can't change protected table.");
end
M.__index = M;

M.__call = function() : string
	return "Version: 0.0.0";
end
M.__tostring = function(object: any) : string
	local result: string = "";

	for key: string, value: any in pairs(object) do
		result = result .. "Key: " .. tostring(key) .. " - Value: " .. tostring(value) .. " \n";
	end

	return result;
end
M.__concat = function(object1: any, object2: any) : string
	return tostring(object1) .. tostring(object2);
end

M.SetUp = function()
	BS.SetUp()
	if AC then
		wait()
		AC.SetUp()
	end
end

return M