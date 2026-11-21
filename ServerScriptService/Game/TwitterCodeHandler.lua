local Handler = {}

local SoundService =		game:GetService("SoundService")
local PhysicsService =		game:GetService("PhysicsService")
local ReplicatedStorage =	game:GetService("ReplicatedStorage")
local RunService = 			game:GetService("RunService")
local ServerStorage = 		game:GetService("ServerStorage")
local Players = 			game:GetService("Players")
local StarterPack = 		game:GetService("StarterPack")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = 	game:GetService("MarketplaceService")
local DataStoreService = 	game:GetService("DataStoreService")
local TeleportService = 	game:GetService("TeleportService")

local twitterCodesStore
local twitterCodesData

local GameSettings = {}
local DS_Settings = {}
local defaultTwitterCodesData

local deepCopy = require(ReplicatedStorage.Modules.DeepCopy)

local function DataStoreRetry(player, func, maxTries,x)
	for tries = 1, maxTries do
		if (player and player.Parent) or x then
			local success, receive = pcall(func)
			if success then
				return success, receive, tries
			else
				wait(10)
			end
		else
			return false, nil, tries
		end
	end
end

local function UpdateDataStore(first)
	--local success, response, tries = DataStoreRetry(
	--	nil,
	--	function() 
	--		return twitterCodesStore:GetAsync("TwitterCodes") 
	--	end,
	--	5,
	--	true
	--)

	--if success then
	--	twitterCodesData = response
	--else
	--	warn("TwitterCodeHandler: FAILED TO GET TWITTERCODESTORE DATA")
	--end

	--if success and (response == nil or typeof(response) ~= "table" or response.CurrentKey ~= DS_Settings.TwitterCodeKey)  then
	--	warn("TwitterCodeHandler: TWITTERCODESTORE DATA IS INVALID, SWITCHING TO DEFAULT")

		
		
	--	--if ServerStorage.Values.SaveData.Value then
	--	--	local success, response, tries = DataStoreRetry(
	--	--		nil,
	--	--		function() 
	--	--			return twitterCodesStore:SetAsync("TwitterCodes",twitterCodesData) 
	--	--		end,
	--	--		5,
	--	--		true
	--	--	)
			
	--	--	if success then
	--	--		warn("TwitterCodeHandler: Successfully overwrote to default TwitterCodeData")
	--	--	else
	--	--		warn("TwitterCodeHandler: FAILED TO OVERWRITE to default TwitterCodeData")
	--	--	end
	--	--end
	--end
	
	twitterCodesData = deepCopy(defaultTwitterCodesData)
end

function Handler:GetCode(code)
	code = tostring(code)
	
	for i,v in pairs(defaultTwitterCodesData.Codes) do
		if i == code then
			local hasExpired = os.time() - v.ExpireTick > 0
			return (not hasExpired and v.Rewards),hasExpired
		end
	end
end

function Handler.SetUp(gameSettings,dS_Settings)
	print("YUP TWITTER CODE HANDLER")
	
	DS_Settings = dS_Settings

	GameSettings = gameSettings
	
	twitterCodesStore = DataStoreService:GetDataStore(DS_Settings.MasterKey .. "." .. DS_Settings.TwitterCodeKey)
	
	defaultTwitterCodesData = require(ServerStorage.Modules.Other.DefaultTwitterCodesData)

	UpdateDataStore()
	
	--if ServerStorage.Values.SaveData.Value then
	--	while wait(60) do
	--		UpdateDataStore()
	--	end
	--end
end
	
return Handler
