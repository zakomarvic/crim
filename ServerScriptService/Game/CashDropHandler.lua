local M = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = 	game:GetService("ServerStorage")

local addComas = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("AddComas"))

local cashSpawnDir = workspace.Filter.SpawnedBread
local cashStuffDir = ServerStorage.Storage.CashStuff

local PlayerbaseData = ServerStorage:WaitForChild("PlayerbaseData")

local modulesDir = ReplicatedStorage.Modules
local eventsDir = ReplicatedStorage.Events
local eventsDir3 = ServerStorage.Events3

local pickupEvent = eventsDir.CZDPZUS
local dropEvent = eventsDir.DCZSH

local drop_sEvent = eventsDir3.D_CSH
local drop_sEvent2 = eventsDir3.D_CSH2
local monitor_sEvent = eventsDir3.M_CSH

wait(5)

local GameSettings
local config
	--= _G.GameSettings

local dropData = {}
local coolDowns = {}
local spams = {}

local deepCopy = require(modulesDir.DeepCopy)

local oDD = {
	LastTick = 0;
	DropAmount = 0;
	Code = 0;
}


function MonitorCash(cash,value,despawnTime)
	delay(despawnTime or 60,function()
		if cash.Parent then
			cash:Destroy()
		end
	end)
	
	value = math.floor(value)
	
	local val = Instance.new("IntConstrainedValue")
	val.Name = "Value"
	val.MaxValue = 9999999
	val.Value = value
	
	cash.A.GUI.TextLabel.Text = "$" .. addComas(value/100)
	
	val.Parent = cash
end

function SpawnCash(code,cf,typ,value,despawnTime,isFromLooting)
	if code ~= "8DR002" then
		return
	end
	
	local cash = cashStuffDir["CashDrop" .. typ]:Clone()
	cash.CFrame = cf
	if ReplicatedStorage.Values.LOutage.Value then
		local pl = cash.A:FindFirstChildOfClass("PointLight")
		if pl then
			pl.Enabled = false
		end
	end
	
	if isFromLooting then
		cash:SetAttribute("LC",true)
	end
	
	cash.Parent = cashSpawnDir
	cash:SetNetworkOwner(nil)
	
	delay(2,function()
		if cash and cash.Parent then
			repeat wait(1) until not cash.Parent or cash.Velocity.Magnitude <= 0.1
			--print("hahaha")

			if cash and cash.Parent then
				cash.Anchored = true
				cash.CanCollide = false
				cash.CanTouch = false
			end
		end
	end)
	
	MonitorCash(cash,value,despawnTime)
	
	return cash
end

function PickupFunc(player,a1,a2,a3)
	local char = player.Character
	if not char then return end
	local vF = _G.GVF(player.Name)
	
	if not vF then return end
	if _G.CheckIfCan and not _G.CheckIfCan(char,"Any") then return end

	if typeof(a1) ~= "Instance" or a1.Parent ~= cashSpawnDir then return end
	local mag = (a1.Position - char.HumanoidRootPart.Position).Magnitude
	if mag >= 10 then return end
	if a1:GetAttribute("DONE") then return end

	if _G.RAC_CHECK and not _G.RAC_CHECK("89RWE89SDFJWEP[O2398",player) then return end
	
	--	if coolDowns[char] then
	--		eventsDir.ClientWarn:FireClient(player,{"Pickup cooldown " .. tostring(math.floor(config.CoolDownTime - (tick() -  coolDowns[char]))) .. "s",1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
	--		return
	--	end
	if coolDowns[char] then
		if not spams[char] then
			spams[char] = 0
			delay(3,function()
				spams[char] = nil
			end)
		end
		spams[char] += 1
		
		if spams[char] > 20 then
			game.ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",player.Name,"Server tamper: " .. "Attempted to spam pick up cash",1,true)
			player:Kick("Attempted to bypass script whitelist.")
			return
		end
		
		eventsDir.ClientWarn:FireClient(player,{"Pickup cooldown",1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
		return
	end
	
	if char.Torso:FindFirstChild("Grab") then
		char.Torso.Grab:Play()
	end
	
	a1:SetAttribute("DONE",true)
	ServerStorage.Events3.nMonee:Fire("IU3898EJKLOY89TYZJDKLJGYI390WKHJSDHG9UKLJLEDGKLJERG9U",player,"Cash",a1.Value.Value)
	
	pcall(function()
		if a1:GetAttribute("LC") then
			if #game:GetService("Players"):GetPlayers() < 15 then
				local t = player:GetAttribute("LootNoticeTime") or -9999
				
				if time() - t > 600 then
					delay(2,function()
						local tab = {
							Title = "Loot Reminder";
							Text = "Servers with less players provide less loot value.";
							Duration = 15;
							Button1 = "Close";
						}

						ReplicatedStorage.Events.Notification:FireClient(player,tab,"lost")	
					end)
					
					player:SetAttribute("LootNoticeTime",math.floor(time()))
				end
			end
		end
	end)

	a1:Destroy()
	
	coolDowns[char] = tick()
	delay(config.PickupCooldown,function()
		coolDowns[char] = nil
	end)
	--	coolDowns[char] = tick()
	--	delay(config.CoolDownTime,function()
	--		coolDowns[char] = nil
	--	end)
end

local function isRealNumber(num)
	return (typeof(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end

local busyPlrs = {}
function DropFunc(plr,a1)
	local char = plr.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	
	if not (char and hum and root) then return false end
	--if _G.CheckIfCan and not _G.CheckIfCan(char,"Any") then return end
	if hum.Health <= 0 then return end
	if not typeof(a1) == "number" then return end
	if busyPlrs[plr.Name] then return end
	if typeof(a1) ~= "number" or not tonumber(a1) then return end
	if not isRealNumber(a1) then return end
	
	if ServerStorage.Values.DisableDroppingCash.Value then
		return false,"Dropping disabled!"
	end
	
	local vF = _G.GVF(char.Name)
	
	if vF and vF.Handcuffed.Value then return end
	
	--if game then return false,"Feature is temporarily disabled" end
	
	local joinTick = _G.GetPlayerData(plr).JoinTick.Value
	local calc = math.floor(tick() - joinTick)
	
	if calc < GameSettings.MinCashDropTime then
		eventsDir.ClientWarn:FireClient(plr,{"You must be in the server for " .. GameSettings.MinCashDropTime - calc .. " more seconds to do this." ,1.5,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 	
		return
	end
	
	local dd = dropData[plr.Name]
	if not dd then
		dd = deepCopy(oDD)
		dropData[plr.Name] = dd
	end

	a1 = math.floor(a1)
	
	local pd = PlayerbaseData:FindFirstChild(plr.Name)
	if not pd then return end
	
	busyPlrs[plr.Name] = true
	delay(1,function()
		busyPlrs[plr.Name] = nil
	end)
	
	if pd.Cash.Value - a1 < 0 then
		return false,"Exceeds cash"
	end
	if a1 < config.MinDropAmount then
		return false,"Min = $" .. config.MinDropAmount
	elseif a1 > config.MaxDropAmount then
		return false,"Max = $" .. config.MaxDropAmount
	end
	
	if tick() - dd.LastTick < config.DropCooldown1 then
		busyPlrs[plr.Name] = nil
		return false,"Cooldown (5s)" 
	elseif dd.DropAmount + a1 > config.Max2DropAmount then
		busyPlrs[plr.Name] = nil
		return false,"Drop cooldown!"
		--(max = " .. config.Max2DropAmount .. ", dropped " .. tostring(a1) .. ")"
	end
	
	local code = math.random()
	dd.Code = code
	
	delay(config.DropCooldown2 * 60,function()
		if dropData[plr.Name] and dropData[plr.Name].Code == code then
			dropData[plr.Name] = nil
		end
	end)
	
	dd.LastTick = tick()
	dd.DropAmount = dd.DropAmount + a1
	
	dropData[plr.Name] = dd
	
	if char.Torso:FindFirstChild("Grab") then
		char.Torso.Grab:Play()
	end
	
	ServerStorage.Events3.nMonee:Fire("IU3898EJKLOY89TYZJDKLJGYI390WKHJSDHG9UKLJLEDGKLJERG9U",plr,"Cash",-a1)

	local pos = plr.Character.HumanoidRootPart.Position
	local lv = (plr.Character.HumanoidRootPart.CFrame.LookVector * 2)

	if root.Orientation.X >= 45 or root.Orientation.X <= -45 then
		lv = Vector3.new(0,2,0)
	end
	
	local CF = CFrame.new(plr.Character.HumanoidRootPart.Position + lv)
	CF = CF * CFrame.Angles(0,math.rad(math.random(0,360)),0)
	SpawnCash("8DR002",CF,1,a1,360)
	
	busyPlrs[plr.Name] = nil
	
	return true
end

pickupEvent.OnServerEvent:Connect(PickupFunc)
dropEvent.OnServerInvoke = DropFunc

drop_sEvent.Event:Connect(SpawnCash)
drop_sEvent2.OnInvoke = SpawnCash

monitor_sEvent.Event:Connect(MonitorCash)

Players.PlayerRemoving:Connect(function(plr)
	dropData[plr.Name] = nil
end)


--while wait(1) do
--	local CF = CFrame.new(-229.89, 153.33, 8.41) * CFrame.new(math.random(-500,500) / 100 ,0,math.random(-500,500) / 100)
--	CF = CF * CFrame.Angles(0,math.rad(math.random(0,360)),0)
--	SpawnCash(CF,1,math.random(50,300),60)
--end

M.SetUp = function(settinz)
	GameSettings = settinz
	config = GameSettings.CashDropSettings
end

return M