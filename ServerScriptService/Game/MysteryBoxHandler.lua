local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local M = {}
	
math.randomseed(tick() / 3)

M.Config = {
	BoxSettings = {
		Uses = {3,6}; -- 3,7

		ItemDespawnTime = 15;

		LootPool = require(script.LootPoolM);
		LootOffset = require(ServerStorage.Modules.Other.GunModelOffsets);
		
		CooldownTime = 1;
		
		Price = 95000;
		
		ArmorItems = {
			--"__NecromancerKit";
		};
	};
}

local Events3 = ServerStorage.Events3
local MoneyEvent = Events3.nMonee

local PlayerbaseData,PlayerbaseData2

local function shuffleArray(arr)
	local arrCopy = {unpack(arr)} -- # making copy of arr

	for i = 1, #arr do
		arr[i] = table.remove(arrCopy, math.random(#arrCopy))
	end
	return arr -- # arr has been shuffled, return back for convenience
end

local function CheckBoxLegit(player,mainPart)
	--print(555)
	if ReplicatedStorage.Values.ShuttingDown.Value then return end
	--print(666)
	if M.spawnF and M.boxF and typeof(mainPart) == "Instance" and mainPart.Name == "MainPart" and mainPart.Parent.Parent == M.boxF then
		--print(777)
		local boxT = M.MysteryBoxM.ActiveBoxes[mainPart.Parent]
		if boxT and boxT.active then
			--print(888)
			
			if _G.CheckIfCan and not _G.CheckIfCan(player.Character,"Any") then return false,"YOU ARE TOO INJURED TO DO THIS RIGHT NOW" end
			--print(999)
			
			local mag = (mainPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if mag >= 10 then return end
			--print(1000)
			return boxT
		end
	end
end

local function AttemptBuy(player,mainPart)
	--print(444)
	local boxT = CheckBoxLegit(player,mainPart)
	--print(1111)
	if not boxT then return end
	--print(22222)
	if boxT.isOpen or boxT.busyV.Value then return end
	--print(3333)
	
	local pd = PlayerbaseData[player.Name]
	local cv = pd.Cash
	local bv = pd.Bank

	local COST = M.Config.BoxSettings.Price

	if cv.Value < COST then
		return false,"NOT ENOUGH CASH ($" .. tostring(COST) .. ")"
	end

	MoneyEvent:Fire("IU3898EJKLOY89TYZJDKLJGYI390WKHJSDHG9UKLJLEDGKLJERG9U",player,"Cash",-COST)
	
	coroutine.wrap(function()
		local open
		open = boxT:Open(player)
	end)()
	
	return true
end

local function AttemptTake(player,mainPart)
	local boxT = CheckBoxLegit(player,mainPart)
	--print(4444)
	if not boxT then return end
	
	--print(5555)
	
	if not boxT.isOpen or not boxT.canTakeItem then return end
	--print(6666)
	
	if boxT.openPlayer ~= player then return end
	
	--print(777)
	
	local take = boxT:TakeItem(player)
	
	return take
end

local function CheckIfSpawnFTaken(spawnF)
	for i,v in pairs(M.MysteryBoxM.ActiveBoxes) do
		if v.spawnFolder == spawnF then
			return true
		end
	end
	return false
end

M.SpawnBox = function(customSpawnF)
	if not M.MysteryBoxM.isSetUp then
		warn("MysteryBoxHandler: BoxM not set up")
		return
	end
	if not M.spawnF then
		warn("MysteryBoxHandler: no spawn folder")
		return
	end
	
	if #M.spawnF:GetChildren() <=0 then
		warn("MysteryBoxHandler: spawn folder EMPTY!")
		return
	end
	
	local chosenSpawnF
	
	if customSpawnF then
		if not CheckIfSpawnFTaken(customSpawnF) then
			chosenSpawnF = customSpawnF
		else
			warn("MysteryBoxHandler: customSpawnF is in use!")
		end
		
	else
		local list = M.spawnF:GetChildren()
		list = shuffleArray(list)
		
		for i,v in pairs(list) do
			if not CheckIfSpawnFTaken(v) then
				chosenSpawnF = v
			else
				--print("box is busy...")
			end	
		end
		
		if not chosenSpawnF then
			warn("MysteryBoxHandler: All Mystery Box spawns are taken rn!")
		end
	end
	
	if chosenSpawnF then
		local box = M.MysteryBoxM.new(chosenSpawnF)
		return box
	end
end

M.SetUp = function(gameSettings)
	if M.isSetUp then return end
	
	M.isSetUp = true
	
	M.MysteryBoxM = require(script.MysteryBoxM)
	
	M.MysteryBoxM.SetUp(M.Config.BoxSettings)
	
	spawn(function()
		PlayerbaseData,PlayerbaseData2 = ServerStorage:WaitForChild("PlayerbaseData",100),ReplicatedStorage:WaitForChild("PlayerbaseData2",100)
	end)
	
	spawn(function()
		M.spawnF = workspace:WaitForChild("Map",1000):WaitForChild("MysteryBoxSpawns",1000)
		M.boxF = workspace:WaitForChild("Map",1000):WaitForChild("MysteryBoxes",1000)
	end)
	
	ReplicatedStorage.Events.MysteryBoxU.OnServerInvoke = function(player,mode,...)
		if not M.spawnF or not M.boxF then
			return
		end
		
		--print(player,mode,...)
		
		if mode == "Buy" then
			return AttemptBuy(player,...)
		elseif mode == "Take" then
			return AttemptTake(player,...)
		end
	end
	
	ServerStorage.Events3.MysteryBox_ClearAll.Event:Connect(function(explode)
		for i,v in pairs(M.MysteryBoxM.ActiveBoxes) do
			if v and not v.destroyed then
				spawn(function()
					v:Destroy(explode)
				end)
			end
		end
	end)
	
	ServerStorage.Events3.MysteryBox_Spawn.Event:Connect(function(c)
		if c ~= "JO43T0943-09IKOR" then
			return 
		end
	
		M.SpawnBox()
	end)
	
	--print("set up")
end


return M