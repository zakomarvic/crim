

local config = {
	Blackouts = {
		Enabled = false;
		StandardOnly = false;

		Chance = 33333;

		LastTime = {400;700};
		CooldownTime = {3600,7200};
	};

	MysteryBoxes = {
		Enabled = true;
		StandardOnly = false;
		BlackoutSpawnAll = true;
		
		MinSpawnPerc = 0.66; --0.6
		
		GamemodeChanceMultis = {
			["Casual"] = 2;
			["M-Casual"] = 2;
		};
		GamemodeCooldownTimeMultis = {
			["Casual"] = 2;
			["M-Casual"] = 2;
		};

		Chance = 500; -- 5000
		
		CooldownTime = {3600,7200};
	};
	
	SupplyDrops = {
		Enabled = true;
		StandardOnly = false;
		
		MinSpawnPerc = 0.5; --0.66
		
		Chance = 600;
		
		GamemodeChanceMultis = {
			["Casual"] = 1;
			["M-Casual"] = 1;
		};
		GamemodeCooldownTimeMultis = {
			["Casual"] = 1;
			["M-Casual"] = 1;
		};

		CooldownTime = {700,1350}; -- 1400,2700
		
		SkipWithCooldowns = {
			--"blackout";
		};
		SkipDuringBlackouts = false;
		
		ExplodeChance = 4;
	};
	
	IgnoreMinSpawnPerc_Studio = true;
}

local M = {}


local rs = game:GetService("RunService")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local l = game.Lighting
local sL_Folder = workspace:WaitForChild("Map",1000):WaitForChild("StreetLights")

local valuesF = ReplicatedStorage.Values

local cooldowns = {blackout = false}

local lastBlackout = time()
local lastMysteryBox = time()
local lastSupplyDrop = time()

local function Update()
	if ServerStorage.Values.DisableRandomEvents.Value then
		return
	end
	
	local MPLAYERS = (ServerStorage.Values:FindFirstChild("MaxPlayers") and ServerStorage.Values.MaxPlayers.Value) or game.Players.MaxPlayers
	
	local PLAYER_COUNT = #game.Players:GetPlayers()
	local c = PLAYER_COUNT / MPLAYERS
	
	--if rs:IsStudio() and config.IgnoreMinSpawnPerc_Studio then
		c = 1
	--end
	
	if config.Blackouts.Enabled and not (config.Blackouts.StandardOnly and not string.find(string.lower(ReplicatedStorage.Values.GameMode.Value),"standard")) then
		if not cooldowns.blackout and not (config.Blackouts.MinSpawnPerc and c < config.Blackouts.MinSpawnPerc) then
			local c = math.random(1,config.Blackouts.Chance)
			--print("BL",c,config.Blackouts.Chance)
			if c == 1 then
				warn("STARTING BLACKOUT")
				warn("LAST BLACKOUT:", time() - lastBlackout)
				lastBlackout = time()
				
				cooldowns.blackout = true
				M.BlackoutM.Toggle(true,true)
				local lastTime = math.random(config.Blackouts.LastTime[1],config.Blackouts.LastTime[2])
				delay(lastTime,function()
					warn("ENDING BLACKOUT")
					M.BlackoutM.Toggle(false,true)
					
					wait(math.random(config.Blackouts.CooldownTime[1],config.Blackouts.CooldownTime[2]))
					
					warn("BLACKOUT COOLDOWN ENDED")
					
					cooldowns.blackout = false
				end)
			end
		end
	end
	
	if config.MysteryBoxes.Enabled and not (config.MysteryBoxes.StandardOnly and not string.find(string.lower(ReplicatedStorage.Values.GameMode.Value),"standard")) then
		if not cooldowns.mysterybox and not (config.MysteryBoxes.MinSpawnPerc and c < config.MysteryBoxes.MinSpawnPerc) then
			local chance = config.MysteryBoxes.Chance
			if config.MysteryBoxes.GamemodeChanceMultis and config.MysteryBoxes.GamemodeChanceMultis[ReplicatedStorage.Values.GameMode.Value] then
				chance *= config.MysteryBoxes.GamemodeChanceMultis[ReplicatedStorage.Values.GameMode.Value]
				chance = math.round(chance)
			end
			
			local c = math.random(1,chance)
			--print("MY",c,config.MysteryBoxes.Chance)
			if c == 1 then
				warn("STARTING MYSTERYBOX")
				warn("LAST MYSTERYBOX:", time() - lastMysteryBox)
				lastMysteryBox = time()

				cooldowns.mysterybox = true
				local box = M.MysteryBoxHandlerM.SpawnBox()
				
				local event = box.destroyedEvent
				
				delay(0,function()
					event.Event:Wait()
					
					local multi = 1
					if config.MysteryBoxes.GamemodeCooldownTimeMultis and config.MysteryBoxes.GamemodeCooldownTimeMultis[ReplicatedStorage.Values.GameMode.Value] then
						multi = config.MysteryBoxes.GamemodeCooldownTimeMultis[ReplicatedStorage.Values.GameMode.Value]
					end
					
					local t = math.random(config.MysteryBoxes.CooldownTime[1],config.MysteryBoxes.CooldownTime[2]) 
					t *= multi
					
					wait(t)
					cooldowns.mysterybox = false
				end)
			end
		end
	end
	
	if config.SupplyDrops.Enabled and not (config.SupplyDrops.StandardOnly and not string.find(string.lower(ReplicatedStorage.Values.GameMode.Value),"standard")) then
		local skip = false
		if config.SupplyDrops.SkipWithCooldowns then
			for i,v in pairs(config.SupplyDrops.SkipWithCooldowns) do
				if cooldowns[v] == true then
					skip = true
					break
				end
			end
		end
		if config.SupplyDrops.SkipDuringBlackouts and ReplicatedStorage.Values.LOutage.Value then
			skip = true
		end
		
		if not skip and not cooldowns.supplydrop and not (config.SupplyDrops.MinSpawnPerc and c < config.SupplyDrops.MinSpawnPerc) then
			
			local chance = config.SupplyDrops.Chance
			
			if config.SupplyDrops.GamemodeChanceMultis and config.SupplyDrops.GamemodeChanceMultis[ReplicatedStorage.Values.GameMode.Value] then
				chance *= config.SupplyDrops.GamemodeChanceMultis[ReplicatedStorage.Values.GameMode.Value]
				chance = math.round(chance)
			end
			
			local c = math.random(1,chance)
			--print("SU",c,config.SupplyDrops.Chance)
			if c == 1 then
				warn("STARTING SUPPLYDROP")
				warn("LAST SUPPLYDROP:", time() - lastSupplyDrop)
				lastSupplyDrop = time()

				cooldowns.supplydrop = true
				local drop = M.SupplyDropHandlerM.SupplyDropMain(math.random(1,config.SupplyDrops.ExplodeChance) == 1)

				delay(0,function()
					
					local multi = 1
					if config.SupplyDrops.GamemodeCooldownTimeMultis and config.SupplyDrops.GamemodeCooldownTimeMultis[ReplicatedStorage.Values.GameMode.Value] then
						multi = config.SupplyDrops.GamemodeCooldownTimeMultis[ReplicatedStorage.Values.GameMode.Value]
					end

					local t = math.random(config.SupplyDrops.CooldownTime[1],config.SupplyDrops.CooldownTime[2]) 
					t *= multi
					
					wait(t)
					
					cooldowns.supplydrop = false
				end)
			end
		end
	end
end

M.MainLoop = function()
	Update()
	--
end

M.SetUp = function(gameSettings)
	if M.isSetUp then return end
	M.isSetUp = true
	
	M.Config = config
	
	M.BlackoutM = require(ServerScriptService.Blackout)
	M.MysteryBoxHandlerM = require(ServerScriptService.Game.MysteryBoxHandler)
	M.SupplyDropHandlerM = require(ServerScriptService.Game.SupplyDropHandler)
	
	M.MysteryBoxHandlerM.SetUp(gameSettings)
	M.SupplyDropHandlerM.SetUp(gameSettings)
end

return M