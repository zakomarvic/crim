local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local ServerScriptService	= game:GetService("ServerScriptService")
local ServerStorage 		= game:GetService("ServerStorage")
local RunService			= game:GetService("RunService")
local Workspace				= game:GetService("Workspace")
local Players				= game:GetService("Players")
local TS 					= game:GetService("TweenService")

if not RunService:IsStudio() then
	wait(1)
end

ReplicatedStorage:WaitForChild("GameLoaded",100)

local REMOTES	= ReplicatedStorage.Events
local MODULES	= ReplicatedStorage:WaitForChild("Modules")
local EVENTS 	= ReplicatedStorage:WaitForChild("Events")
local EVENTS2	= ReplicatedStorage:WaitForChild("Events2")
local EVENTS3 = ServerStorage:WaitForChild("Events3")

local CONFIG	= require(MODULES.Config)
local DAMAGE	= require(MODULES.Damage)
local EFFECTS 	= require(MODULES.Effects)

local PLAYERS = require(game:GetService("ServerStorage").PlantsStorage.Objects.Player)

local types = require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Types"))
local framework: types.framework = require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Framework")) 

local fastWaitM = require(MODULES.FastWait)

local GameSettings = _G.GSAT345NIJ384TU034TRWEFGKFGS

local MeleeSettings = {
	ReverseHits = false;

	DownedKill_Leeway = 0.06;
	PingSync_Max = 1000; -- in ms

	PassoverEnabled = false;
	PassoverMulti = 0.4;

	BRUH_SEC_C = "🍞";

	NoComboRequired = true;

	DownedDmgDiv = 1.5;
}

local cMelees = {}
local NewMeleeEvent =	EVENTS3:FindFirstChild("NewMelee")
local mRemote =			REMOTES:WaitForChild("XMHH.2")
local mEvent =			REMOTES:WaitForChild("XMHH2.2")

local blockModule =	require(script.BlockModule)
local AA_Module =	_G.AntiExploitModule

local PingTimes = require(MODULES.PingTimes)

local ToolModules = ServerStorage:FindFirstChild("ToolModules")

local StaminaFunctionBind = EVENTS3:WaitForChild("Staminaaa")
local GetModelMassModule = require(MODULES.GetModelMass)

local rValues = ReplicatedStorage.Values

local MeleeSounds = Instance.new("Folder")
MeleeSounds.Name = "MeleeSounds"
MeleeSounds.Parent = ServerStorage

local reviveDBs = {}
local CONFIGS = {}
local downDBs = {}

local crateDBs = {}

local function GetSoundDir(v)
	return MeleeSounds:FindFirstChild(v.Name)
end

local function Lerp(a, b, c)
	return a + ((b - a) * c)
end

--- local functions
local function PlaySound(p,n)
	if p and p.Parent and p:FindFirstChild(n) then
		p[n]:Play()
	end
end

local function StopSound(p,n)
	if p and p.Parent and p:FindFirstChild(n) then
		p[n]:Stop()
	end
end

local function StopSound2(p,n)
	if p and p.Parent and p:FindFirstChild(n) then
		p[n]:Destroy()
	end
end

local function PlaySound2(tool,name,part)
	local sDir = GetSoundDir(tool)

	StopSound2(part,name)
	if sDir and sDir:FindFirstChild(name) then
		local sound = sDir[name]:Clone()
		game.Debris:AddItem(sound,sDir[name].TimeLength)
		sound.Parent = part
		sound:Play()
	end
end

local function RealityCheck(Player,Tool)
	if cMelees[Tool] and cMelees[Tool].Tool and cMelees[Tool].Tool.Parent and cMelees[Tool].Tool.Parent == Player.Character then
		return true
	end
end

local function AddXP(sPlr,xp)
	game.ServerStorage.Events3.AyuP:Fire("KLJ8902209SANK8234LDFG0OKJAKA984231ZZ04LGXBNBZ1U912",sPlr,xp)	
end

local function CancelAnim(x)
	if x then
		x:Stop()
	end
	x = nil
end

local function lookAt(target, eye)
	local forwardVector = (eye - target).Unit
	local upVector = Vector3.new(0, 1, 0)

	local rightVector = forwardVector:Cross(upVector)
	local upVector2 = rightVector:Cross(forwardVector)

	return CFrame.fromMatrix(eye, rightVector, upVector2)
end

local function DmgOverTime(VF,Humanoid,Dmg,Time,Step,Fatal)
	local Dmg = Dmg

	if VF then
		Dmg = Dmg * VF.BleedProof.Value
	end

	_G.DamageOverTime(Humanoid,Dmg,Time,Step,Fatal)
end

local function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

local deepCopy = require(MODULES.DeepCopy)

local function CheckIfFacing(Part1,Part2,div)
	div = div or 1.5
	local threshold = nil
	threshold = threshold or math.pi/div --if you don't give it a threshold, then the threshold is 90 degrees
	return Part1.CFrame.LookVector:Dot((Part2.CFrame.Position-Part1.CFrame.Position).Unit) > math.cos(threshold)
end

local function Destroy(x)
	if x and x.Parent then
		x:Destroy()
	end
	x = nil
end

local function CanBlockCheck(hitTool,myTool)
	if not (myTool and myTool.Parent and hitTool and hitTool.Parent) then return end

	local x = blockModule[myTool.Name]
	if x then
		for _,v in pairs(x) do
			if v == hitTool.Name or v == "All" then
				return true
			end
		end
	end

	return false
end


local function getValueStr(s)
	local r = 0
	for c in s:gmatch'.' do
		r = r + c:byte()
	end

	return r or 0
end

local SCM = {
	['IntSalt'] = 81919,
	['UserIdSalt'] = false,
	["MaxDt"] = 75000,
}

local function getDt(p, d)
	local uid = p.UserId
	local Data = d + (SCM.IntSalt+(SCM.UsernameSalt and getValueStr(tostring(p)) or 0) + (SCM.UserIdSalt and uid/2 or 0))
	return ReplicatedStorage.Values.ServerTick.Value - Data
end
-------


for _,v in pairs(ToolModules.Melees:GetChildren()) do
	local c = require(v)
	CONFIGS[v.Name] = c

	local realTool = ServerStorage.Tools:FindFirstChild(v.Name)
	if realTool then
		local rTSounds = realTool:FindFirstChild("Sounds")
		rTSounds.Name = v.Name
		rTSounds.Parent = MeleeSounds

		local realHandle = realTool:FindFirstChild(c.Handle[2])
		if realHandle then
			for _,v in pairs(realHandle:GetChildren()) do
				if v:IsA("Sound") and
					(
						v.Name == "BlockStart"
							or v.Name == "BlockStop"
							or v.Name == "EquipSound"
							or v.Name == "Execute"
							or v.Name == "Execute2"
							or v.Name == "Swing1"
							or v.Name == "Swing2"
							or v.Name == "Swing3"
							or v.Name == "UnequipSound"
					)
				then
					v.Parent = rTSounds
				end
			end
		end
	end
end

local GrabModule
delay(3,function()
	GrabModule  = _G.GrabModule
end)

local function FireExploitLog(player,text,doKick)
	ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",player.Name,"Server tamper | melee: " .. text,1,true)
	if doKick then
		task.delay(math.random(1,10),function()
			pcall(function()
				player:Destroy()
				wait()
				player:Kick()
			end)
			--player:Kick("Attempted to bypass script whitelist.")
		end)

	end
end


function OnRemote(Player,mainSecurityCode,securityCode,Tool,Type,...)
	AA_Module = _G.AntiExploitModule

	local Dt = getDt(Player, securityCode)

	if Dt > SCM.MaxDt then
		return
	end
	
	if Type == "ZAPESC" then
		local nm = typeof(Tool) == "Instance" and Tool:IsA("Tool") and cMelees[Tool]
		if nm and Player.Character and (Tool.Parent == Player.Character or Tool.Parent == Player:FindFirstChild("Backpack")) then
			return nm:ZapEscapeFunc(Player.Character)
		end
		return
	end
	
	if Player.Character and Player.Character.Parent and Tool and Tool:IsA("Tool") and RealityCheck(Player,Tool) and _G.CheckIfCan(Player.Character,nil,MeleeSettings.DownedKill_Leeway,MeleeSettings.DownedKill_Leeway) then
		local nMelee = cMelees[Tool]

		--if not AA_Module:CheckTing(Player.Character) then return end
		if Type == "43TRFWX" then
			return nMelee:SwingFunc(Player.Character,...)
		elseif Type == "2389ZFX34" then
			nMelee:HitFunc(Player.Character,...)
		elseif Type == "BLSTAX1" then
			return nMelee:BlockStartFunc(Player)
		elseif Type == "BZLZSTI2" then
			return nMelee:BlockStopFunc(Player)
		elseif Type == "EXECQX" then
			return nMelee:ExecuteFunc(Player.Character)
		elseif Type == "EEZXEQ2" then
			return nMelee:CancelExecuteFunc(Player.Character)
		elseif Type == "PPZXKU1" then
			return nMelee:PickupHandler(Player.Character,"Start")
		elseif Type == "PPZXKU2" then
			return nMelee:PickupHandler(Player.Character,"Stop")
		elseif Type == "PPZXKU3" then
			return nMelee:PickupHandler(Player.Character,"Throw")
		elseif Type == "DZDRRRKI" then
			return nMelee:DoorKickFunc(Player.Character,...)
		elseif Type == "REV1" then
			return nMelee:ReviveFunc(Player.Character,...)
		elseif Type == "REV2" then
			return nMelee:CancelReviveFunc(Player.Character,...)
		elseif Type == "SNNBZAA" then
			return nMelee:SnowballFunc(Player.Character,...)
		elseif Type == "ZAPQX1" then
			return nMelee:ZapStartFunc(Player.Character,...)
		elseif Type == "ZAPQX2" then
			return nMelee.ZapStopFunc()
		elseif Type == "THRWQX1" then
			return nMelee:ThrowFunc(Player.Character,...)
		elseif Type == "THRWQX0" then
			return nMelee:ThrowChargeStartFunc(Player.Character)
		elseif Type == "THRWQX2" then
			return nMelee.ThrowChargeCancelFunc()
		end
	end
end

NewMeleeEvent.Event:Connect(function(Tool)
	if cMelees[Tool] then return end

	local nMelee = {}
	nMelee.EqCode = math.random()
	nMelee.Equipped = false
	nMelee.Tool = Tool
	nMelee.SwingNum = 0
	nMelee.ComboCount = 0

	cMelees[Tool] = nMelee

	local function GetTing(cL,sCharacter)
		local x = cL

		if x[1] == "Tool" then
			return Tool:FindFirstChild(x[2])
		elseif x[1] == "Char" and sCharacter then
			return sCharacter:FindFirstChild(x[2])
		end
	end

	local originalConfig = ToolModules.Melees[Tool.Name]:Clone()
	originalConfig.Name = "Config"
	originalConfig.Parent = Tool

	local config = CONFIGS[Tool.Name]

	local Handle = GetTing(config["Handle"],nil)
	local customModulesDir = Tool:FindFirstChild("Modules")
	local animsDir = Tool:FindFirstChild("AnimsFolder")
	local SoundsDir = GetSoundDir(Tool)
	
	local function GetSoundFromDir(dir: string)
		--
		local path = string.split(dir, ">")
		local overrides = Tool:FindFirstChild("SoundOverrides")
		--
		local function find_from(from: Instance)
			--
			local root = from
			local found: Instance = root
			--
			for _, into in ipairs(path) do
				if (found:FindFirstChild(into)) then
					found = found:FindFirstChild(into)
				else
					break
				end
			end
			--
			return found
		end
		--
		local gotten: Instance = (overrides ~= nil and find_from(overrides)) or find_from(SoundsDir)
		if (gotten:IsA("Folder")) then
			local inside = gotten:GetChildren()
			gotten = inside[math.random(1, #inside)]
		end
		--
		return gotten:Clone()
	end

	local executeAnim = nil
	local disconnected = false
	local eCon
	local customs = {}
	local lCharacter

	local swingTables = {}

	local sCode = 0
	local defaultSwingTable = {
		Code = 0;
		HitCount = 0;
		SwingNum = 1;
		HitChars = {};
		LastHitChar = nil;
		cST = "";
		Ended = false;
	}

	local function NewAnim(Humanoid,n)
		if animsDir:FindFirstChild(n) then
			return Humanoid:LoadAnimation(animsDir[n])
		else
			local a = Instance.new("Animation")
			a.AnimationId = "rbxassetid://0"
			game.Debris:AddItem(a,0)
			return Humanoid:LoadAnimation(a)
		end
	end

	local Values = Instance.new("Folder")
	Values.Name = "Values"
	
	local IsMelee = Instance.new("BoolValue")
	IsMelee.Name = "IsMelee"
	IsMelee.Parent = Tool

	local Slashing1 = Instance.new("BoolValue")
	Slashing1.Name = "Slashing1"
	Slashing1.Parent = Values

	local CustomFlinch = Instance.new("BoolValue")
	CustomFlinch.Name = "CustomFlinch"
	CustomFlinch.Parent = Values

	local SlashDB = Instance.new("BoolValue")
	CustomFlinch.Name = "SlashDB"
	CustomFlinch.Parent = Values

	local BlockValue = Instance.new("BoolValue")
	BlockValue.Name = "Blocking"
	BlockValue.Parent = Values

	local ExecuteValue = Instance.new("BoolValue")
	ExecuteValue.Name = "Executing"
	ExecuteValue.Parent = Values

	if config.BlockSettings.DontCancelOnHit then
		local NoFlinchValue = Instance.new("BoolValue")
		NoFlinchValue.Name = "NoFlinch"
		NoFlinchValue.Parent = Tool
	end
	
	for name,v in pairs(config.Mains) do
		if v.CustomCooldown then
			local slashCooldown = Instance.new("BoolValue")
			slashCooldown.Name = "slashCooldown_"..name
			slashCooldown.Parent = Values
		end
	end

	if config.Customs["Pickup"] then
		local x = Instance.new("BoolValue")
		x.Name = "Grabbing"
		x.Parent = Values
		customs.GrabValue = x
	end

	if config.Customs["Revive"] then
		local x = Instance.new("BoolValue")
		x.Name = "Reviving"
		x.Parent = Values
		customs.ReviveValue = x	
	end

	if config.Customs["PoisonCharges"] then
		local x = Instance.new("IntValue")
		x.Name = "PoisonCharges"
		x.Value = config.Customs.PoisonCharges.StartCharges
		x.Parent = Values
		customs.ReviveValue = x	

	end

	local cmEvent = Instance.new("RemoteEvent")
	cmEvent.Name = "Event"
	cmEvent.Parent = Tool

	local DisconnectEvent = Instance.new("RemoteFunction")
	DisconnectEvent.Name = "DisconREMOTE"
	DisconnectEvent.Parent = Tool

	local eventCon = cmEvent.OnServerEvent:Connect(OnRemote)
	local con1,con2

	local S_SWST = nil
	
	if config.Customs["Zap"] and animsDir and not animsDir:FindFirstChild("ZapIdle") then
		local src = ServerStorage.Storage.ForceChokeDirectory.GrabLS:FindFirstChild("ForceZapIdle")
		if src then
			local c = src:Clone()
			c.Name = "ZapIdle"
			c.Parent = animsDir
		end
	end
	
	if config.Customs["Zap"] then
		local zc = config.Customs.Zap
		local charge = Instance.new("NumberValue")
		charge.Name = "ZapCharge"
		charge.Value = zc.MaxCharge or 100
		charge.Parent = Values

		task.spawn(function()
			while not disconnected do
				task.wait(0.5)
				if customs and not customs.Zapping then
					if charge.Value <= 0 then
						local p = Tool.Parent
						local owner = p and (Players:GetPlayerFromCharacter(p) or (p.Parent and p.Parent:IsA("Player") and p.Parent))
						if owner then
							nMelee.TryBattery(owner)
						end
					end
					if (zc.RechargePerSecond or 0) > 0 then
						charge.Value = math.min(zc.MaxCharge or 100, charge.Value + zc.RechargePerSecond * 0.5)
					end
				end
			end
		end)
	end
	
	Values.Parent = Tool

	local function DisconnectFunc()
		if disconnected then return end

		pcall(function()
			disconnected = true
			nMelee.UnequipFunc(true)
			if Handle and Handle.Parent then
				Handle.CanCollide = true
				Handle.Massless = true
				for _,v in pairs(Tool:GetDescendants()) do
					if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") or v:IsA("Constraint") then
						v:Destroy()
					end
				end
			end
		end)
		
		pcall(nMelee.ThrowCleanup)

		if customModulesDir and customModulesDir:FindFirstChild("Disconnect") then
			require(customModulesDir["Disconnect"])
		end

		wait(0.1)

		customs = nil
		swingTables = nil
		lCharacter = nil
		config = nil

		con1:Disconnect()
		con2:Disconnect()

		nMelee = nil
		cMelees[Tool] = nil

		eventCon:Disconnect()
		eventCon = nil

		cmEvent:Destroy()
		cmEvent = nil

		Values:Destroy()
		Values = nil

		Tool:Destroy()

		return
	end

	con1 = Tool.Equipped:Connect(function()	nMelee:EquipFunc() end)
	con2 = Tool.Unequipped:Connect(function()	nMelee:UnequipFunc() end)

	local ansCON
	ansCON = Tool.AncestryChanged:Connect(function(_,Parent)
		if not Parent or (Parent ~= ServerStorage.HoldingTools and Parent.Name ~= "Backpack" and not Parent:FindFirstChild("Humanoid")) then
			DisconnectFunc()
			ansCON:Disconnect()
		end
	end)

	------------------------------------------------------

	local function checkHitName(hit)
		local hitNames = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
		for _,v in pairs(hitNames) do 
			if v == hit.Name or (config.CanClash and hit:FindFirstChild("Blade")) then 
				return true
			end
		end		
	end

	function nMelee:DoorKickFunc(sCharacter,gModel,typ)
		--print("DK1",typ)
		if typ ~= "Door" and typ ~= "Register" and typ ~= "Crate" and typ ~= "Vending" then return end
		--print("DK2")
		if (typ == "Door" and not config.Customs["DoorKick"])
			or (typ == "Register" and not config.Customs["RegisterHit"])
			or (typ == "Crate" and not config.Customs["CrateHit"]) 
			or (typ == "Vending" and not config.Customs["VendingHit"]) 
		then return end
		--print("DK3")
		if disconnected then return end
		if SlashDB.Value then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed then return end
		if customs.DoorKickDB then return end		
		if customs.Reviving then return end

		if typ ~= "Crate" and (not gModel or typeof(gModel) ~= "Instance") then return end

		--print("DK4")

		local sPlr,sHumanoid,sRoot,sHead,sTorso = Players:GetPlayerFromCharacter(sCharacter),sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Head"),sCharacter:FindFirstChild("Torso")

		if typ == "Register" and sPlr and _G.GetPlayerData(sPlr) then
			local joinTick = _G.GetPlayerData(sPlr).JoinTick.Value
			local calc = math.floor(tick() - joinTick)
			if calc < GameSettings.MinRegisterBreakTime then
				EVENTS.ClientWarn:FireClient(sPlr,{"You must be in the server for " .. GameSettings.MinRegisterBreakTime - calc .. " more seconds to do this." ,1.5,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 	
				return
			end
		end

		local function RayCheck(pos1,part,list)
			local ray = Ray.new(pos1, (part.Position - pos1).Unit * 15)
			local n, position = workspace:FindPartOnRayWithWhitelist(ray, {list},true)
			return (n and n == part)
		end

		local function kickCheck()
			if not (gModel.Parent == workspace.Map.Doors and (gModel.Knob2.Position - sRoot.Position).Magnitude < 6) then
				return false
			end

			local woodOnly = config.Customs["DoorKick"].WoodOnly

			if gModel.Values.Type.Value ~= "Wood" and woodOnly then
				return false
			end

			if (gModel.Parent == workspace.Map.Doors 
				and gModel.Values.Broken.Value == false 
				and (config.Customs["DoorKick"].KickUnlocked or gModel.Values.Locked.Value == true) 
				--and RayCheck(sRoot.Position,gModel.Knob2,gModel)
				)
			then
				return true
			end
			return false
		end

		local function kickCheck2()
			if not (gModel.Parent == workspace.Map.BredMakurz and (gModel.MainPart.Position - sRoot.Position).Magnitude < 6) then
				return false
			end
			if (gModel.Parent == workspace.Map.BredMakurz and gModel.Values.Broken.Value == false 
				--and (RayCheck(sRoot.Position,gModel.MainPart,gModel) or RayCheck(sHead.Position,gModel.PrimaryPart,gModel))
				)
			then
				return true
			end
			return false
		end

		local function kickCheck3()
			local id = gModel


			local crateData = ServerStorage.Events3.GetActiveScrapData:Invoke(id)

			--print(id,crateData)

			if crateData then
				--print("ye got retun of scrapdata")
				if crateData.active and crateData.isCrate 
					--and crateData.isLocked 
				then
					local cf = crateData.cf

					--print("ye scrap is a damn locked crate!")

					if sRoot and (sRoot.Position - cf.Position).Magnitude < 15 then
						return crateData
					end
				end
			end
		end

		local function kickCheck4()
			--print("DK11_1")
			local vendingF = workspace.Map:FindFirstChild("VendingMachines")
			if not vendingF then
				return
			end

			--print("DK11_2")

			if not (gModel.Parent == vendingF and (gModel.MainPart.Position - sRoot.Position).Magnitude < 10) then
				return false
			end

			--print("DK11_3")

			if (gModel.Parent == vendingF and gModel.Values.Broken.Value == false and gModel.Values.Stuck.Value
				--and (RayCheck(sRoot.Position,gModel.MainPart,gModel) or RayCheck(sHead.Position,gModel.PrimaryPart,gModel))
				)
			then
				--print("DK11_4")
				return true
			end
			return false
		end

		local crateData = (typ == "Crate" and kickCheck3())

		--	print(7,crateData)

		--print("DK9")

		if (typ == "Door" and kickCheck()) 
			or (typ == "Register" and kickCheck2()) 
			or crateData 
			or (typ == "Vending" and kickCheck4()) 
		then
			--print("DK10")
			local cL
			if typ == "Door" then
				cL = config.Customs.DoorKick
			elseif typ == "Register" then
				cL = config.Customs.RegisterHit
			elseif typ == "Crate" then
				cL = config.Customs.CrateHit
			elseif typ == "Vending" then
				cL = config.Customs.VendingHit
			end

			if not StaminaFunctionBind:Invoke(sPlr,cL.StaminaUsage) then return end

			if typ ~= "Register" then
				_G.CombatTagChar(sPlr,15,"DK")
			end

			customs.DoorKickDB = true
			customs.DoorKicking = true

			local cCode = math.random()
			customs.DoorKickCode = cCode

			customs.DoorKickType = typ
			customs.CrateData = crateData

			local isInverted = typ == "Door" and gModel.Values.IsInverted.Value

			--customs.DoorKickAnim = sHumanoid:LoadAnimation((isInverted and  Tool.AnimsFolder:FindFirstChild("DoorHit2") and Tool.AnimsFolder.DoorHit2) or Tool.AnimsFolder.DoorHit)
			--customs.DoorKickAnim:Play()

			local dTime = cL.SwingTime + cL.SwingWait

			if cL.DebounceTime > dTime then 
				dTime = cL.DebounceTime
			end
			dTime = dTime * 0.5

			if cL then
				delay(cL.DebounceTime,function()
					if customs then
						customs.DoorKickDB = false
					end
				end)
				delay(cL.DebounceTime + 2,function()
					if customs and customs.DoorKickCode == cCode then
						customs.DoorKicking = false
						customs.CrateData = nil
					end
				end)
			end
			return cCode
		end
		return false
	end


	function nMelee:DoorHitFunc(sCharacter,code,hit,hitM)
		if not config.Customs["DoorKick"] 
			and not config.Customs["RegisterHit"] 
			and not config.Customs["CrateHit"] 
			and not config.Customs["VendingHit"] 
		then return end

		if not customs.DoorKicking or code ~= customs.DoorKickCode then return end

		local sPlr,sHumanoid,sRoot,sTorso = Players:GetPlayerFromCharacter(sCharacter),sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")

		local typ = customs.DoorKickType

		--print("doorhitfunc",sCharacter,code,hit)

		if typ == "Door" then
			if hit:IsA("BasePart") 
				and hitM.Parent == workspace.Map.Doors
				and hit:IsDescendantOf(hitM) 
				--and hitM.Values.Locked.Value
				and not hitM.Values.Broken.Value
			then
				customs.DoorKicking = false

				--local xp = 15
				--game.ServerStorage.Events3.AyuP:Fire(sPlr,xp)	

				local xp = math.floor(config.Customs.DoorKick.Damage / 8 + 0.5)
				xp = math.min(xp,30)
				AddXP(sPlr,xp)

				local customHitType = config.Customs.DoorKick.CustomHitType

				local kickedLocked = false
				if not hitM.Values.Locked.Value and config.Customs["DoorKick"].KickUnlocked then
					customHitType = "AxeHit"
					kickedLocked = true
					--print("yeah kicked not locked")
				end

				hitM.Events.Damage:Fire(
					config.Customs.DoorKick.Damage,
					customHitType,
					config.Customs.DoorKick.ForceMulti,
					config.Customs.DoorKick.DontPlayHitSound,
					sCharacter.HumanoidRootPart.Position,
					kickedLocked and 15
				)

			end
		elseif typ == "Register" then
			if hit:IsA("BasePart") 
				and hitM.Parent == workspace.Map.BredMakurz
				and hit:IsDescendantOf(hitM) 
				and not hitM.Values.Broken.Value
				and hitM.Type.Value <= config.Customs["RegisterHit"].BreakType
			then
				customs.DoorKicking = false

				local xp = math.floor(config.Customs.RegisterHit.Damage / 8 + 0.5)
				xp = math.min(xp,30)
				AddXP(sPlr,xp)

				hitM.Events.Damage:Fire(config.Customs.RegisterHit.Damage,sPlr)
			end		
		elseif typ == "Crate" and customs.CrateData and hit == customs.CrateData.id then
			if not crateDBs[sPlr] then
				crateDBs[sPlr] = {}
			end

			local __x = crateDBs[sPlr][customs.CrateData.id]
			if __x then
				if typeof(__x) == "number" then
					crateDBs[sPlr][customs.CrateData.id] += 1
					if __x < 30 then
						--crateDBs[sPlr][customs.CrateData.id] = "EXPLOIT"
						FireExploitLog(sPlr,"Attempted to XP_crate_dupe")
					end
				end

				return
			else
				delay(600,function()
					crateDBs[sPlr] = nil
				end)

				crateDBs[sPlr][customs.CrateData.id] = 0

				local xp = math.floor(config.Customs.CrateHit.Damage / 8 + 0.5)
				xp = math.min(xp,30)
				AddXP(sPlr,xp)

				--print("broke crate lol")

				ServerStorage.Events3.OpenActiveScrap:Invoke("MOK4F-90I4R-09I0-RMSDDFSADKL",customs.CrateData.id)

				customs.crateData = nil
			end
		elseif typ == "Vending" then
			if hit:IsA("BasePart") 
				and hitM.Parent == workspace.Map:FindFirstChild("VendingMachines")
				and hit:IsDescendantOf(hitM) 
				and not hitM.Values.Broken.Value
			then
				customs.DoorKicking = false

				local xp = math.floor(config.Customs.VendingHit.Damage / 8 + 0.5)
				xp = math.min(xp,30)
				AddXP(sPlr,xp)

				hitM.Events.Damage:Fire(config.Customs.VendingHit.Damage,sPlr,"IsKick")
			end		
		end
	end

	function nMelee:DoorKickCancel()
		if customs.DoorKicking then
			--customs.DoorKickAnim:Stop()
			customs.DoorKicking = false
			customs.DoorKickCode = 0
			customs.DoorKickType = nil
		end
	end

	function nMelee:EquipFunc()
		if disconnected then return end
		if Handle and not Handle.Parent then return end

		if customModulesDir and customModulesDir:FindFirstChild("Equip") then
			local m  =require(customModulesDir["Equip"])
			m(Tool.Parent)
		end

		coroutine.wrap(function()
			if Tool:FindFirstChild("Tool6D") then
				Tool.Tool6D.Part0 = Tool.Parent:WaitForChild("Right Arm")
			elseif Tool:FindFirstChild("Tool6D_Torso") then
				Tool.Tool6D_Torso.Part0 = Tool.Parent:WaitForChild("Torso")
				local v = Instance.new("CFrameValue")
				v.Value = Tool.Tool6D_Torso.C0
				v.Name = "DefaultCF"
				v.Parent = Tool.Tool6D_Torso
			end
		end)()

		nMelee.EqCode = math.random()
		lCharacter = Tool.Parent
		Handle = GetTing(config["Handle"],Tool.Parent)

		if Tool:GetAttribute("ripper") then
			local SParent = Handle
			local SName = "Equip"


			local Directory = game:GetService("ServerStorage"):WaitForChild("Storage").RipDirectory
			local Sound = Directory:WaitForChild(SName):Clone()

			Sound.PlaybackSpeed = Sound.PlaybackSpeed * math.random(950,1050) / 1000
			Sound.Parent = SParent
			Sound:Play()

			game.Debris:AddItem(Sound)

			for _, v in pairs(Handle:GetDescendants()) do
				if v:IsA("BasePart") and v.Parent.Name == "EyeParts" then
					v.Transparency = 1
				end
			end

			if Handle:FindFirstChild("RIP_PLS") then
				Handle:FindFirstChild("RIP_PLS"):Destroy()
			end
		end

		nMelee.Equipped = true

		if _G.CheckIfCan and not _G.CheckIfCan(Tool.Parent) then return end		

		if not Tool:GetAttribute("voidedge") then
			PlaySound2(Tool,"EquipSound",Handle)
		end

		if Tool:GetAttribute("HasKilltrack") and Tool:GetAttribute("ID") and game.Players:GetPlayerFromCharacter(lCharacter) then
			local ID = Tool:GetAttribute("ID")
			if Tool:GetAttribute(game.Players:GetPlayerFromCharacter(lCharacter).Name) then
				local dataBase = _G.DataBase_000[game.Players:GetPlayerFromCharacter(lCharacter)]
				for __, v in pairs(dataBase.playerData.Cosmetics.Skins) do
					if __ then
						if tostring(__) == tostring(ID) then
							local UptKilltrack = require(game:GetService("ServerStorage").Modules.UpdateKilltrack) UptKilltrack(Tool, v.KilltrackCT)
						end
					end
				end
			else
				local UptKilltrack = require(game:GetService("ServerStorage").Modules.UpdateKilltrack) UptKilltrack(Tool, "FRAUD")
			end
		end

		local humanoid=Tool.Parent.Humanoid
		
		nMelee.StalkTrackStart(Tool.Parent)
		
		eCon = humanoid.HealthChanged:Connect(function(x)
			if humanoid:GetState()==Enum.HumanoidStateType.Dead or (not humanoid:GetAttribute("SecondStatus") and x<=0) then
				DisconnectFunc()
				if eCon then
					eCon:Disconnect()
					eCon = nil
				end
			end
		end)

		if config.SlowDown and config.SlowDown.Enabled then
			if S_SWST and S_SWST.Parent then
				S_SWST:Destroy()
			end
			S_SWST = _G.AffectChar(Tool.Parent,"S_SWST",math.huge,math.random(),config.SlowDown.Amount)
		end
	end

	function nMelee:PickupHandler(sCharacter,m)
		if disconnected then return end
		if SlashDB.Value then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabbing then return false end
		if customs.DoorKickDB then return false end		
		if customs.Reviving then return end

		if not config.Customs["Pickup"] then return false end

		local sPlr,sHumanoid,sRoot,sTorso

		if sCharacter and sCharacter.Parent then
			sPlr,sHumanoid,sRoot,sTorso = Players:GetPlayerFromCharacter(sCharacter),sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")
		end

		if m == "Start" and not customs.grabbed and not customs.grabbing and not customs.grabDB then
			local function GetGChar()
				local Point1 = sCharacter.HumanoidRootPart.CFrame.p - Vector3.new(2,4,2)
				local Point2 = sCharacter.HumanoidRootPart.CFrame.p + Vector3.new(2,4,2)
				local Region = Region3.new(Point1,Point2)
				for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},math.huge)) do
					local gChar = Part.Parent
					if gChar ~= sCharacter
						and Part.Name == "Torso"
						and gChar:FindFirstChild("Humanoid") 
						and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead
						and _G.GVF(gChar.Name)
						and _G.GVF(gChar.Name).Grabbed.Value == false
						and (_G.DownedCheck(gChar) or _G.GVF(gChar.Name).Currents:FindFirstChild("TIEDUP") or _G.GVF(gChar.Name).Unconscious.Value)
					then
						return gChar,gChar:FindFirstChild("Humanoid")
					end
				end	
				return nil			
			end

			local gChar,gHumanoid = GetGChar()

			if not (gChar and gHumanoid) then return end
			if not StaminaFunctionBind:Invoke(Players:GetPlayerFromCharacter(sCharacter),config.Customs.Pickup.GrabStaminaUsage) then return end

			CancelAnim(customs.grabAnim1)
			CancelAnim(customs.grabAnim2)
			CancelAnim(customs.grabAnim3)
			CancelAnim(customs.grabAnim4)

			customs.grabDB = true
			customs.grabbing = true
			customs.grabAnim1 = NewAnim(sHumanoid,"LiftBodyStart")
			customs.grabAnim1:Play()

			local s = game.ServerStorage.Storage.PlayerSounds.Torso.PickupChar:Clone()
			game.Debris:AddItem(s,2)
			s.Parent = sCharacter.Torso
			s:Play()
			--PlaySound(sCharacter.Torso,"PickupChar")

			_G.AffectChar(sCharacter,"SD",1.25,"Grab",14)
			_G.AffectChar(sCharacter,"AJ",1.25)	
			_G.AffectChar(sCharacter,"B",0.5)

			local cCode = math.random()
			customs.grabCode = cCode

			delay(0.5,function()
				delay(0.5,function()
					customs.grabDB = false
				end)
				if customs.grabbing and nMelee.Equipped and GrabModule.TryGrab(sCharacter,sHumanoid,gChar,gHumanoid,Tool,customs.grabbing) then
					Tool:SetAttribute("NoArmMovement",true)
					customs.grabbed = true
					Values.Grabbing.Value = true
					CancelAnim(customs.grabAnim2)
					CancelAnim(customs.grabAnim3)
					customs.grabAnim2 = NewAnim(sHumanoid,"LiftBodySuccess")
					customs.grabAnim2:Play()
					customs.grabAnim3 = NewAnim(sHumanoid,"LiftBodyIdle")
					customs.grabAnim3:Play()
					customs.grabSD = _G.AffectChar(sCharacter,"SD",math.huge,"Grab",0)
					--customs.grabAJ = _G.AffectChar(sCharacter,"AJ",math.huge)
				else
					customs.grabbed = false
				end
				customs.grabbing = false
			end)

			return true
		elseif m == "Stop" and customs.grabbed then
			customs.grabDB = true
			customs.grabbing = false
			customs.grabbed = false
			Values.Grabbing.Value = false

			CancelAnim(customs.grabAnim1)
			CancelAnim(customs.grabAnim2)
			CancelAnim(customs.grabAnim3)
			CancelAnim(customs.grabAnim4)

			cmEvent:FireClient(sPlr,"GrabStop")

			Destroy(customs.grabSD)
			--Destroy(customs.grabAJ)

			Tool:SetAttribute("NoArmMovement",nil)

			GrabModule.StopGrab(sCharacter.Name,1)

			delay(0.5,function()
				if customs then

					customs.grabDB = false		
				end
			end)

			return true
		elseif m == "Throw" and customs.grabbed and not customs.grabDB then
			if not StaminaFunctionBind:Invoke(Players:GetPlayerFromCharacter(sCharacter),config.Customs.Pickup.ThrowStaminaUsage) then return end

			customs.grabDB = true
			customs.grabbing = false
			customs.grabbed = false
			Values.Grabbing.Value = false

			CancelAnim(customs.grabAnim2)
			CancelAnim(customs.grabAnim3)

			Destroy(customs.grabSD)
			--Destroy(customs.grabAJ)

			CancelAnim(customs.grabAnim4)
			customs.grabAnim4 = NewAnim(sHumanoid,"LiftBodyThrow")
			customs.grabAnim4:Play()

			GrabModule.StopGrab(sCharacter.Name,2)

			delay(1,function()
				Tool:SetAttribute("NoArmMovement",nil)
				customs.grabDB = false		
			end)

			return true
		end
	end

	function nMelee:UnequipFunc(x)
		if disconnected and not x then return end
		nMelee.Equipped = false
		Slashing1.Value = false
		nMelee.CancelExecuteFunc()
		nMelee.BlockStopFunc()
		nMelee.PickupHandler(lCharacter,"Stop")
		nMelee.ThrowChargeCancelFunc()
		if customs then
			customs.StalkCode = nil
			customs.Stalk = {}
		end
		nMelee.ZapStopFunc()
		StopSound2(Handle,"EquipSound")
		PlaySound2(Tool,"UnequipSound",Handle)

		if Tool:GetAttribute("ripper") then
			for _, v in pairs(Handle:GetDescendants()) do
				if v:IsA("BasePart") and v.Parent.Name == "EyeParts" then
					v.Transparency = 1
				end
			end

			if Handle:FindFirstChild("RIP_PLS") then
				Handle:FindFirstChild("RIP_PLS"):Destroy()
			end
		end
		
		coroutine.wrap(function()
			if Tool:FindFirstChild("Tool6D") then
				Tool.Tool6D.Part0 = nil
			elseif Tool:FindFirstChild("Tool6D_Torso") then
				Tool.Tool6D_Torso.Part0 = nil
			end
		end)()

		if customModulesDir and customModulesDir:FindFirstChild("Unequip") then
			local m  = require(customModulesDir["Unequip"])
			m(Tool.Parent)
		end

		if S_SWST and S_SWST.Parent then
			S_SWST:Destroy()
		end
		S_SWST= nil

		if eCon then
			eCon:Disconnect()
			eCon = nil
		end
	end

	function nMelee:SwingFunc(sCharacter,swingSpecialType,lastTick,doPingSync,didClientHit)
		if disconnected then return end
		if swingSpecialType == "Normal" then swingSpecialType = nil end

		local sPlayer = Players:GetPlayerFromCharacter(sCharacter)

		doPingSync = doPingSync == true

		if SlashDB.Value then
			if doPingSync then
				local ev = Instance.new("BindableEvent")

				local c
				local activ = true
				local function disc()
					if not activ then return end
					activ = nil
					if c and typeof(c) ~= "boolean" then
						c:Disconnect()
						c = nil
					end
					ev:Fire()
				end

				coroutine.wrap(function()
					c = SlashDB.Changed:Wait()

					--if Tool.Name == "Nunchucks" then
					--	task.wait(0.15)
					--end

					if activ then
						disc()
					end
				end)()

				local maxLeeway = MeleeSettings.PingSync_Max
				local originPlayerPing = PingTimes[sPlayer] * 1.4
				local playerPing = math.floor((math.min(originPlayerPing * 1000,maxLeeway) / 1000) * 1000) / 1000

				task.delay(playerPing,function()
					disc()
				end)

				ev.Event:Wait()
				ev:Destroy()
			end

			if Tool.Name == "Nunchucks" then
				task.wait(0.1)
			end

			if SlashDB.Value then
				return false
			end
		end

		if (_G.GVF(sCharacter.Name).Currents:FindFirstChild("CUTTINGROPE")) then return end
		if Tool:GetAttribute("CantSwing_") then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed then return end
		if customs.DoorKickDB then return end
		if customs.Reviving then return end
		if customs.Thrown then return false end
		--sNum = math.floor(sNum)
		--if (sNum ~= 1 and sNum ~= 2 and sNum ~= 3) then return end
		--if sNum > config.SlashStages or sNum < 1 then return end
		if typeof(lastTick) ~= "number" then return end
		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter,nil,MeleeSettings.DownedKill_Leeway,MeleeSettings.DownedKill_Leeway)) or _G.CheckIfFlinching(sCharacter,true,true) or sCharacter.Humanoid.Health <= 0 then return end
		if sCharacter.Humanoid.Sit then return end

		local stamina_usage = config.StaminaUsage
		if (_G.CharHasTrait(sCharacter, "cigarettejunkie")) then
			stamina_usage = math.round(stamina_usage * 1.35) end
		--print("Stamina Usage: ", stamina_usage)

		if not StaminaFunctionBind:Invoke(Players:GetPlayerFromCharacter(sCharacter),stamina_usage) then return end
		local sHumanoid,sRoot,sTorso =sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")

		SlashDB.Value = true
		Slashing1.Value = true

		local sTick = tick()

		local cCode = math.random()
		sCode = cCode

		local sNum = nMelee.SwingNum
		
		if type(sNum) ~= "number"  and not swingSpecialType then sNum = 0 end
		if swingSpecialType then sNum = string.split(swingSpecialType,"")[1] end

		local vF = _G.GVF(sCharacter.Name)

		local function GetHitter(cL)
			if not cL then return end

			local x = cL["Hitter"]

			if x and x[1] == "Tool" then
				return Tool:FindFirstChild(x[2])
			elseif x and x[1] == "Char" then
				return sCharacter:FindFirstChild(x[2])
			end
		end
		local function IsBrokenCheck(hittingpart)
			if vF.HealthValues:FindFirstChild(hittingpart.Name) then
				if vF.HealthValues:FindFirstChild(hittingpart.Name).Broken.Value then
					return true
				end
			elseif vF.HealthValues:FindFirstChild("Right Arm").Broken.Value then
				return true
			end
		end

		local speedMulti = 1

		local _CL = (swingSpecialType and config.Mains[string.split(swingSpecialType,"")[1]]) or config.Mains["S" .. sNum]

		local _hitter
		if _CL then
			local hitter = GetHitter(_CL)
			_hitter = hitter

			if hitter and IsBrokenCheck(hitter) then
				speedMulti = speedMulti * 0.85
			end
		end




		--print("------------------------------------")
		--print("1_snuM: " .. sNum .. " | combo: " .. nMelee.ComboCount)

		local lastSwingTable = swingTables[cCode]


		--if doPingSync and didClientHit and not nMelee.DidHit then
		--	nMelee.ComboCount += 1 
		--	nMelee.DidHit = true
		--end

		if _CL and tonumber(lastTick) and lastTick > (_CL.DebounceTime + _CL.ComboEndTime) / speedMulti and not swingSpecialType then
			--print("end combo_1")
			nMelee.ComboCount = 0
			sNum = 0
		end

		local mcS=config.SlashStages>3 and 4 or 3
		if sNum == config.SlashStages-- or not nMelee.DidHit 

		then
			--print("end combo_2")
			nMelee.ComboCount = 0
			nMelee.DidHit = false
		end

		local bypass = false

		if type(sNum) == "number" and not MeleeSettings.NoComboRequired or config.ComboRequireBP then			
			if not config.M3HitCombo and sNum == 2 and nMelee.ComboCount < 2 and nMelee.DidHit then
				--print("combo set 1 " .. sNum)
				bypass = true
				sNum = 1
			elseif not config.M3HitCombo and sNum == 1 and nMelee.ComboCount > 1 and nMelee.DidHit then
				--print("combo 3 " .. sNum)
				sNum = 3
				bypass = true
			else--
				--print("combo +1 " .. sNum)
				sNum = sNum + 1
			end


			if (sNum < 1 or sNum > config.SlashStages or (not bypass and (sNum == 3 and nMelee.ComboCount < 2))) then
				sNum = 1
			end
		elseif type(sNum) == "number" then

			if nMelee.ResetCombo then
				sNum = 0
			end

			sNum += 1

			if (sNum < 1 or sNum > config.SlashStages) then
				sNum = 1
			end
		end

		if sNum == 1 then
			local _CL = (swingSpecialType and config.Mains[string.split(swingSpecialType,"")[1]]) or config.Mains["S" .. sNum]

			local _hitter
			if _CL then
				local hitter = GetHitter(_CL)
				if hitter then
					if vF.HealthValues:FindFirstChild(hitter.Name) and vF.HealthValues[hitter.Name].Destroyed.Value then
						sNum += 1
					end
				end
			end
		end

		nMelee.DidHit = false
		nMelee.ResetCombo = nil

		nMelee.SwingNum = sNum
		nMelee.LastSwingCode = cCode

		local tab = deepCopy(defaultSwingTable)
		tab.Code = cCode
		tab.SwingNum = sNum
		tab.StartTick = tick()
		swingTables[cCode] = tab

		local cL = config.Mains["S" .. sNum]

		local sPart = cL and GetTing(cL["SoundPart"],sCharacter)
		
		if Tool:GetAttribute("voidedge") then
			local sDir = game:GetService("ServerStorage"):WaitForChild("Storage").VoidDirectory
			local sound = sDir["Swing" .. sNum]:Clone()
			game.Debris:AddItem(sound,sDir["Swing" .. sNum].TimeLength)
			sound.Parent = sPart
			sound:Play()
		elseif swingSpecialType then
			cL = config.Mains[string.split(swingSpecialType,"")[1]]
			sPart = GetTing(cL["SoundPart"],sCharacter)

			PlaySound2(Tool,swingSpecialType,sPart)
		else
			PlaySound2(Tool,"Swing" .. sNum,sPart)
		end

		if Tool:GetAttribute("ripper") then
			local SParent = Handle
			local SName = "Swing"

			local Directory = game:GetService("ServerStorage"):WaitForChild("Storage").RipDirectory
			local Sound = Directory:WaitForChild(SName):Clone()

			Sound.PlaybackSpeed = Sound.PlaybackSpeed * math.random(950,1050) / 1000
			Sound.Parent = SParent
			Sound:Play()

			game.Debris:AddItem(Sound)

			local CurCode = nMelee.EqCode

			local PL = Instance.new("PointLight")
			PL.Color = Color3.fromRGB(255, 48, 48)
			PL.Brightness = 0
			PL.Shadows = true
			PL.Range = 7
			PL.Name = "RIP_PLS"

			PL.Parent = Handle

			game.Debris:AddItem(PL, 2.5)

			game:GetService("TweenService"):Create(PL, TweenInfo.new(0.3), {
				Brightness = 3
			}):Play()

			for _, v in pairs(Handle:GetDescendants()) do
				if v:IsA("BasePart") and v.Parent.Name == "EyeParts" then
					game:GetService("TweenService"):Create(v, TweenInfo.new(0.3), {
						Transparency = 0
					}):Play()
				end
			end

			delay(2, function()
				if CurCode == nMelee.EqCode then

					if PL and PL.Parent then
						game:GetService("TweenService"):Create(PL, TweenInfo.new(0.3), {
							Brightness = 0
						}):Play()
					end

					for _, v in pairs(Handle:GetDescendants()) do
						if v:IsA("BasePart") and v.Parent.Name == "EyeParts" then
							game:GetService("TweenService"):Create(v, TweenInfo.new(0.3), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end)
		end

		if SoundsDir:FindFirstChild("SwingSoundAddon") then
			local hitSound2 = SoundsDir["SwingSoundAddon"]:Clone()
			hitSound2.Parent = Handle
			hitSound2.PlaybackSpeed = hitSound2.PlaybackSpeed * math.random(900,1100) / 1000
			hitSound2:Play()
			game.Debris:AddItem(hitSound2)
		end

		if Tool:GetAttribute("goldenkatana") then
			local hitSound2 = script["Ching2"]:Clone()
			hitSound2.TimePosition = 0.3
			hitSound2.Parent = Handle
			hitSound2.PlaybackSpeed = 1.9 * math.random(900,1100) / 1000
			hitSound2:Play()
			game.Debris:AddItem(hitSound2)
		end

		--local maxLeeway = MeleeSettings.MeleeDebounce_MaxLeeway
		--local originPlayerPing = PingTimes[sPlayer]
		--local playerPing = math.floor((math.min(originPlayerPing * 1000,maxLeeway) / 1000) * 1000) / 1000

		--	playerPing = Lerp(0,0.25,playerPing/ (maxLeeway / 1000))
		--if playerPing < 0.3 then
		--	playerPing = 0
		--end

		delay(cL.DebounceTime,function()
			SlashDB.Value = false
		end)
		
		if swingSpecialType and cL.CustomCooldown then
			local val = Values:FindFirstChild("slashCooldown_"..sNum)
			if val then
				val.Value = true
				task.delay(cL.CustomCooldown, function()
					val.Value = false
				end)
			end
		end

		local dTime = cL.SwingTime + cL.SwingWait
		if cL.DebounceTime > dTime then 
			dTime = cL.DebounceTime
		end

		dTime = dTime * 0.5

		_G.AffectChar(sCharacter,"NRG",dTime)

		delay(cL.SwingWait,function()
			local tPart = GetTing(cL["Hitter"],sCharacter)
			if tPart and config and config.TrailEnabled and tPart:FindFirstChild("Trail") then
				if tPart.Trail:IsA("Folder") then
					for i,v in pairs(tPart.Trail:GetChildren()) do
						if v:IsA("Trail") then
							v.Enabled=true
						end
					end
				else
					tPart.Trail.Enabled = true
				end
			end
			delay(cL.SwingTime,function()
				if tPart and tPart.Parent and config and config.TrailEnabled and tPart:FindFirstChild("Trail") then
					if tPart.Trail:IsA("Folder") then
						for i,v in pairs(tPart.Trail:GetChildren()) do
							if v:IsA("Trail") then
								v.Enabled=false
							end
						end
					else
						tPart.Trail.Enabled = false
					end
				end

				--				delay(cL.ComboEndTime,function()
				--					if sCode == cCode then
				--						lastHitChar = nil
				--					end
				--				end)
				delay(2,function()
					_G.ZaWarudoWait()
					wait()
					if swingTables and swingTables[cCode] then
						swingTables[cCode] = nil
					end
					if sCode == cCode  and nMelee then
						--print("ended combo lol")
						Slashing1.Value = false
						nMelee.ComboCount = 0
						nMelee.DidHit = false
						nMelee.SwingNum = 0
					end
				end)
			end)
		end)

		return cCode,sNum
	end

	function nMelee:ExecuteFunc(sCharacter)
		if disconnected then return end
		if SlashDB.Value then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed then return end
		if customs.DoorKickDB then return end
		if customs.Reviving then return end
		if customs.Thrown then return false end

		if not config.ExecuteSettings.Enabled then return false end

		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter)) or _G.CheckIfFlinching(sCharacter) then return nil end

		local sHumanoid,sRoot,sTorso =	sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")

		local function executeCheck()
			local g = false
			local Point1 = sRoot.Position - Vector3.new(3,3,3)
			local Point2 = sRoot.Position + Vector3.new(3,2,3)
			local Region = Region3.new(Point1,Point2)
			for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},100)) do
				local gChar = Part.Parent
				if gChar ~= sCharacter
					and Part.Name == "Torso"
					and gChar:FindFirstChild("Humanoid") 
					--and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead 
					and (_G.DownedCheck(gChar) or gChar:FindFirstChild("Humanoid").Health <=0)
				then
					return gChar
				end
			end
			return false
		end

		local executeChar = executeCheck()

		if not executeChar then return false end
		if not StaminaFunctionBind:Invoke(Players:GetPlayerFromCharacter(sCharacter),config.ExecuteSettings.StaminaUsage) then return end

		SlashDB.Value = true
		Slashing1.Value = true
		ExecuteValue.Value = true

		local cCode = math.random()
		local cL = deepCopy(config.Mains["E"])

		local fsm = rValues.FinishSpeedMulti.Value
		if config.Customs.NoFinishSpeedMulti then
			fsm = 3
		end

		cL.SwingWait /= fsm
		cL.SwingTime /= fsm
		cL.DebounceTime /= fsm

		_G.AffectChar(sCharacter,"ADT",cL.DebounceTime)

		local tab = deepCopy(defaultSwingTable)
		tab.cST = "Execute"
		tab.Code = cCode
		tab.StartTick = tick()
		swingTables[cCode] = deepCopy(tab)


		local dTime = cL.SwingTime + cL.SwingWait
		if cL.DebounceTime > dTime then 
			dTime = cL.DebounceTime
		end
		dTime = dTime * 0.5

		_G.AffectChar(sCharacter,"NRG",dTime)

		--executeAnim = NewAnim(sHumanoid,"Finish")
		--executeAnim:Play(0.125)
		lCharacter = sCharacter

		local sPart = GetTing(cL["SoundPart"],sCharacter)

		if Tool:GetAttribute("voidedge") then
			local sDir = game:GetService("ServerStorage"):WaitForChild("Storage").VoidDirectory
			local sound = sDir["Execute"]:Clone()
			game.Debris:AddItem(sound,sDir["Execute"].TimeLength)
			sound.Parent = sPart
			sound:Play()

			local sound2 = sDir["Start"]:Clone()
			game.Debris:AddItem(sound2,sDir["Start"].TimeLength)
			sound2.Parent = sPart
			sound2:Play()
		else
			PlaySound2(Tool,"Execute",sPart)
			PlaySound2(Tool,"Execute2",sPart)
		end

		if Tool:GetAttribute("goldenkatana") then
			local hitSound2 = script["Ching"]:Clone()
			hitSound2.Parent = Handle
			hitSound2:Play()
			game.Debris:AddItem(hitSound2)
		end

		if config.Customs.ExecuteResistance then
			local damageReduction: NumberValue = framework.Gs.Create("NumberValue", "BDRM_EXECUTE", _G.GVF(sCharacter.Name).Currents)
			damageReduction.Value = config.Customs.ExecuteResistance
			framework.services.TweenService:Create(damageReduction, TweenInfo.new((cL.SwingWait + cL.SwingTime)*3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15), {Value = 0}):Play()
			_G.SafeDestroy(damageReduction, (cL.SwingWait + cL.SwingTime)*3.5)
		end

		delay(cL.DebounceTime - 0.15,function()
			SlashDB.Value = false
			ExecuteValue.Value = false
		end)	

		delay(cL.SwingWait,function()
			local tPart = GetTing(cL["Hitter"],sCharacter)
			if tPart and config and config.TrailEnabled and tPart:FindFirstChild("Trail") then
				if tPart.Trail:IsA("Folder") then
					for i,v in pairs(tPart.Trail:GetChildren()) do
						if v:IsA("Trail") then
							v.Enabled=true
						end
					end
				else
					tPart.Trail.Enabled = true
				end
			end
			delay(cL.SwingTime,function()
				if tPart and config and config.TrailEnabled and tPart:FindFirstChild("Trail") then
					if tPart.Trail:IsA("Folder") then
						for i,v in pairs(tPart.Trail:GetChildren()) do
							if v:IsA("Trail") then
								v.Enabled=false
							end
						end
					else
						tPart.Trail.Enabled = false
					end
				end			
			end)
		end)

		delay((cL.SwingWait + cL.SwingTime) * 3,function()
			if swingTables and swingTables[cCode] then
				swingTables[cCode] = nil
			end
		end)

		if _G.FlinchChar then
			_G.FlinchChar(executeChar,executeChar:FindFirstChild("Humanoid"),3)
		end

		local sPlr = Players:GetPlayerFromCharacter(sCharacter)

		if config.Customs["SlayersFinishStart"] then
			local sfF = ServerStorage.Storage.Other.SlayersFinish

			local dummy = sfF.SlayersDummy:Clone()
			local dhum = dummy:FindFirstChildOfClass("Humanoid")
			game.Debris:AddItem(dummy,3)

			for i,v in pairs(dummy:GetChildren()) do
				if v:IsA("BasePart") then
					pcall(function()
						v.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId("No-Collide5")
					end)
				end
			end

			local droot = dummy:FindFirstChild("HumanoidRootPart")
			droot.CFrame = sCharacter.HumanoidRootPart.CFrame

			dummy.Parent = workspace.Debris
			droot.Anchored = false
			if droot:CanSetNetworkOwnership() then
				droot:SetNetworkOwner(sPlr)
			end

			for i,v in pairs(dummy:GetDescendants()) do
				if v:IsA("BasePart") then
					pcall(function()
						local t = v.Transparency
						v.Transparency = 1
						TS:Create(v,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency = t}):Play()
					end)
				end
			end

			local s = sfF.Summon:Clone()
			s.Parent = droot
			s:Play()

			local anim = dhum:LoadAnimation(sfF.Idle)
			anim:Play(0.3)

			local gyro = droot.BodyGyro
			local bpos = droot.BodyPosition
			local function updateGyro()

				local x1,y1,z1 = sCharacter.HumanoidRootPart.CFrame:ToEulerAnglesXYZ()
				local x2,y2,z2 = sCharacter.Torso.CFrame:ToEulerAnglesXYZ()
				local cf = CFrame.new(sCharacter.Torso.Position) * CFrame.fromEulerAnglesXYZ(x1,y1,z1) 

				gyro.CFrame = cf
				bpos.Position = cf.Position
			end
			updateGyro()

			local t = tick()

			delay(1.5,function()
				for i,v in pairs(dummy:GetDescendants()) do
					if v:IsA("BasePart") then
						pcall(function()
							TS:Create(v,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency = 1}):Play()
						end)
					end
				end
			end)

			spawn(function()
				while droot and droot.Parent and sCharacter.Parent and sCharacter:FindFirstChild("HumanoidRootPart") do
					updateGyro()
					RunService.Heartbeat:Wait()
				end
			end)
		end

		return cCode
	end

	function nMelee:CancelExecuteFunc()
		if not ExecuteValue.Value then return end
		ExecuteValue.Value = false

		swingTables = {}
		Slashing1.Value = false
		SlashDB.Value = false

		--StopSound(Handle,"Execute")

		if lCharacter and lCharacter.Parent and lCharacter:FindFirstChild("Humanoid") then
			for _,v in pairs(lCharacter:FindFirstChild("Humanoid"):GetPlayingAnimationTracks()) do
				local a = v.Animation
				for _,z in pairs(animsDir:GetChildren()) do
					if z.Name == "Finish" and z.AnimationId == a.AnimationId then
						v:Stop(0.2)
						break
					end
				end
			end
		end

		if executeAnim then
			executeAnim:Stop(0.2)
			executeAnim = nil
		end		
	end

	function nMelee:ReviveFunc(sCharacter)
		if not config.Customs["Revive"] then return end

		if disconnected then return end
		if SlashDB.Value then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed then return end
		if customs.DoorKickDB then return end
		if customs.Reviving then return end
		if Tool.Parent ~= sCharacter then return end
		--if ReplicatedStorage.LegacyDowningSystem.Value then return end

		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter)) or _G.CheckIfFlinching(sCharacter) then return nil end

		local sPlr,sHumanoid,sRoot,sTorso = Players:GetPlayerFromCharacter(sCharacter),sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")

		local function reviveCheck()
			local g = false
			local Point1 = sRoot.Position - Vector3.new(3,3,3)
			local Point2 = sRoot.Position + Vector3.new(3,2,3)
			local Region = Region3.new(Point1,Point2)
			for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},100)) do
				local gChar = Part.Parent
				if gChar ~= sCharacter
					and Part.Name == "Torso"
					and gChar:FindFirstChild("Humanoid") 
					and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead 
					and _G.DownedCheck(gChar)
					and _G.GVF(gChar.Name)
					and _G.GVF(gChar.Name).Grabbed.Value == false
					and not _G.GVF(gChar.Name).Currents:FindFirstChild("Reviving")
					and not _G.LimbCheck(gChar,"Head","Broken")
					and not (_G.LimbCheck(gChar,"Right Leg","Destroyed") and _G.LimbCheck(gChar,"Left Leg","Destroyed"))
					and not (_G.GVF(gChar.Name).Currents:FindFirstChild("POIZSKRATA") and _G.GVF(gChar.Name).Currents.POIZSKRATA.Value > 0.31)
				then
					return gChar
				end
			end
			return false
		end

		local reviveChar = reviveCheck()
		if not reviveChar then return false end

		local rHum = reviveChar:FindFirstChild("Humanoid")
		local rRoot = reviveChar:FindFirstChild("HumanoidRootPart")

		customs.Reviving = true
		customs.ReviveValue.Value = true

		local can = true

		local function Check()
			return can and customs and customs.Reviving and Tool.Parent == sCharacter and _G.DownedCheck(reviveChar) and _G.CheckIfCan(sCharacter,"Any") and not _G.CheckIfFlinching(sCharacter) and (sRoot.Position - rRoot.Position).Magnitude < 6 and rHum.Health > 0 and sHumanoid.Health > 0 and not _G.GVF(reviveChar.Name).Grabbed.Value
		end

		if not Check() then
			return
		end

		local rPlr = Players:GetPlayerFromCharacter(reviveChar)
		local HealGUI = ReplicatedStorage.Storage.GUIs.HealGUI:Clone()

		if rPlr then
			HealGUI.Parent = rPlr.PlayerGui
			HealGUI.LocalScript.Disabled = false
		end

		Destroy(customs.ReviveBG)
		customs.ReviveBG = Instance.new("BodyGyro")
		customs.ReviveBG.Name = "HealGyro"
		_G.cTag(customs.ReviveBG,"BM")
		customs.ReviveBG.MaxTorque = Vector3.new(0,15000,0)
		customs.ReviveBG.D = 200;
		customs.ReviveBG.CFrame = CFrame.new(sRoot.Position,rRoot.Position)

		customs.ReviveBG.Parent = sCharacter.HumanoidRootPart

		local anim = sHumanoid:LoadAnimation(script.ReviveAnim)
		anim:Play(0.25,1,config.Customs["Revive"].AnimSpeed)

		local RevivingVALL = _G.AffectChar(reviveChar,"Reviving",math.huge)

		local rs = script.BLoop:Clone()
		rs.Parent = sRoot
		rs:Play()

		local con0,con1,con2,con3,con4,con5,con6,con7,con8

		local function disconnect()
			if not can then return end
			can = false

			Destroy(customs.ReviveBG)
			customs.ReviveBG = nil

			con0:Disconnect()
			con1:Disconnect()
			con2:Disconnect()
			con3:Disconnect()
			con4:Disconnect()
			con5:Disconnect()
			con6:Disconnect()
			con7:Disconnect()
			con8:Disconnect()
		end

		con0 = rHum.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con1 = sHumanoid.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con2 = rRoot.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con3 = sRoot.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con4 = sCharacter.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con5 = reviveChar.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)
		con6 = Handle.AncestryChanged:Connect(function(_,parent)
			if not parent then
				disconnect()
			end
		end)

		con7 = rHum.Died:Connect(disconnect)
		con8 = sHumanoid.Died:Connect(disconnect)

		local t = tick()

		local aS = _G.AffectChar(sCharacter,"AS",math.huge)
		local aJ = _G.AffectChar(sCharacter,"AJ",math.huge)
		local sD = _G.AffectChar(sCharacter,"SD",math.huge,0,math.huge)
		local dBe = _G.AffectChar(reviveChar,"BLEOUT",math.huge)
		local aC = _G.AffectChar(sCharacter,"AC",math.huge)

		if reviveChar.HumanoidRootPart:FindFirstChild("ReviveGUI") then
			reviveChar.HumanoidRootPart:FindFirstChild("ReviveGUI").Frame.ImageLabel.ImageColor3 = Color3.new(1,1,1)
		end

		-- Revive Time

		local revive_time = config.Customs["Revive"].Time * (_G.Run("Modifier", "OtherHealMultiplier", sCharacter))

		-- Reviving

		coroutine.wrap(function()

			local t = tick()
			repeat wait(0.15)
				pcall(function()
					customs.ReviveBG.CFrame = CFrame.new(sRoot.Position,rRoot.Position)
				end)
			until not Check() or tick() - t >= revive_time

			if Check() then
				--
				_G.Run("SafeReviveSystem", sCharacter, reviveChar)
				local healerPlayerObj = PLAYERS.getPlayerBy(sPlr)
				if (healerPlayerObj and not healerPlayerObj:beenViolent()) then
					local _society = healerPlayerObj.data.player.Society
					local cooldownTick = (_society.Temp[rHum.Parent.Name.."_REVIVE"] or 0)
					if ((os.time() - cooldownTick) >= (60*10)) then
						_society.Temp[rHum.Parent.Name.."_REVIVE"] = os.time()
						healerPlayerObj:changeReputation(2, "Revived a player.")
						game.ServerStorage.Events3.AyuP:Fire("KLJ8902209SANK8234LDFG0OKJAKA984231ZZ04LGXBNBZ1U912",sPlr,300)
					end
				end
				--
				local axc = reviveChar:GetAttribute("AltruismXpCooldown")
				if (axc == nil or (os.clock() - axc) >= 60) and sPlr then
					reviveChar:SetAttribute("AltruismXpCooldown", os.clock())
					_G.GivePlayerAttributeXp(sPlr, "Altruism", _G.Random(0.7, 1.1, 100))
				end
				--
				rHum.Health = 30
				local s = script.ReviveSound:Clone()
				s.Parent = rRoot
				s:Play()
				game.Debris:AddItem(s,2)

				if rPlr and not reviveDBs[rPlr] then
					local xp = 25

					--AddXP(sPlr,xp)

					--reviveDBs[rPlr] = true
					--delay(100,function()
					--	reviveDBs[rPlr] = nil
					--end)
				end
			end

			disconnect()

			if customs then
				customs.Reviving = false
				customs.ReviveValue.Value = false
			end

			if rs and rs.Parent then
				rs:Destroy()
			end

			anim:Stop(0.25)

			if aS.Parent then
				aS:Destroy()
			end
			aS = nil

			if sD.Parent then
				sD:Destroy()
			end
			sD = nil

			if aJ.Parent then
				aJ:Destroy()
			end
			aJ = nil

			if aC.Parent then
				aC:Destroy()
			end
			aC = nil

			if dBe.Parent then
				dBe:Destroy()
			end
			dBe = nil

			HealGUI:Destroy()

			cmEvent:FireClient(sPlr,"StopRevive")

			if RevivingVALL.Parent then
				RevivingVALL:Destroy()
			end
		end)()

		return true, revive_time
	end

	function nMelee:SnowballFunc(sChar,snowPart)
		if not config.Customs["Snowball"] then return end
		if customs.Snowballin then return end

		if disconnected then return end
		if SlashDB.Value then return false end
		if BlockValue.Value then return false end
		if ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed then return end
		if customs.DoorKickDB then return end
		if customs.Reviving then return end
		if not nMelee.Equipped then return end
		if typeof(snowPart) ~= "Instance" then return end

		local sPlr,sHumanoid,sRoot,sTorso = Players:GetPlayerFromCharacter(sChar),sChar:FindFirstChild("Humanoid"),sChar:FindFirstChild("HumanoidRootPart"),sChar:FindFirstChild("Torso")

		if not (_G.CheckIfCan and _G.CheckIfCan(sChar)) or _G.CheckIfFlinching(sChar) then return nil end

		if not snowPart:IsDescendantOf(workspace.Filter.Snow) or (Vector3.new(0,sRoot.Position.Y,0) - Vector3.new(0,snowPart.Position.Y,0)).Magnitude > 20 then return end

		local tim = config.Customs.Snowball.Time

		local function CHECC()
			if sHumanoid.Health <=0 or _G.DownedCheck(sChar) or _G.RagdollCheck(sChar) or _G.CheckIfFlinching(sChar,true) or not _G.CheckIfCan(sChar) then
				return false
			end
			return true
		end

		if not CHECC() then return end
		if not StaminaFunctionBind:Invoke(sPlr,config.Customs.Snowball.StaminaUsage) then return end

		customs.Snowballin = true
		customs.grabDB = true

		local aS = _G.AffectChar(sChar,"AS",tim)
		local aJ = _G.AffectChar(sChar,"AJ",tim - 0.5)
		local sD = _G.AffectChar(sChar,"SD",tim - 0.5,"SB",math.huge)
		local aC = _G.AffectChar(sChar,"AC",tim - 0.5)
		_G.AffectChar(sChar,"B",tim)

		local anim1 = sHumanoid:LoadAnimation(script.SnowballA1)	
		local speed = config.Customs["Snowball"].AnimSpeed or 1

		spawn(function()
			anim1:Play(0.05,1,speed)

			fastWaitM(tim / 4)

			if CHECC() then
				local sb = ServerStorage.Tools.Snowball:Clone()
				sb.StartUp.Value = true

				sb.Parent = sPlr.Backpack
				sHumanoid:EquipTool(sb)

				local anim2 = sHumanoid:LoadAnimation(script.SnowballA2)
				anim2:Play(0.25,1,speed)

				fastWaitM(tim - (tim / 4))
			end

			customs.Snowballin = false
			customs.grabDB = false
		end)


		return true,config.Customs["Snowball"].Time
	end
	
	function nMelee.ZapStopFunc(notify)
		local z = customs and customs.ZapData
		if not z then return end

		customs.ZapData = nil
		customs.Zapping = false
		z.running = false

		for _,e in ipairs(z.effects) do
			if e.Parent then
				e.Enabled = false
				game.Debris:AddItem(e,1)
			end
		end
		for _,m in ipairs(z.misc) do
			if m.Parent then
				game.Debris:AddItem(m,2)
			end
		end
		if z.scream and z.scream.Parent then
			game.Debris:AddItem(z.scream,1)
		end
		if z.anim then
			z.anim:Stop(0.5)
		end
		if z.heartbeat then
			z.heartbeat:Disconnect()
		end

		if notify and z.sPlr and z.sPlr.Parent then
			cmEvent:FireClient(z.sPlr,"ZapStop")
		end
		return true
	end
	
	function nMelee.TryBattery(owner)
		local zc = config and config.Customs["Zap"]
		local charge = Values and Values:FindFirstChild("ZapCharge")
		if not (zc and charge and owner) or charge.Value > 0 then return false end

		local name = zc.Battery or "val_battery"
		local bat = (owner:FindFirstChild("Backpack") and owner.Backpack:FindFirstChild(name))
			or (owner.Character and owner.Character:FindFirstChild(name))
		if not bat then return false end

		bat:Destroy()
		charge.Value = zc.MaxCharge or 100
		return true
	end
	
	function nMelee:ZapEscapeFunc(sCharacter)
		local zc = config.Customs["Zap"]
		local charge = Values:FindFirstChild("ZapCharge")
		if not (zc and charge) or disconnected or customs.ZapEscapeDB then return end

		-- must actually be the Bottom of a running sequence
		local rg = sCharacter:FindFirstChild("ReceivingGifts")
		local top = rg and rg.Value
		if not (typeof(top) == "Instance" and top.Parent and top:FindFirstChild("Gifting") and top.Gifting.Value == sCharacter) then return end
		if top:FindFirstChild("ForceEnd") then return end

		local sPlr = Players:GetPlayerFromCharacter(sCharacter)

		if charge.Value <= 0 then
			nMelee.TryBattery(sPlr)
		end
		if charge.Value <= 0 then return end

		customs.ZapEscapeDB = true
		task.delay(3,function()
			if customs then customs.ZapEscapeDB = false end
		end)

		charge.Value = math.max(0, charge.Value - (zc.HitCost or 10))

		-- end the sequence early (the loop checks for this every frame)
		local fe = Instance.new("Model")
		fe.Name = "ForceEnd"
		fe.Parent = top
		game.Debris:AddItem(fe,2)

		task.spawn(function()
			-- wait for the sequence to clean up (Gifting value and GoonFF forcefield removed)
			local t = tick()
			while tick() - t < 4 and top.Parent and (top:FindFirstChild("Gifting") or top:FindFirstChild("GoonFF")) do
				task.wait(0.1)
			end

			local hum = top.Parent and top:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 or top:FindFirstChildOfClass("ForceField") then return end

			_G.TagChar(top,sPlr,30,15,nil,Tool.Name,0)
			
			_G.AffectChar(top,"Stunned",zc.EscapeStunDuration or 5)
			if _G.SMains and not hum:GetAttribute("NoMeleeKnock") then
				_G.SMains.RagdollChar(top,zc.EscapeStunDuration or 5)
			end
			
			local TIME = zc.ShockDuration or 1
			if top:FindFirstChild("Taze") then
				top.Taze.Duration.Value = TIME
			else
				local TS = ServerStorage.Tools.Taze:Clone()
				TS.Duration.Value = TIME
				TS.Ragdoll.Value = false
				TS.Parent = top
			end
		end)

		return true
	end

	function nMelee:ZapStartFunc(sCharacter,targetChar)
		local zc = config.Customs["Zap"]
		if not zc then return end
		if disconnected or not nMelee.Equipped then return end
		if SlashDB.Value or BlockValue.Value or ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed or customs.DoorKickDB or customs.Reviving or customs.Zapping or customs.Thrown then return end
		if typeof(targetChar) ~= "Instance" or not targetChar:IsA("Model") or targetChar == sCharacter then return end
		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter)) or _G.CheckIfFlinching(sCharacter) then return end

		local sPlr = Players:GetPlayerFromCharacter(sCharacter)
		local sHum = sCharacter:FindFirstChild("Humanoid")
		local myRoot = sCharacter:FindFirstChild("HumanoidRootPart")
		local rightArm = sCharacter:FindFirstChild("Right Arm")

		local hum = targetChar:FindFirstChildOfClass("Humanoid")
		local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local tTorso = targetChar:FindFirstChild("Torso")
		if not (sHum and myRoot and rightArm and hum and tRoot and tTorso) or hum.Health <= 0 then return end
		if (tRoot.Position - myRoot.Position).Magnitude > zc.Range then return end
		if targetChar:FindFirstChildOfClass("ForceField") then return end
		local charge = Values:FindFirstChild("ZapCharge")
		if charge and charge.Value <= 0 and not nMelee.TryBattery(sPlr) then return end

		local hPlr = Players:GetPlayerFromCharacter(targetChar)
		if sPlr and _G.TeamCheck and _G.TeamCheck(sPlr,hPlr) then return end
		if not zc.Fatal and _G.DownedCheck and _G.DownedCheck(targetChar) then return end

		local zapDir = Tool:FindFirstChild("ZapStuff") or ServerStorage.Storage.ForceChokeDirectory.Stuff.ZapStuff

		local z = {running = true, effects = {}, misc = {}, sPlr = sPlr}
		customs.ZapData = z
		customs.Zapping = true

		_G.CombatTagChar(sPlr,30,"ML")

		-- particles
		for _,partName in ipairs({"Head","Left Arm","Right Arm","Torso","Left Leg","Right Leg"}) do
			local part = targetChar:FindFirstChild(partName)
			if part then
				if partName == "Torso" then
					for _,n in ipairs({"GlowP","Lightning2P","PointLightP"}) do
						local e = zapDir[n]:Clone()
						e.Parent = part
						e.Enabled = true
						table.insert(z.effects,e)
					end
				else
					local e = zapDir.LightningP:Clone()
					e.Parent = part
					e.Enabled = true
					table.insert(z.effects,e)
				end
			end
		end

		-- beam
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0,-1,0)
		a0.Parent = rightArm
		local a1 = Instance.new("Attachment")
		a1.Parent = tTorso
		table.insert(z.misc,a0)
		table.insert(z.misc,a1)

		local beam = zapDir.Beam0:Clone()
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Parent = myRoot
		beam.Enabled = true
		table.insert(z.effects,beam)

		z.heartbeat = RunService.Heartbeat:Connect(function()
			if beam.Parent then
				beam.TextureSpeed = math.random(4,15)
				beam.Width0 = math.random(3,6)
				beam.Width1 = math.random(3,6)
				beam.CurveSize0 = math.random(-4,4)
			end
		end)

		-- sounds
		local s1 = zapDir.ZapStart:Clone()
		local s2 = zapDir.ZapLoop:Clone()
		s1.Parent = tTorso
		s2.Parent = tTorso
		s1:Play()
		s2:Play()
		table.insert(z.misc,s1)
		table.insert(z.misc,s2)

		local scream = zapDir.ZapScreaming:Clone()
		scream.Parent = targetChar:FindFirstChild("Head") or tTorso
		scream:Play()
		scream.TimePosition = math.random(1,300) / 100
		z.scream = scream

		-- victim animation
		local anim = hum:LoadAnimation(zapDir.ZapAnimation)
		anim.Priority = Enum.AnimationPriority.Action4
		anim:Play(0.1,0.65,2)
		anim.TimePosition = math.random(1,30) / 10
		z.anim = anim
		
		local lastStun = tick()
		_G.AffectChar(targetChar,"Stunned",zc.StunDuration or 2)
		if _G.SMains and not hum:GetAttribute("NoMeleeKnock") then
			_G.SMains.RagdollChar(targetChar,zc.StunDuration or 2)
		end
		-- damage loop
		task.spawn(function()
			while z.running and customs and customs.ZapData == z do
				if not (targetChar.Parent and hum.Health > 0 and tRoot.Parent and myRoot.Parent and sHum.Health > 0) then break end
				local mag = (tRoot.Position - myRoot.Position).Magnitude
				if mag > (zc.BreakRange or zc.Range) then break end
				if not zc.Fatal and _G.DownedCheck and _G.DownedCheck(targetChar) then break end
				if charge and charge.Value <= 0 then break end

				local dmg = zc.DamagePerTick
				if not zc.Fatal and hum.Health - dmg <= 15 then
					dmg = hum.Health - 14
				end
				if dmg <= 0 then break end

				_G.TagChar(targetChar,sPlr,30,15,nil,Tool.Name,mag)
				hum:TakeDamage(dmg)

				if tick() - lastStun >= (zc.StunDuration or 2) - 0.5 then
					lastStun = tick()
					_G.AffectChar(targetChar,"Stunned",zc.StunDuration or 2)
					if _G.SMains and not hum:GetAttribute("NoMeleeKnock") then
						_G.SMains.RagdollChar(targetChar,zc.StunDuration or 2)
					end
				end

				if charge then
					charge.Value = math.max(0, charge.Value - (zc.DrainPerSecond or 15) * zc.TickTime)
					if charge.Value <= 0 then
						nMelee.TryBattery(sPlr)
					end
				end

				task.wait(zc.TickTime)
			end
			if customs and customs.ZapData == z then
				nMelee.ZapStopFunc(true)
			end
		end)

		return true
	end

	-- ===== BACKSTAB / STALK =====
	function nMelee.StalkStep(sCharacter,sneakV,camV,dt)
		local bc = config.Customs["Backstab"]
		local stalk = customs.Stalk
		local maxT = bc.StalkTime or 3

		if not sneakV.Value then
			if next(stalk) then customs.Stalk = {} end
			return
		end

		local camCF = camV.Value
		local sRoot = sCharacter:FindFirstChild("HumanoidRootPart")
		local sHead = sCharacter:FindFirstChild("Head")
		if not (sRoot and sHead and typeof(camCF) == "CFrame") then return end

		local gain = dt
		if _G.CharHasTrait and _G.CharHasTrait(sCharacter,"spyagent") then gain *= 4 end

		local ignore = {}
		for _,n in ipairs({"Characters","Filter","Debris"}) do
			local f = workspace:FindFirstChild(n)
			if f then table.insert(ignore,f) end
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore

		for model in pairs(stalk) do
			if not model.Parent then stalk[model] = nil end
		end

		for _,o in ipairs(workspace.Characters:GetChildren()) do
			local oRoot = o:FindFirstChild("HumanoidRootPart")
			local oHum = o:FindFirstChildOfClass("Humanoid")
			if o ~= sCharacter and oRoot and oHum then
				if oHum.Health <= 0 then
					stalk[o] = nil
				else
					local odot = (oRoot.Position - camCF.Position).Unit:Dot(camCF.LookVector)
					local odis = (oRoot.Position - sHead.Position).Magnitude
					local blocked = workspace:Raycast(sRoot.Position,oRoot.Position - sRoot.Position,params) ~= nil
					local cur = stalk[o] or 0

					if odot >= 0.975 and odis < 256 and not blocked then
						stalk[o] = math.min(cur + gain,maxT)
					elseif cur >= maxT then
						-- fully stalked: only lost if they get far away or behind a wall
						if odis >= 256 or blocked then stalk[o] = cur - dt * 0.75 end
					elseif cur > 0 then
						stalk[o] = cur - dt
					end

					if stalk[o] and stalk[o] <= 0 then stalk[o] = nil end
				end
			end
		end
	end

	function nMelee.StalkTrackStart(sCharacter)
		local bc = config.Customs["Backstab"]
		if not bc or bc.RequireStalk == false then return end

		local vf = _G.GVF and _G.GVF(sCharacter.Name)
		local sneakV = vf and vf:FindFirstChild("Sneaking")
		local camV = vf and vf:FindFirstChild("Camera")
		if not (sneakV and camV) then
			warn("Backstab: couldn't find Sneaking/Camera in the character values")
			return
		end

		local code = math.random()
		customs.StalkCode = code
		customs.Stalk = {}

		task.spawn(function()
			local last = tick()
			while customs and customs.StalkCode == code and not disconnected do
				task.wait(0.1)
				local now = tick()
				local dt = now - last
				last = now
				if customs and customs.StalkCode == code then
					nMelee.StalkStep(sCharacter,sneakV,camV,dt)
				end
			end
		end)
	end

	function nMelee.GetStalkedSet()
		local bc = config.Customs["Backstab"]
		local set = {}
		if not bc then return set end
		local maxT = (bc.StalkTime or 3) - 0.001
		for m,t in pairs(customs.Stalk or {}) do
			if t >= maxT then set[m] = true end
		end
		return set
	end

	function nMelee.BackstabCheck(sCharacter,targetChar,fromPos,stalkedSet)
		local bc = config.Customs["Backstab"]
		if not bc or customs.BackstabDB or targetChar == sCharacter then return false end

		if bc.RequireStalk ~= false then
			stalkedSet = stalkedSet or nMelee.GetStalkedSet()
			if not stalkedSet[targetChar] then return false end
		end

		local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
		if not tRoot then return false end
		local look = Vector3.new(tRoot.CFrame.LookVector.X,0,tRoot.CFrame.LookVector.Z)
		local away = Vector3.new(fromPos.X - tRoot.Position.X,0,fromPos.Z - tRoot.Position.Z)
		if look.Magnitude < 0.01 or away.Magnitude < 0.01 then return false end

		return look.Unit:Dot(away.Unit) <= -(bc.BackDot or 0.5)
	end

	function nMelee.BackstabConsume(sCharacter,targetChar)
		local bc = config.Customs["Backstab"]
		if customs.Stalk then customs.Stalk[targetChar] = nil end
		customs.BackstabDB = true
		task.delay(bc.Cooldown or 3,function()
			if customs then customs.BackstabDB = false end
		end)
		local sPlr = Players:GetPlayerFromCharacter(sCharacter)
		if sPlr then cmEvent:FireClient(sPlr,"BackstabDone",targetChar) end
	end

	-- ===== THROWING =====
	local throwData = nil

	local function ValidThrowHit(p)
		if p == workspace.Terrain then return true end
		if p.Transparency > 0.9 then return false end
		local m = p:FindFirstAncestorOfClass("Model")
		if m and m:FindFirstChildOfClass("Humanoid") then
			return p.Name ~= "HumanoidRootPart"
		end
		local map = workspace:FindFirstChild("Map")
		return p.CanCollide or (map ~= nil and p:IsDescendantOf(map))
	end

	function nMelee.ThrowCleanup()
		local d = throwData
		throwData = nil
		if d then
			if d.con then d.con:Disconnect() end
			if d.stickCon then d.stickCon:Disconnect() end
			if d.leaveCon then d.leaveCon:Disconnect() end
			if d.model then d.model:Destroy() end
		end
	end

	function nMelee.ThrowReset(silent)
		if not customs then return end
		customs.Thrown = false
		local tv = Values and Values:FindFirstChild("Thrown")
		if tv then tv.Value = false end
		if silent then
			customs.ThrowDB = false
		else
			customs.ThrowDB = true
			local tc = config and config.Customs["Throw"]
			task.delay((tc and tc.Cooldown) or 1,function()
				if customs then customs.ThrowDB = false end
			end)
		end
	end

	function nMelee.ThrowRetrieve(plr,silent)
		nMelee.ThrowCleanup()
		nMelee.ThrowReset(silent)
		local bp = plr and plr.Parent and plr:FindFirstChildOfClass("Backpack")
		if bp then
			Tool.Parent = bp
		else
			Tool:Destroy()
		end
	end

	function nMelee.ThrowHitChar(d,targetChar,hitPart,hitPos)
		local tc = config.Customs["Throw"]
		local sCharacter,sPlr = d.char,d.sPlr
		
		local downed = _G.DownedCheck and _G.DownedCheck(targetChar)
		local hum = targetChar:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end

		if targetChar:FindFirstChildOfClass("ForceField") then
			if sPlr and hum.Name ~= "NPC" then
				EVENTS.ClientWarn:FireClient(sPlr,{"Player is protected!",1.5,Color3.fromRGB(255,121,121),Color3.new(0,0,0),"lost"})
			end
			return
		end

		local hPlr = Players:GetPlayerFromCharacter(targetChar)
		if sPlr and _G.TeamCheck and _G.TeamCheck(sPlr,hPlr) then return end
		if sPlr and DAMAGE.PlayerCanDamage and not DAMAGE.PlayerCanDamage(nil,sPlr,hum) then return end

		local dir = d.vel.Magnitude > 0 and d.vel.Unit or Vector3.new(0,0,-1)
		local mag = (hitPos - d.origin).Magnitude

		local dmg = tc.Damage or config.Damage
		local minD = tc.MinDamageMulti or 0.6
		dmg *= minD + (1 - minD) * (d.charge or 1)
		if downed then
			dmg = dmg / MeleeSettings.DownedDmgDiv
			if config.DownedMulti then dmg = dmg * config.DownedMulti end
		end
		if hitPart.Name == "Head" then dmg *= (tc.HeadMulti or 1.5) end

		local vf = _G.GVF(targetChar.Name)
		if vf and vf:FindFirstChild("MeleeProof") then
			local mp = vf.MeleeProof:FindFirstChild(hitPart.Name)
			if mp then dmg *= mp.Value end
		end

		local bc = config.Customs["Backstab"]
		local isBackstab = false
		if bc and tc.CanBackstab and not downed then
			if nMelee.BackstabCheck(sCharacter,targetChar,hitPos - dir * 10,d.stalked) then
				isBackstab = true
				nMelee.BackstabConsume(sCharacter,targetChar)
				dmg *= (bc.Multi or 2.5)
				if bc.Lethal then dmg = hum.MaxHealth + 10 end
			end
		end

		if not downed and not tc.Fatal and not (isBackstab and bc.Lethal) and hum.Health - dmg <= 15 then
			dmg = hum.Health - 14
		end
		
		if dmg <= 0 then return end

		if sPlr then
			_G.TagChar(targetChar,sPlr,30,15,nil,Tool.Name,mag)
			if _G.CombatTagChar then _G.CombatTagChar(sPlr,30,"ML") end
		end
		hum:TakeDamage(dmg)

		if _G.FlinchChar then
			_G.FlinchChar(targetChar,hum,tc.FlinchTime or 0.4,false,false,false,true)
		end

		pcall(function()
			local s = GetSoundFromDir("HitSounds")
			s.PlaybackSpeed *= math.random(900,1100) / 1000
			s.Parent = hitPart
			s:Play()
			game.Debris:AddItem(s,3)
		end)

		if sPlr then
			cmEvent:FireClient(sPlr,"Hitmarker",hitPart.Name == "Head",2,false)
		end
	end
	
	function nMelee.ThrowChargeCancelFunc(notifyPlr)
		if not customs or not customs.ThrowChargeT then return end
		customs.ThrowChargeT = nil
		if notifyPlr and notifyPlr.Parent then
			cmEvent:FireClient(notifyPlr,"ThrowCancel")
		end
		return true
	end

	function nMelee:ThrowChargeStartFunc(sCharacter)
		local tc = config.Customs["Throw"]
		if not tc then return end
		if disconnected or not nMelee.Equipped then return end
		if customs.Thrown or customs.ThrowDB or customs.ThrowChargeT then return end
		if SlashDB.Value or BlockValue.Value or ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed or customs.DoorKickDB or customs.Reviving or customs.Zapping then return end
		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter)) or _G.CheckIfFlinching(sCharacter) then return end

		local t = tick()
		customs.ThrowChargeT = t
		task.delay(10,function() -- safety if the release never arrives
			if customs and customs.ThrowChargeT == t then customs.ThrowChargeT = nil end
		end)
		return true
	end

	function nMelee:ThrowFunc(sCharacter,aimPos)
		local tc = config.Customs["Throw"]
		if not tc then return end
		if disconnected or not nMelee.Equipped then return end
		if customs.Thrown or customs.ThrowDB or not customs.ThrowChargeT then return end
		if SlashDB.Value or BlockValue.Value or ExecuteValue.Value then return false end
		if customs.grabDB or customs.grabbed or customs.DoorKickDB or customs.Reviving or customs.Zapping then return end
		if typeof(aimPos) ~= "Vector3" or aimPos ~= aimPos then return end
		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter)) or _G.CheckIfFlinching(sCharacter) then return end

		local sPlr = Players:GetPlayerFromCharacter(sCharacter)
		local sHum = sCharacter:FindFirstChild("Humanoid")
		local sRoot = sCharacter:FindFirstChild("HumanoidRootPart")
		if not (sPlr and sHum and sRoot and sHum.Health > 0) then return end
		if not (Handle and Handle:IsDescendantOf(Tool)) then return end
		local charge = math.clamp((tick() - customs.ThrowChargeT) / (tc.ChargeTime or 1.2),0,1)
		customs.ThrowChargeT = nil
		local minS = tc.MinSpeedMulti or 0.3
		local speed = (tc.Speed or 140) * (minS + (1 - minS) * charge)
		if not StaminaFunctionBind:Invoke(sPlr,tc.StaminaUsage or 15) then return end

		customs.ThrowDB = true
		customs.Thrown = true
		local tv = Values:FindFirstChild("Thrown")
		if tv then tv.Value = true end

		task.delay(tc.ReleaseDelay or 0.15,function()
			if disconnected or not customs or not nMelee then return end
			if not nMelee.Equipped or sHum.Health <= 0 or not sRoot.Parent or _G.CheckIfFlinching(sCharacter) then
				nMelee.ThrowReset(true)
				return
			end

			-- which part's hurtbox points to use (same part the swings use)
			local pointName = tc.PointName or "DmgPoint"
			local hitterObj = Handle
			local hs = tc.Hitter or (config.Mains["S1"] and config.Mains["S1"].Hitter)
			if hs and hs[1] == "Tool" then
				hitterObj = (hs[2] == "ALL_MODEL" and Tool) or Tool:FindFirstChild(hs[2],true) or Handle
			end

			-- build the projectile from the tool's parts
			local model = Instance.new("Model")
			model.Name = Tool.Name .. "_Thrown"
			local main
			local points = {}

			for _,p in ipairs(Tool:GetDescendants()) do
				if p:IsA("BasePart") then
					local isHit = hitterObj == Tool or p == hitterObj or p:IsDescendantOf(hitterObj)
					if p == Handle or p.Transparency < 0.95 or isHit then
						local c = p:Clone()
						if c then
							for _,x in ipairs(c:GetDescendants()) do
								if x:IsA("BasePart") or x:IsA("JointInstance") or x:IsA("WeldConstraint")
									or x:IsA("Constraint") or x:IsA("LuaSourceContainer") or x:IsA("Sound")
									or x:IsA("ProximityPrompt") then
									x:Destroy()
								end
							end
							c.Anchored = true
							c.CanCollide = false
							c.CanTouch = false
							c.CanQuery = false
							c.Parent = model
							if isHit then
								for _,a in ipairs(c:GetDescendants()) do
									if a:IsA("Attachment") and a.Name == pointName then
										table.insert(points,a)
									end
								end
							end
							if p == Handle then main = c end
						end
					end
				end
			end
			main = main or model:FindFirstChildWhichIsA("BasePart")
			if not main then
				model:Destroy()
				nMelee.ThrowReset(true)
				return
			end
			model.PrimaryPart = main
			if #points == 0 then
				warn(Tool.Name .. ": no '" .. pointName .. "' attachments found on the hitter, throw hits use the weapon's centre")
			end

			local origin = sRoot.Position + Vector3.new(0,1.5,0) + sRoot.CFrame.LookVector * 1.5
			local dir = aimPos - origin
			if dir.Magnitude < 1 then dir = sRoot.CFrame.LookVector end
			dir = dir.Unit

			local o = tc.Orientation or Vector3.new()
			local orient = CFrame.Angles(math.rad(o.X),math.rad(o.Y),math.rad(o.Z))

			local d = {
				model = model, char = sCharacter, sPlr = sPlr,
				origin = origin, pos = origin, vel = dir * speed, charge = charge,
				t0 = tick(), angle = 0, landed = false,
				stalked = nMelee.GetStalkedSet(), -- snapshot before the tool leaves your hands
			}
			throwData = d

			model:PivotTo(CFrame.lookAt(origin,origin + dir) * orient)
			model.Parent = workspace:FindFirstChild("Debris") or workspace

			-- the weapon really leaves the inventory (HoldingTools is allowed by the melee ancestry check)
			local holding = ServerStorage:FindFirstChild("HoldingTools")
			if not holding then
				holding = Instance.new("Folder")
				holding.Name = "HoldingTools"
				holding.Parent = ServerStorage
			end
			Tool.Parent = holding

			d.leaveCon = Players.PlayerRemoving:Connect(function(p)
				if p == sPlr and throwData == d and not tc.RetrieveByAnyone then
					nMelee.ThrowCleanup()
					Tool:Destroy()
				end
			end)

			-- swing hurtbox: sweep every point from its last position to its current one
			local pts = (#points > 0) and points or {main}
			local function Pos(obj)
				return obj:IsA("Attachment") and obj.WorldPosition or obj.Position
			end
			local last = {}
			for i,pt in ipairs(pts) do last[i] = Pos(pt) end

			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {sCharacter,model}
			params.IgnoreWater = true

			local function Cast(from,to)
				local v = to - from
				if v.Magnitude < 0.001 then return nil end
				for _ = 1,6 do
					local r = workspace:Raycast(from,v,params)
					if r and not ValidThrowHit(r.Instance) then
						local list = params.FilterDescendantsInstances
						table.insert(list,r.Instance)
						params.FilterDescendantsInstances = list
					else
						return r
					end
				end
			end

			local function Land(result,point)
				d.landed = true
				d.con:Disconnect()
				d.con = nil

				local hit = result.Instance
				local vdir = d.vel.Magnitude > 0 and d.vel.Unit or Vector3.new(0,0,-1)

				local hitChar = hit:FindFirstAncestorOfClass("Model")
				local hum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
				if hum and hitChar ~= sCharacter then
					local ok,err = pcall(nMelee.ThrowHitChar,d,hitChar,hit,result.Position)
					if not ok then warn(err) end
				end

				-- stick: keep the exact in-air rotation, only slide so the point that hit sits on the surface
				model:PivotTo(model:GetPivot() + (result.Position - point) + vdir * (tc.StickDepth or 0.3))

				if not hit.Anchored then
					-- moving target (a player's body part, a loose object): weld on so it travels with them
					for _,p in ipairs(model:GetChildren()) do
						if p:IsA("BasePart") then
							p.Massless = true
							if p ~= main then
								local w = Instance.new("WeldConstraint")
								w.Part0 = main
								w.Part1 = p
								w.Parent = main
							end
						end
					end
					local w = Instance.new("WeldConstraint")
					w.Part0 = hit
					w.Part1 = main
					w.Parent = main
					for _,p in ipairs(model:GetChildren()) do
						if p:IsA("BasePart") then p.Anchored = false end
					end
					-- if the limb gets removed, freeze the weapon where it is
					d.stickCon = hit.AncestryChanged:Connect(function()
						if model.Parent and not hit:IsDescendantOf(workspace) then
							for _,p in ipairs(model:GetChildren()) do
								if p:IsA("BasePart") then p.Anchored = true end
							end
						end
					end)
				end

				local prompt: ProximityPrompt = framework.Gs.Create("ProximityPrompt", "keyboardPrmpt", main)
				prompt.ActionText = ""
				prompt.ObjectText = ""
				prompt.HoldDuration = 1
				prompt.MaxActivationDistance = 8
				prompt.RequiresLineOfSight = false
				prompt.Style = Enum.ProximityPromptStyle.Custom
				prompt.Parent = main
				prompt.Triggered:Connect(function(plr)
					if throwData ~= d then return end
					if plr == sPlr or tc.RetrieveByAnyone then
						nMelee.ThrowRetrieve(plr)
					end
				end)

				if tc.ReturnTime then
					task.delay(tc.ReturnTime,function()
						if throwData == d then nMelee.ThrowRetrieve(sPlr) end
					end)
				end
			end

			d.con = RunService.Heartbeat:Connect(function(dt)
				if not nMelee or throwData ~= d or d.landed then return end
				dt = math.min(dt,0.1)

				d.vel += Vector3.new(0,-workspace.Gravity * (tc.Gravity or 0.15) * dt,0)
				d.pos += d.vel * dt
				d.angle += (tc.SpinSpeed or 0) * dt
				model:PivotTo(CFrame.lookAt(d.pos,d.pos + d.vel) * orient * CFrame.Angles(d.angle,0,0))

				local best,bestFrac,bestPoint
				for i,pt in ipairs(pts) do
					local now = Pos(pt)
					local prev = last[i] or now
					local r = Cast(prev,now)
					if r then
						local frac = (r.Position - prev).Magnitude / math.max((now - prev).Magnitude,0.001)
						if not best or frac < bestFrac then
							best,bestFrac,bestPoint = r,frac,now
						end
					end
					last[i] = now
				end

				if best then
					Land(best,bestPoint)
					return
				end

				if tick() - d.t0 > (tc.MaxFlightTime or 4)
					or (d.pos - d.origin).Magnitude > (tc.MaxRange or 250)
					or d.pos.Y < workspace.FallenPartsDestroyHeight + 20 then
					nMelee.ThrowRetrieve(sPlr) -- missed: it comes back to your Backpack
				end
			end)
		end)

		return true
	end

	function nMelee:CancelReviveFunc()
		customs.ReviveValue.Value = false
		customs.Reviving = false		
	end

	function nMelee:Flinch(sChar,isGun,dCancel)
		nMelee.CancelExecuteFunc()

		if (not isGun) or dCancel then
			nMelee.BlockStopFunc()
			nMelee.DoorKickCancel()
		end

		nMelee.PickupHandler(sChar,"Stop")
		nMelee.ThrowChargeCancelFunc(Players:GetPlayerFromCharacter(sChar))
		nMelee.ZapStopFunc(true)
		
		if (not isGun) or dCancel then
			--for _,v in pairs(swingTables) do
			--	swingTables[v.Code].SwingNum = 0
			--end
			nMelee.ComboCount = 0
			nMelee.ResetCombo = true
		end

		if Players:GetPlayerFromCharacter(sChar) then
			cmEvent:FireClient(Players:GetPlayerFromCharacter(sChar),"Flinch",isGun)
		end
		if customs.grabAnim4 then
			customs.grabAnim4:Stop()
			customs.grabAnim4 = nil
		end
	end

	function nMelee:BlockStartFunc(sChar)
		if customs.DoorKickDB then return end
		if disconnected then return end
		if customs.Reviving then return end
		if customs.Thrown then return false end
		if not nMelee.Equipped then return end

		if customs.grabDB or customs.grabbed then return end

		if not config.BlockSettings.Enabled then return end

		if config.BlockSettings.DontCancelOnHit and Tool:FindFirstChild("NoFlinch") then
			Tool.NoFlinch.Value = true
		end

		if 
			--not _G.CheckIfFlinching(sChar,true,true) and 
			nMelee.Equipped then
			PlaySound2(Tool,"BlockStart",Handle)
			BlockValue.Value = true
			return true
		end
		return false
	end

	function nMelee:BlockStopFunc(sPlr,bHit)
		if not BlockValue.Value then return end

		if sPlr and sPlr.Parent then
			cmEvent:FireClient(sPlr,"BS",bHit)
		end

		if config.BlockSettings.DontCancelOnHit and Tool:FindFirstChild("NoFlinch") then
			Tool.NoFlinch.Value = false
		end

		PlaySound2(Tool,"BlockStop",Handle)
		BlockValue.Value = false
		return true
	end

	function nMelee:BlockHitFunc(sPlr,sCharacter)
		if not Tool:GetAttribute("voidedge") then
			if config.Sharp and Handle:FindFirstChild("Spark") then
				local sparkA = Handle.Spark:Clone()
				sparkA.Parent = Handle
				sparkA.Position = Vector3.new(-0.04,0,math.random(0,200) / 100)
				sparkA.Sparks:Emit(100)
				game.Debris:AddItem(sparkA,2)
			end
			
			if Tool:GetAttribute("EpicParry") and Handle:FindFirstChild("EpicParry") then
				for i,v in pairs(Handle.EpicParry:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v.Name)
					end
				end
			end

			if SoundsDir:FindFirstChild("BlockHitSound") then
				local hSound = SoundsDir["BlockHitSound"]:Clone()
				hSound.Pitch = hSound.Pitch * math.random(85,150) / 100
				hSound.Parent = Handle
				hSound:Play()
				game.Debris:AddItem(hSound,hSound.TimeLength)
			end
		end

		if Tool:GetAttribute("Payback") then
			--
			local storedDamage=Tool:FindFirstChild("paybackDamagePerc")
			if not storedDamage then
				storedDamage=Instance.new("DoubleConstrainedValue",Tool)
				storedDamage.Name="paybackDamagePerc"
				storedDamage.MaxValue=0.5
			end
			--
			storedDamage.Value+=0.04
			--
			if _G.SafeCheck(sCharacter) and sCharacter:FindFirstChild("Humanoid") then
				--
				local trueHealth=sCharacter.Humanoid.Health-15
				local dmgToDo=trueHealth*0.04
				--
				sCharacter.Humanoid:TakeDamage(dmgToDo)
			end
			--
		end

		spawn(function()
			StaminaFunctionBind:Invoke(sPlr,config.BlockSettings.HitStaminaUsage or -10) 
		end)

		if not config.BlockSettings.DontCancelOnHit then
			nMelee:BlockStopFunc(sPlr,true)
		else
			cmEvent:FireClient(sPlr,"BH")
		end
	end

	function nMelee:HitFunc(sCharacter,gCode,doCombo,hitter,hit,hitChar,pos1,pos2)
		if disconnected then return end
		if customs.grabDB or customs.grabbed then return end

		if customs.DoorKicking then
			--print("xd do'kin")
			return nMelee:DoorHitFunc(sCharacter,gCode,hit,hitChar)
		end

		local sPlr,sHumanoid,sRoot,sTorso = Players:GetPlayerFromCharacter(sCharacter), sCharacter:FindFirstChild("Humanoid"),sCharacter:FindFirstChild("HumanoidRootPart"),sCharacter:FindFirstChild("Torso")

		if not (swingTables and swingTables[gCode]) or swingTables[gCode].Ended then return end
		local sTable = swingTables[gCode]
		local cL = config.Mains["S" .. sTable.SwingNum] or config.Mains[sTable.SwingNum]

		if not cL then return end

		if sTable.cST == "Execute" then
			cL = deepCopy(config.Mains["E"])
			cL.SwingWait /= rValues.FinishSpeedMulti.Value
			cL.SwingTime /= rValues.FinishSpeedMulti.Value
			cL.DebounceTime /= rValues.FinishSpeedMulti.Value
		end


		if sCharacter.Humanoid.Health <= 0 and sTable.cST ~= "Execute" then return end

		if not (_G.CheckIfCan and _G.CheckIfCan(sCharacter,nil,MeleeSettings.DownedKill_Leeway,MeleeSettings.DownedKill_Leeway)) 
			--or sCharacter.Humanoid.Health <= 0 
		then return nil end
		
		local sVF = _G.GVF(sCharacter.Name)

		if not sTable.HitChars[hitChar]
			and typeof(hit) == "Instance"
			and checkHitName(hit)
			and (hit.Parent == hitChar 
				--or (Settings.CanClash and hit:FindFirstChild("Blade"))
			)

				and typeof(hitChar) == "Instance" and hitChar:IsA("Model") and hitChar:FindFirstChild("Humanoid")
				and hitChar ~= sCharacter
				and typeof(hitter) == "Instance" and hitter:IsDescendantOf(sCharacter)
		then
			local hHumanoid = hitChar:FindFirstChild("Humanoid")

			if not hHumanoid or (hHumanoid:GetState() == Enum.HumanoidStateType.Dead and sTable.cST ~= "Execute") then return end

			local hitVF = _G.GVF(hitChar.Name)

			if (hitVF and hitVF.HealthValues:FindFirstChild(hit.Name) and (hitVF.HealthValues[hit.Name].Destroyed.Value)) then
				return
			end

			local hasRBTMVB = hitVF.Currents:FindFirstChild("RBTMVB") 

			if MeleeSettings.ReverseHits or (config.Customs and config.Customs["DaReverser"]) or (hasRBTMVB and config.Customs["LTNM"] == true) then
				hitChar = sCharacter
				hHumanoid = hitChar:FindFirstChild("Humanoid")
			end

			hitVF = _G.GVF(hitChar.Name)

			local hPlr = Players:GetPlayerFromCharacter(hitChar)

			local Mag = (hit.CFrame.p - sRoot.CFrame.p).Magnitude

			if hitChar:FindFirstChildOfClass("ForceField") then 
				if hHumanoid.Name ~= "NPC" then
					EVENTS.ClientWarn:FireClient(sPlr,{"Player is protected!",1.5,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
				end
				return 
			end

			if Mag > config.MMAG + 5 then return end
			if (hit.CFrame.p.Y - sRoot.Position.Y) > config.MMAG * 0.7 and sRoot.Velocity.Y > -10 then
				return
			end

			if hitVF and hitVF.Grabbed.Value == true then return end
			if sPlr and _G.TeamCheck and _G.TeamCheck(sPlr,hPlr) then return end

			local brokeJoint = false
			local brokeKill = false

			local function Break(Name,BreakType)
				brokeJoint = true
				if hit.Name == "Head" and BreakType ~= "BoneBreak" then
					brokeKill = true
				end
				_G.BreakJoint(hit,hitChar,Name,BreakType)
			end

			local function DamageJoint(BreakType,hV,dmg,attackPlr,...)
				if hV.Value - dmg <= 0 then
					brokeJoint = true
					if hit.Name == "Head" and BreakType ~= "BoneBreak" then
						brokeKill = true
					end
				end

				--print(hit,BreakType,dmg)

				_G.DamageJoint(hit,hitChar,dmg,BreakType,nil,nil,attackPlr,nil,...)
			end

			if sTable.cST == "Execute" then 
				if _G.CheckIfFlinching(sCharacter) then return end
				if not (hHumanoid.Health <= 0 or _G.DownedCheck(hitChar)) then return end
				--				elseif slashnum ~= 3 then
				--					if not CheckIfFacing(Character.HumanoidRootPart,hit) then
				--						--return
				--					end
			end

			swingTables[gCode].HitChars[hitChar] = true

			_G.CombatTagChar(sPlr,30,"ML")

			local MHits = cL.MultipleHits or config.MultipleHits
			if MHits and MHits.Enabled then
				task.spawn(function()
					if MHits.DB and MHits.DB > 0 then
						task.wait(MHits.DB)
					end
					swingTables[gCode].HitChars[hitChar] = false
				end)
			end

			sTable.HitCount = sTable.HitCount + 1
			if sTable.cST == "Execute" or (not cL or (cL and sTable.HitCount >= cL.MaxHits)) then
				swingTables[gCode].Ended = true
			end
			sTable = swingTables[gCode]

			--if not doCombo then
			--nMelee.ComboCount = 0
			--end

			local Clashed = false
			local blockedHit = false

			local function BlockCheck()
				local hTool = hitChar:FindFirstChildOfClass("Tool")
				local cMelee = cMelees[hTool]
				if hTool and cMelee and hTool:FindFirstChild("Values") and hTool:FindFirstChild("Config") and hTool.Values:FindFirstChild("Blocking") then
					local hValues = hTool["Values"]
					local hConfig = CONFIGS[hTool.Name]
					if hConfig and hTool.Values.Blocking.Value and not (sCharacter:GetAttribute("Winds") and sCharacter:GetAttribute("Winds")>0) then
						--if hConfig.BlockSettings.Strength < config.BlockHitStrength and hTool.Name ~= Tool.Name then
						if not CanBlockCheck(Tool,hTool) then
							blockedHit = false
						elseif not CheckIfFacing(hitChar.HumanoidRootPart,sCharacter.HumanoidRootPart) then
							blockedHit = false
						else
							blockedHit = true
						end
						--					elseif hitChar:FindFirstChildOfClass("Tool") and hitChar:FindFirstChildOfClass("Tool"):FindFirstChild("Slashing") and hitChar:FindFirstChildOfClass("Tool"):FindFirstChild("Slashing").Value == true and hit:FindFirstChild("Blade") then
						--						if CheckIfFacing(hitChar.HumanoidRootPart,sCharacter.HumanoidRootPart) then
						--							Clashed = true
						--						end
					end

					local hSound
					if blockedHit or Clashed then
						Slashing1.Value = false
						swingTables[gCode].Ended = true

						cMelee:BlockHitFunc(Players:GetPlayerFromCharacter(hitChar),sCharacter)

						if _G.FlinchChar then
							local hitFlinchTime = hConfig.BlockSettings.HitFlinchTime and hConfig.BlockSettings.HitFlinchTime or 1

							if hHumanoid:GetAttribute("InfectedType") then
								hitFlinchTime += 1
							end

							_G.FlinchChar(sCharacter,sHumanoid,hitFlinchTime)
						end	
						cmEvent:FireClient(sPlr,"BH2",2)
						return true
					end
				end
			end

			if BlockCheck() then return false end
			-------------------

			local dmg = 		config.Damage	-- Initial damage
			local torsoMLDMulti = (hitVF and hitVF.MeleeProof.Torso.Value) or 1
			local dMulti = 		cL.DmgMulti		-- Damage multi
			local dMulti2 = 	cL.DmgMulti2	-- Damage multi for break limbs
			local cantChop = 	false 			-- can chop limbs
			local exDmulti = 	1				-- Execute damage multi
			local hL = 			false 			-- Hit a limb
			local cDB = 		true; 			-- Can draw blood
			local fMulti =		1				-- force multi
			local dReducMulti = 1
			local knockedChar = false
			local combodChar = false
			local playHitSound = true
			local explodedHead = false
			local dCombo = false
			local didStun = false
			local meleeProofMulti = 1;
			local isAlive = hHumanoid.Health > 0
			local isLegacyDowned = false
			-- Invoxe

			local hit_data = {from = sCharacter, who = hitChar, position = pos2, source = "Melee", cancel = false}
			hit_data = framework.invoxe.get("hit"):reach(hit_data)
			if (hit_data.cancel) then return false end
			-- Modded
			
			if (Tool:GetAttribute("ModdedDamageOverwrite")) then
				dmg = Tool:GetAttribute("ModdedDamageOverwrite") end
			-- Damage Multipliers
			
			dmg+=dmg*sVF.M_DamageMulti.Value

			dmg = dmg * _G.GetDmgMulti1(hitChar)
			--
			local reduced_dmg = dmg
			local _, bdr = _G.GetCharAffects(hitChar, "BDRM", true, 2)
			local _, bmdr = _G.GetCharAffects(hitChar, "BMDRM", true, 2)
			if (bmdr) then reduced_dmg -= (reduced_dmg * bmdr) end
			if (bdr) then reduced_dmg -= (reduced_dmg * bdr) end
			dmg = math.clamp(reduced_dmg, 0, dmg)

			local strengthPercentage = _G.GetCharAttribute(sPlr, "Strength", "percentage")
			dmg += (dmg * (0.35 * strengthPercentage))

			local endurancePercentage = _G.GetCharAttribute(hitChar, "Endurance", "percentage")
			dmg -= (dmg * (0.35 * endurancePercentage))

			if (_G.CharHasTrait(hitChar, "toughcookie")) then
				local toughCookieReduction = (_G.ToughCookieResistance(hitChar, "melee")/100)
				local protected = math.round(dmg * toughCookieReduction)
				dmg -= protected
			end

			if (_G.CharHasTrait(hitChar, "flimsyfigure")) then
				local flimsyFigureDamage = (_G.FlimsyFigureDamage(hitChar, "melee")/100)
				local damage = math.round(dmg * flimsyFigureDamage)
				dmg += damage
			end
			--
			local function ForceChar(downed,isRagdolled,forceMulti)
				delay(0.1,function()
					if hitChar.Parent and hit.Parent and hit.Velocity.Magnitude < 16 then
						local force = (CFrame.new(pos2,pos1).LookVector + cL.ForceUpVec)
						force = (force * cL.Force * fMulti)
						force+=force*sVF.M_ForceMulti.Value

						local ye = false

						local n = config.ForceNN or 2.5

						if hit.Name == "Head" then
							n = n * 2.5
						elseif hit.Name ~= "Torso" then
							n = n * 2
						end

						if brokeJoint and (downed or isRagdolled) then
							n = n * 0.5

							force = force * 0.2
						else
							if downed or isRagdolled then
								n = n * 0.85
								force = force * 0.5
							end

							if sTable.cST == "Execute" then
								force = Vector3.new(force.X * 0.5,force.Y * 0.5,force.Z * 0.5)
							end					
						end

						if sTable.cST == "Execute" then
							force = force + Vector3.new(0,12,0)
						end

						local vel = sRoot.Velocity

						local x = math.min(vel.X / 3,250)
						x = math.max(vel.X / 3,-25)

						local y = 0

						local z = math.min(vel.Z / 3,25)
						z = math.max(vel.Z / 3,-25)

						vel = Vector3.new(x,y,z)

						local mass = GetModelMassModule(hitChar)

						if hitVF then
							force = force * hitVF.WeightProof.Value
						end
						force = force * 0.4 * mass
						force = force + vel

						local cTime = cL.ForceLastTime

						if config.IgnoreACT then
							_G.cTag(hHumanoid,"CTP",3)
						end

						if forceMulti then
							force *= forceMulti
							n *= forceMulti
						end

						_G.SMains.ForceT(hit,force,n,nil,nil,cTime)
					end
				end)
			end

			_G.ZaWarudoWait()
			local downed = _G.DownedCheck(hitChar)

			if sTable.cST ~= "Execute" then
				if downed then
					--_G.AssistChar(hitChar,sPlr,30,Tool.Name,Mag)
					if not _G.DownedCheck(hitChar,1) then
						_G.AssistChar(hitChar,sPlr,30,Tool.Name,Mag)
					end
				else
					_G.TagChar(hitChar,sPlr,30,15,nil,Tool.Name,Mag)
				end

				--if not _G.DownedCheck(hitChar) or hHumanoid:GetState() == Enum.HumanoidStateType.Dead then
				--	--AddBloodSplatter("Blood" .. math.random(1,7))
				--end

				if 
					--_G.DownedCheck(hitChar) or 
					hHumanoid:GetState() == Enum.HumanoidStateType.Dead then
					---cDB = false
					dMulti = 0
					--cantChop = true

					if hHumanoid:GetState() ~= Enum.HumanoidStateType.Dead  then
						if hitChar:FindFirstChild("Health") and hitChar.Health:FindFirstChildOfClass("BindableEvent") then
							hitChar.Health:FindFirstChildOfClass("BindableEvent"):Fire()
						end
					end
				end

				if type(nMelee.SwingNum) == "number" then
					if nMelee.ComboCount < 1 and nMelee.SwingNum > 1 and config.M3HitCombo then
						dCombo = true
					end

					if not nMelee.DidHit then
						--if config.Combo.Enabled then
						--	if ((hitChar == sTable.LastHitChar or not sTable.LastHitChar) and config.Combo.OnePerson) or not config.Combo.OnePerson then
						--		nMelee.ComboCount = nMelee.ComboCount + 1
						--	end
						--elseif not swingTables[gCode].DidHit then

						if not dCombo and config.SlashStages > 2 then
							nMelee.ComboCount += 1
						end

						swingTables[gCode].LastHitChar = hitChar
						swingTables[gCode].DidHit = true
					end
				end


				sTable = swingTables[gCode]

				if config.Combo.Enabled and nMelee.ComboCount == config.SlashStages and sTable.SwingNum == config.SlashStages and not hasRBTMVB and not hitVF.NoRagdoll.Value then
					if SoundsDir:FindFirstChild("ComboHit") then
						local chs = SoundsDir["ComboHit"]:Clone()
						chs.PlaybackSpeed = chs.PlaybackSpeed * math.random(950,1050) / 1000
						chs.Parent = hitChar["HumanoidRootPart"]
						chs:Play()
						game.Debris:AddItem(chs)
						if chs:FindFirstChild("Ignore") then
							playHitSound = false
						end

						didStun = true

						if not _G.DownedCheck(hitChar) then
							_G.SMains.RagdollChar(hitChar,config.Combo.KnockTime)
							_G.AffectChar(hitChar,"Stunned",config.Combo.KnockTime)

							if hPlr and (sTable.cST == "Execute" or not downed) then
								local xp = 20
								AddXP(sPlr,xp)	
							end

							knockedChar = true
							combodChar = true
						end

						if config.Combo.Multi then
							dMulti = dMulti * config.Combo.Multi
						end

						if config.Combo.ForceMulti then
							fMulti = fMulti * config.Combo.ForceMulti
						end
					end
				end
			else
				exDmulti = 1000
				--AddBloodSplatter("BloodExecute")

				if not Tool:GetAttribute("voidedge") then
					if SoundsDir:FindFirstChild("ExecuteHit") then
						local hitSound3 = SoundsDir["ExecuteHit"]:Clone()
						if hitSound3:FindFirstChild("Ignore") then
							playHitSound = false
						end
						hitSound3.PlaybackSpeed = hitSound3.PlaybackSpeed * math.random(950,1050) / 1000
						hitSound3.Parent = hitChar["HumanoidRootPart"]
						hitSound3:Play()
						game.Debris:AddItem(hitSound3)
					end
				end

				if isAlive then
					_G.TagChar(hitChar,sPlr,30,0,nil,Tool.Name,Mag)
				end
			end

			if string.match(Tool.Name,"ZombieFists") and not hitChar:GetAttribute("IsInfected") then
				local s = ServerStorage.Tools.POISON_HANDLER:Clone()
				s.Creator.Value = sPlr
				s.Zombify.Value=true
				s.InstantStart.Value=true
				s.Parent = hitChar
			end

			if config.Customs["PoisonCharges"] then
				_G.CombatTagChar(sPlr,120,"POI_S")

				if sTable.cST ~= "Execute" then
					if config.Customs.PoisonCharges.Scream then
						_G.Scream(hitChar,hitChar["Head"],"Scream" .. math.random(1,5))
					end

					if Tool.Values.PoisonCharges.Value > 0 and not hitChar:GetAttribute("IsInfected") then
						Tool.Values.PoisonCharges.Value -= 1
						local s = ServerStorage.Tools.POISON_HANDLER:Clone()
						s.Creator.Value = sPlr
						s.Parent = hitChar
					end
				else
					Tool.Values.PoisonCharges.Value = math.min(Tool.Values.PoisonCharges.Value + (config.Customs.PoisonCharges.FinishCharges or 0),config.Customs.PoisonCharges.StartCharges)
				end
			end

			if config.Customs and config.Customs.FlameHit and not (config.Customs.Chance and math.random(1,100)>config.Customs.Chance) then
				local amount = 0
				for _,v in pairs(hitChar:GetChildren()) do
					if v:GetAttribute("BURNSCRIPT") and v:GetAttribute("BURNSCRIPT") == Tool.Name then
						amount += 1
					end
				end

				if (not config.Customs.FlameHit.MaxFire) or (amount < config.Customs.FlameHit.MaxFire) then
					local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
					sc.Time.Value = config.Customs.FlameHit.Time
					sc.Dmg.Value = config.Customs.FlameHit.DPS
					sc.CustomColor.Value=config.Customs.FlameHit.CustomColor or Color3.new()
					sc.IgnoreDowned.Value = config.Customs.FlameHit.IgnoreDowned or false
					sc.IsCursed.Value = config.Customs.FlameHit.Cursed or false
					sc.DoSkeletonDeath.Value = config.Customs.FlameHit.SkeletonEffect or false

					sc:SetAttribute("BURNSCRIPT", Tool.Name)
					task.delay(config.Customs.FlameHit.Time, function()
						sc:SetAttribute("BURNSCRIPT", nil)
					end)

					sc.Parent = hitChar
					sc.Disabled = false
				end
			end

			local parried=false
			-- Enchants

			--
			if Tool:GetAttribute("Deferred") then
				--
				dmg+=dmg*0.07
				--
				if not Tool:GetAttribute("DeferredCD") then
					Tool:SetAttribute("DeferredCD",true)
					--
					local overTimeDmg=dmg*1.17
					--
					dmg=0
					--
					task.delay(math.random(2, 5), function()
						task.spawn(function()
							for i = 1, 10 do
								if _G.SafeCheck({hitChar,hHumanoid}) and hHumanoid.Health>0 then
									hHumanoid:TakeDamage(overTimeDmg / 10)
									_G.FlinchChar(hitChar,hHumanoid,0.1,false,false,false,true)
								else
									break
								end
								task.wait(0.25)
							end
						end)
					end)
					--
					task.delay(7,function()
						Tool:SetAttribute("DeferredCD",nil)
					end)
				end
			end
			--
			if not Tool:GetAttribute("EnchantCD") then
				--
				if Tool:GetAttribute("Heroism") then
					--
					local maxHealth=sHumanoid.MaxHealth-15
					local currentHealth=sHumanoid.Health-15
					--
					local highThreshold = maxHealth * 0.75
					local lowThreshold = maxHealth * 0.25
					--
					local bonusDamage=0
					--
					if currentHealth > highThreshold then
						local overThreshold = ((currentHealth - highThreshold) / maxHealth) * 100
						bonusDamage = overThreshold * 0.8
					elseif currentHealth < lowThreshold then
						local underThreshold = ((lowThreshold - currentHealth) / maxHealth) * 100
						bonusDamage = underThreshold * 0.8
					end

					dmg = dmg * (1 + bonusDamage / 100)
					--
				end
				--
				if Tool:GetAttribute("Payback") then
					if Tool:FindFirstChild("paybackDamagePerc") and Tool.paybackDamagePerc.Value>0 and sTable.cST ~= "Execute" then
						Tool:SetAttribute("EnchantCD",true)
						--
						parried=true
						--
						dmg=dmg+(dmg*Tool.paybackDamagePerc.Value)
						Tool.paybackDamagePerc.Value=0
						--
						task.delay(10,function()
							Tool:SetAttribute("EnchantCD",nil) end)
					end
				end
				--
				if Tool:GetAttribute("Storm") then
					--
					if math.random(1,100)<=33 then
						--
						Tool:SetAttribute("EnchantCD",true)
						--
						dmg*=1.175
						--
						if hitChar:FindFirstChild("Taze") then
							hitChar.Taze.Duration.Value+=math.random(1,4)
						else
							local TS=ServerStorage.Tools.Taze:Clone()
							TS.Duration.Value=math.random(1,4)
							TS.Ragdoll.Value=false
							TS.Parent=hitChar
						end
						--
						task.delay(5,function()
							Tool:SetAttribute("EnchantCD",nil)
						end)
					end
					--
				end
				--
				if Tool:GetAttribute("Blazing") then
					--
					if math.random(1,100)<=33 then
						--
						Tool:SetAttribute("EnchantCD",true)
						--
						local dps=5
						local burntime=math.random(1,3)
						--
						if hitVF then
							local poisV = Instance.new("NumberValue")
							poisV.Name = "FROSTSKRATA"
							poisV:SetAttribute("NoIcon",true)
							poisV.Value = 0.5
							game.Debris:AddItem(poisV,burntime)
							poisV.Parent = hitVF.Currents
						end
						--
						local s1 = ServerStorage.Storage.Other.CurseFinish.ZapS:Clone()
						game.Debris:AddItem(s1,5)
						s1.Parent = hitChar.HumanoidRootPart
						s1:Play()
						--
						if hitChar:FindFirstChild("BurningScript") then
							--
							hitChar.BurningScript.Duration.Value+=burntime
							--
						else
							local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							--sc.IsFrostbite.Value = true
							sc.Time.Value = burntime
							sc.Dmg.Value = dps
							--
							sc.Parent = hitChar
							sc.Disabled = false
						end
						--
						task.delay(5,function()
							Tool:SetAttribute("EnchantCD",nil)
						end)
					end
					--
				end
				--
				if Tool:GetAttribute("Chilling") then
					--
					if math.random(1,100)<=33 then
						--
						Tool:SetAttribute("EnchantCD",true)
						--
						require(game:GetService("ServerStorage").PlantsStorage.Scripts.Effects.Chilled).apply(hitChar,{duration=_G.Random(2,5,100)})
						--
						task.delay(7,function()
							Tool:SetAttribute("EnchantCD",nil)
						end)
					end
				end
				--
				if Tool:GetAttribute("Detonation") then
					--
					if math.random(1,100)<=20 then
						--
						Tool:SetAttribute("EnchantCD",true)
						--
						local ExplodePart = ServerStorage.Projectiles.Detonation:Clone()

						ExplodePart.Creator.Value = sPlr
						local toolV = ExplodePart.Creator:FindFirstChild("Tool")
						if not toolV then
							toolV = Instance.new("StringValue")
							toolV.Name = "Tool"
							toolV.Parent = ExplodePart.Creator
						end
						local ktV = ExplodePart.Creator:FindFirstChild("KeepText")
						if not ktV then
							ktV = Instance.new("BoolValue")
							ktV.Name = "KeepText"
							ktV.Parent = ExplodePart.Creator
						end
						toolV.Value = Tool.Name .. string.format(' <font color="#ff4608"><b>[DETONATION]<\b></font>')
						ktV.Value=true

						ExplodePart.CFrame = hit.CFrame
						ExplodePart.Parent = workspace.Debris

						coroutine.wrap(function()
							RunService.Heartbeat:Wait()
							ExplodePart.Main.Disabled = false
						end)()
						--
						--
						task.delay(10,function()
							Tool:SetAttribute("EnchantCD",nil)
						end)
					end
					--
				end
				--
			end
			--
			if Tool:GetAttribute("CurseOfTheNoLifeKing") then
				local stressGain=25
				hitVF.Stress.Value += math.floor(stressGain*0.6)
				hitVF.Stress.Overtime.Value += math.floor(stressGain*0.4)
			end
			--

			if sTable.cST == "Execute" and isAlive then
				if Tool:GetAttribute("ripper") then
					local SParent = sRoot
					local SName = "Execute"
					local rageScript = ServerStorage.Storage.Scripts.Ripper:Clone()
					rageScript.Parent = sCharacter
					rageScript.Disabled = false
					local Directory = game:GetService("ServerStorage"):WaitForChild("Storage").RipDirectory
					local Sound = Directory:WaitForChild(SName):Clone()

					Sound.PlaybackSpeed = Sound.PlaybackSpeed * math.random(950,1050) / 1000
					Sound.Parent = SParent
					Sound:Play()

					game.Debris:AddItem(Sound)

					if hitChar and hitChar.Parent and hitChar:FindFirstChild("Torso") then
						local exp = ServerStorage.Projectiles["__InfectedConvulseExplosion2"]:Clone()
						exp.CFrame = hitChar.Torso.CFrame
						game.Debris:AddItem(exp,15)
						exp.Creator.Value = sPlr
						exp.Parent = workspace.Debris
						exp.Main.Disabled = false

						for _, v in pairs(hit.Parent:GetChildren()) do
							if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
								_G.DamageJoint(v,hit.Parent,1000,"Normal",nil,nil,sPlr)
							end
						end
					end
				end
				if Tool:GetAttribute("voidedge") then
					local sDir = game:GetService("ServerStorage"):WaitForChild("Storage").VoidDirectory
					local hitSound = sDir.Boom:Clone()
					hitSound.Parent = hit
					hitSound.PlaybackSpeed = hitSound.PlaybackSpeed * math.random(900,1100) / 1000
					hitSound:Play()
					game.Debris:AddItem(hitSound)

					local Fire3 = sDir.Fire3:Clone()
					Fire3.Parent = hit.Parent.Torso
					Fire3:Emit(20)
					game.Debris:AddItem(Fire3, Fire3.Lifetime.Max)

					for _, v in pairs(hit.Parent:GetChildren()) do
						if v:IsA("BasePart") then
							local Fire = sDir.Fire:Clone()
							Fire.Parent = v
							Fire:Emit(10)
							game.Debris:AddItem(Fire, Fire.Lifetime.Max)
						end
					end

					local Fire2 = sDir.Fire2:Clone()
					Fire2.Parent = hit.Parent.Torso
					Fire2:Emit(20)
					game.Debris:AddItem(Fire2, Fire2.Lifetime.Max)

					for _, v in pairs(hit.Parent:GetDescendants()) do
						if v:IsA("MeshPart") then
							v.TextureID = ""
						elseif v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Texture") or v:IsA("Decal") or v:IsA("Shirt") or v:IsA("Pants") then
							v:Destroy()
						end

						if v:IsA("BasePart") then
							v.Color = Color3.fromRGB(0, 0, 0)
							v.Material = Enum.Material.ForceField
						end
					end

					if sHumanoid and sHumanoid.Parent and sHumanoid.Health > 15 then
						sHumanoid.Health = sHumanoid.MaxHealth
					end
				end
				if Tool:GetAttribute("goldenkatana") then
					local TransformS = script:WaitForChild("Gold"):Clone()
					TransformS.TimePosition = 2.7
					TransformS.Parent = hit.Parent.Torso
					TransformS:Play()
					game.Debris:AddItem(TransformS)

					local Ching11 = script:WaitForChild("Ching"):Clone()
					Ching11.Parent = sTorso
					Ching11:Play()
					game.Debris:AddItem(Ching11)

					task.spawn(function()
						for _, v in pairs(hit.Parent:GetDescendants()) do
							if v:IsA("MeshPart") then
								v.TextureID = ""
							elseif v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Texture") or v:IsA("Decal") or v:IsA("Shirt") or v:IsA("Pants") then
								v:Destroy()
							end

							if v:IsA("BasePart") then
								v.Color = Color3.fromRGB(235, 175, 55)
								v.Material = Enum.Material.Metal
							end
						end
					end)

					local vF = _G.GVF(hit.Parent.Name)

					if vF and hit.Parent:FindFirstChild("Torso") then
						local ang = Instance.new("BodyAngularVelocity")
						_G.cTag(ang,"BM")
						local pos = Instance.new("BodyPosition")
						_G.cTag(pos,"BM")

						local n = 10
						if math.random(1,2) == 1 then
							n = -n
						end

						local vel = Vector3.new(n / 3, n / 3, n / 3)

						local pPos = hit.Parent.Torso.Position

						pos.MaxForce = Vector3.new(9999999,9999999,9999999)
						pos.D = 100
						pos.Position = pPos

						ang.MaxTorque = Vector3.new(10e10,10e10,10e10)
						ang.AngularVelocity = Vector3.new()

						ang.Parent = hit.Parent.Torso
						pos.Parent = hit.Parent.Torso

						local raycastDistance = 20
						local ignoreList = {hit.Parent, workspace.Debris, workspace.Filter, workspace.Characters}
						local TargetPos = Vector3.new(0, 20, 0)

						local raycastOrigin = hit.Parent.Torso.Position
						local raycastDirection = Vector3.new(0, 1, 0)

						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = ignoreList

						local raycastResult = workspace:Raycast(raycastOrigin, raycastDirection, raycastParams)

						if raycastResult then
							TargetPos = raycastResult.Position - Vector3.new(0, 6, 0)
						end

						TS:Create(ang,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{AngularVelocity = vel}):Play()
						TS:Create(pos,TweenInfo.new(1.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Position = pPos + TargetPos}):Play()

						for i,v in pairs(vF.HealthValues:GetChildren()) do
							if not v.Destroyed.Value then
								v.Value = 1
							end
						end

						delay(2, function()
							if hit and hit.Parent and hit.Parent.Parent and hit.Parent:FindFirstChild("Torso") and vF and vF.Parent then
								if ang and ang.Parent then
									ang:Destroy()
								end
								if pos and pos.Parent then
									pos:Destroy()
								end
								if TransformS and TransformS.Parent then
									TransformS:Destroy()
								end

								local Particles = script:WaitForChild("GoldParticles"):Clone()
								Particles.Parent = hit.Parent.Torso
								Particles:Emit(30)
								game.Debris:AddItem(Particles, Particles.Lifetime.Max)

								for _, v in pairs(hit.Parent:GetChildren()) do
									if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
										_G.DamageJoint(v,hit.Parent,1000,"Normal",nil,nil,sPlr)
									end
								end
							end
						end)
					end
				end
				if config.Customs["SantaFinish"] and not hitChar:FindFirstChild("SF_DB") then

					local DB = Instance.new("BoolValue", hitChar)
					DB.Name = "SF_DB"
					game.Debris:AddItem(DB, 0.25)

					local soundsDir = ServerStorage.Storage.SantaSounds

					if soundsDir:FindFirstChild("SantaHit2") then
						local hitSound = soundsDir["SantaHit2"]:Clone()
						hitSound.PlaybackSpeed = hitSound.PlaybackSpeed * math.random(950,1050) / 1000
						hitSound.Parent = hitChar["HumanoidRootPart"]
						hitSound:Play()
						game.Debris:AddItem(hitSound)
					end

					if soundsDir:FindFirstChild("Laugh2") then
						local laughSound = soundsDir["Laugh2"]:Clone()
						laughSound.PlaybackSpeed = laughSound.PlaybackSpeed * math.random(950,1050) / 1000
						laughSound.Parent = sRoot
						laughSound:Play()
						game.Debris:AddItem(laughSound)
					end

					for _, v in pairs(Handle:GetDescendants()) do
						if v:IsA("ParticleEmitter") and v.Name == "Sparks" and v:FindFirstChild("Emit") then
							v:Emit(v:FindFirstChild("Emit").Value)
						end
					end
				end
				if config.Customs["CurseFinish"] then
					_G.CombatTagChar(sPlr,120,"POI_S2")
					local RADIUS = config.Customs.CurseFinish.Radius
					local TIME = config.Customs.CurseFinish.Time
					local DPS = config.Customs.CurseFinish.DPS

					local Point1 = sCharacter.HumanoidRootPart.CFrame.p - Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Point2 = sCharacter.HumanoidRootPart.CFrame.p + Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Region = Region3.new(Point1,Point2)

					local targets = {}

					for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},math.huge)) do
						local gChar = Part.Parent
						if gChar ~= sCharacter
							and Part.Name == "Torso"
							and gChar:FindFirstChild("Humanoid") 
							and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead
							and not gChar:FindFirstChildOfClass("ForceField")
						then
							table.insert(targets,gChar)
						end
					end

					local p = ServerStorage.Storage.Other.CurseFinish.LightningS:Clone()
					game.Debris:AddItem(p,10)
					p.CFrame = sRoot.CFrame + Vector3.new(0,1000,0)
					p.Parent = workspace.Debris
					p["Strike" .. math.random(1,3)]:Play()

					local Attachment = Instance.new("Attachment", workspace.Terrain)
					game.Debris:AddItem(Attachment,10)
					Attachment.WorldPosition = hit.Position

					local s2 = ServerStorage.Storage.Other.CurseFinish.Laugh:Clone()
					s2.Parent = Attachment
					s2:Play()

					for _,v in pairs(targets) do
						delay(math.random(20,100) / 100,function()
							_G.Scream(v,v["Head"],"Scream" .. math.random(1,5))

							local tvf = _G.GVF(v.Name)

							if tvf then
								local poisV = Instance.new("NumberValue")
								poisV.Name = "POIZSKRATA"
								poisV:SetAttribute("NoIcon",true)
								poisV.Value = 0.5
								game.Debris:AddItem(poisV,TIME)
								poisV.Parent = tvf.Currents
							end

							local s1 = ServerStorage.Storage.Other.CurseFinish.ZapS:Clone()
							game.Debris:AddItem(s1,5)
							s1.Parent = v.HumanoidRootPart
							s1:Play()

							local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							sc.IsCursed.Value = true
							sc.Time.Value = TIME
							sc.Dmg.Value = DPS

							sc.Parent = v

							sc.Disabled = false

							_G.AffectChar(v,"Stunned",TIME)

							_G.TagChar(v,sPlr,15,15,nil,Tool.Name,Mag)
						end)
					end
				elseif config.Customs["SlayersFinishFull"] then
					_G.CombatTagChar(sPlr,120,"SLAYZ1")

					local RADIUS = config.Customs.SlayersFinishFull.Radius
					local TIME = config.Customs.SlayersFinishFull.Time
					local DPS = config.Customs.SlayersFinishFull.DPS

					local Point1 = sCharacter.HumanoidRootPart.CFrame.p - Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Point2 = sCharacter.HumanoidRootPart.CFrame.p + Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Region = Region3.new(Point1,Point2)

					local targets = {}

					for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},math.huge)) do
						local gChar = Part.Parent
						if gChar ~= sCharacter
							and Part.Name == "Torso"
							and gChar:FindFirstChild("Humanoid") 
							and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead
							and not gChar:FindFirstChildOfClass("ForceField")
						then
							table.insert(targets,gChar)
						end
					end

					local sfF = ServerStorage.Storage.Other.SlayersFinish

					local p = sfF.LightningS:Clone()
					game.Debris:AddItem(p,10)
					p.CFrame = sRoot.CFrame + Vector3.new(0,1000,0)
					p.Parent = workspace.Debris
					p["Strike" .. math.random(1,3)]:Play()

					local Attachment = Instance.new("Attachment", workspace.Terrain)
					game.Debris:AddItem(Attachment,10)
					Attachment.WorldPosition = hit.Position

					local s2 = sfF.Break:Clone()
					s2.Parent = Attachment
					s2:Play()

					for _,v in pairs(targets) do
						delay(math.random(20,100) / 100,function()
							_G.Scream(v,v["Head"],"Scream" .. math.random(1,5))

							local tvf = _G.GVF(v.Name)

							if tvf then
								local poisV = Instance.new("NumberValue")
								poisV.Name = "FLAMESKRATA"
								poisV:SetAttribute("NoIcon",true)
								poisV.Value = 0.5
								game.Debris:AddItem(poisV,TIME)
								poisV.Parent = tvf.Currents
							end

							local s1 = sfF.ZapS:Clone()
							game.Debris:AddItem(s1,5)
							s1.Parent = v.HumanoidRootPart
							s1:Play()

							--local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							--sc.IsCursed.Value = true
							--sc.Time.Value = TIME
							--sc.Dmg.Value = DPS

							--sc.Parent = v

							--sc.Disabled = false

							local t = {
								"la";
								"ra";
								"ll";
								"rl";
								--"n";
							}

							_G.AffectChar(v,"Stunned",TIME)

							_G.TagChar(v,sPlr,15,15,nil,Tool.Name,Mag)

							for i,z in pairs(t) do
								local cD = math.random(config.Customs.SlayersFinishFull.LimbDmgMin,config.Customs.SlayersFinishFull.LimbDmgMax)

								if tvf then
									cD *= tvf.MeleeProof[hit.Name].Value
								end

								game.ServerStorage.Events3.LimbTing:Fire(v,"damage",z,cD)
							end

							for i,z in pairs(sfF.Particles:GetChildren()) do
								z = z:Clone()
								z.Parent = v.Torso
								if z:IsA("ParticleEmitter") then
									game.Debris:AddItem(z,0.5)
									z:Emit(20)
								else
									game.Debris:AddItem(z,0.15)
									z.Enabled = true

								end
							end

							local vP = Players:GetPlayerFromCharacter(v)
							if vP then
								local cTime = config.Customs.SlayersFinishFull.ConcussionEffect.Time
								local cMulti = config.Customs.SlayersFinishFull.ConcussionEffect.Multi

								if hitVF then
									cTime = cTime * hitVF.ConcussionProof.Value
									cMulti = cMulti * hitVF.ConcussionProof.Value
								end

								ReplicatedStorage.Events.CONC_EF:FireClient(vP,cTime,cMulti,config.Customs.SlayersFinishFull.ConcussionEffect.DoLimit,config.Customs.SlayersFinishFull.ConcussionEffect.Limit_FadeTime,config.Customs.SlayersFinishFull.ConcussionEffect.Limit_Perc)
							end	

							local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							sc.IsFrostbite.Value = true
							sc.Time.Value = TIME
							sc.Dmg.Value = DPS

							sc.Parent = v
							sc.Disabled = false

							if config.Customs.SlayersFinishFull.Rage_Enabled and not sCharacter:FindFirstChild("RageScript") then
								local rageScript = ServerStorage.Storage.Scripts.RageScript:Clone()
								rageScript.Parent = sCharacter
								rageScript.LastTime.Value = config.Customs.SlayersFinishFull.Rage_LastTime
								rageScript.SM.Value = config.Customs.SlayersFinishFull.Rage_Speed_Perc
								rageScript.DMM.Value = config.Customs.SlayersFinishFull.Rage_HP_Perc
								rageScript.NoEnd.Value = true
								rageScript.Disabled = false
							end
						end)
					end
				elseif config.Customs["NecromancerFinishFull"] then
					_G.CombatTagChar(sPlr,120,"SLAYZ1")

					local RADIUS = config.Customs.NecromancerFinishFull.Radius
					local TIME = config.Customs.NecromancerFinishFull.Time
					local DPS = config.Customs.NecromancerFinishFull.DPS

					local Point1 = sCharacter.HumanoidRootPart.CFrame.p - Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Point2 = sCharacter.HumanoidRootPart.CFrame.p + Vector3.new(RADIUS/2,RADIUS/2,RADIUS/2)
					local Region = Region3.new(Point1,Point2)

					local targets = {}

					local sfF = ServerStorage.Storage.Other.NecroFinish

					if config.Customs.NecromancerFinishFull.DoScreech and not customs.NecromancerFinishSoundTing then
						if time() - customs.NecromancerFinishSoundTing > config.Customs.NecromancerFinishFull.ScreechCooldown then
							customs.NecromancerFinishSoundTing = time()

							delay(0.5,function()
								local s = sfF["nazgul_screech" .. math.random(1,4)]:Clone()
								game.Debris:AddItem(s,3)
								s.Name = "Screech"
								s.Parent = sCharacter.Head
								s:Play()
							end)
						end
					end

					if sCharacter:FindFirstChild("ScytheChargeUpEffectEvent") then
						sCharacter.ScytheChargeUpEffectEvent:Fire()
					end

					for _,Part in pairs(workspace:FindPartsInRegion3WithWhiteList(Region,{workspace.Characters},math.huge)) do
						local gChar = Part.Parent
						if gChar ~= sCharacter
							and Part.Name == "Torso"
							and gChar:FindFirstChild("Humanoid") 
							and gChar:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead
							and not gChar:FindFirstChildOfClass("ForceField")
						then
							table.insert(targets,gChar)
						end
					end



					--local p = sfF.LightningS:Clone()
					--game.Debris:AddItem(p,10)
					--p.CFrame = sRoot.CFrame + Vector3.new(0,1000,0)
					--p.Parent = workspace.Debris
					--p["Strike" .. math.random(1,3)]:Play()

					local Attachment = Instance.new("Attachment", workspace.Terrain)
					game.Debris:AddItem(Attachment,10)
					Attachment.WorldPosition = hit.Position

					local s2 = sfF.Break:Clone()
					s2.Parent = Attachment
					s2:Play()

					for _,v in pairs(targets) do
						delay(math.random(20,100) / 100,function()
							_G.Scream(v,v["Head"],"Scream" .. math.random(1,5))

							local tvf = _G.GVF(v.Name)

							if tvf then
								local poisV = Instance.new("NumberValue")
								poisV.Name = "FROSTSKRATA"
								poisV:SetAttribute("NoIcon",true)
								poisV.Value = 0.5
								game.Debris:AddItem(poisV,TIME)
								poisV.Parent = tvf.Currents
							end

							local s1 = sfF.ZapS:Clone()
							game.Debris:AddItem(s1,5)
							s1.Parent = v.HumanoidRootPart
							s1:Play()

							--local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							--sc.IsCursed.Value = true
							--sc.Time.Value = TIME
							--sc.Dmg.Value = DPS

							--sc.Parent = v

							--sc.Disabled = false

							local t = {
								"la";
								"ra";
								"ll";
								"rl";
								--"n";
							}

							_G.AffectChar(v,"Stunned",TIME)

							_G.TagChar(v,sPlr,15,15,nil,Tool.Name,Mag)

							for i,z in pairs(t) do
								local cD = math.random(config.Customs.NecromancerFinishFull.LimbDmgMin,config.Customs.NecromancerFinishFull.LimbDmgMax)

								if tvf then
									cD *= tvf.MeleeProof[hit.Name].Value
								end

								game.ServerStorage.Events3.LimbTing:Fire(v,"damage",z,cD)
							end

							for i,z in pairs(sfF.Particles:GetChildren()) do
								z = z:Clone()
								z.Parent = v.Torso
								if z:IsA("ParticleEmitter") then
									game.Debris:AddItem(z,0.5)
									z:Emit(20)
								else
									game.Debris:AddItem(z,0.15)
									z.Enabled = true

								end
							end

							local vP = Players:GetPlayerFromCharacter(v)
							if vP then
								local cTime = config.Customs.NecromancerFinishFull.ConcussionEffect.Time
								local cMulti = config.Customs.NecromancerFinishFull.ConcussionEffect.Multi

								if hitVF then
									cTime = cTime * hitVF.ConcussionProof.Value
									cMulti = cMulti * hitVF.ConcussionProof.Value
								end

								ReplicatedStorage.Events.CONC_EF:FireClient(vP,cTime,cMulti,config.Customs.NecromancerFinishFull.ConcussionEffect.DoLimit,config.Customs.NecromancerFinishFull.ConcussionEffect.Limit_FadeTime,config.Customs.NecromancerFinishFull.ConcussionEffect.Limit_Perc)
							end	

							local sc = ServerStorage.Storage.Scripts.BurningScript:Clone()
							--sc.IsFrostbite.Value = true
							sc.Time.Value = TIME
							sc.Dmg.Value = DPS
							sc.CustomColor.Value=config.Customs.NecromancerFinishFull.CustomColor or Color3.new()
							sc.DoSkeletonDeath.Value = config.Customs.NecromancerFinishFull.SkeletonEffect or false

							sc.Parent = v
							sc.Disabled = false

							if config.Customs.NecromancerFinishFull.Rage_Enabled and not sCharacter:FindFirstChild("RageScript") then
								local rageScript = ServerStorage.Storage.Scripts.RageScript:Clone()
								rageScript.Parent = sCharacter
								rageScript.LastTime.Value = config.Customs.NecromancerFinishFull.Rage_LastTime
								rageScript.SM.Value = config.Customs.NecromancerFinishFull.Rage_Speed_Perc
								rageScript.DMM.Value = config.Customs.NecromancerFinishFull.Rage_HP_Perc
								rageScript.NoEnd.Value = true
								rageScript.Disabled = false
							end
						end)
					end
				elseif config.Customs.RageEffectFinish then
					local rageScript = ServerStorage.Storage.Scripts.RageScript:Clone()
					rageScript.Parent = sCharacter
					rageScript.LastTime.Value = config.Customs.RageEffectFinish.LastTime
					--rageScript.SM.Value = config.Customs.SlayersFinishFull.Rage_Speed_Perc
					--rageScript.DMM.Value = config.Customs.SlayersFinishFull.Rage_HP_Perc
					rageScript.NoEnd.Value = true
					rageScript.Disabled = false
				end
			end

			if playHitSound then
				if Tool:GetAttribute("voidedge") then
					--
					local sDir = game:GetService("ServerStorage"):WaitForChild("Storage").VoidDirectory
					local hitSound = sDir.HitSounds:GetChildren()[math.random(1,#sDir.HitSounds:GetChildren())]:Clone()
					hitSound.Parent = hit
					hitSound.PlaybackSpeed = hitSound.PlaybackSpeed * math.random(900,1100) / 1000
					hitSound:Play()
					game.Debris:AddItem(hitSound)
					--
					if sHumanoid and sHumanoid.Parent and sHumanoid.Health > 15 then
						sHumanoid.Health += 8
					end
					--
				else
					--
					local hitSound = GetSoundFromDir("HitSounds")
					hitSound.Parent = hit
					hitSound.PlaybackSpeed = hitSound.PlaybackSpeed * math.random(900,1100) / 1000
					hitSound:Play()
					game.Debris:AddItem(hitSound)
					--
					if SoundsDir:FindFirstChild("HitSound2") then
						local hitSound2 = GetSoundFromDir("HitSound2")
						hitSound2.Parent = hit
						hitSound2.PlaybackSpeed = hitSound2.PlaybackSpeed * math.random(900,1100) / 1000
						hitSound2:Play()
						game.Debris:AddItem(hitSound2)
					end
					--
				end
			end

			if config.Customs.HitScream then
				_G.Scream(hitChar,hitChar["Head"],"Scream" .. math.random(1,5))
			end

			local lHealth = _G.LimbHealthValue_Check(hitChar,hit)
			local bT = config.BreakSettings.BreakType

			if config.BreakSettings.Enabled and config.BreakSettings[hit.Name] then
				if config.BreakSettings[hit.Name].BreakType then
					bT = config.BreakSettings[hit.Name].BreakType
				elseif sTable.cST == "Execute" and config.BreakSettings.KillType then
					bT = config.BreakSettings.KillType
				end
			end

			if config.BreakSettings.KillType and sTable.cST == "Execute" then
				bT = config.BreakSettings.KillType
			end

			local zzz = true
			if bT == "BoneBreak" and hitVF and hitVF.HealthValues:FindFirstChild(hit.Name) and hitVF.HealthValues[hit.Name].Broken.Value and not (sTable.cST == "Execute" and cL.ExplodeHead) then
				zzz = false
			end

			if hitVF then
				for _,v in pairs(hitVF.Currents:GetChildren()) do
					if v.Name == "DRSTNCE" then
						dReducMulti = dReducMulti * v.Value
					end
				end
			end

			if config.BreakSettings.Enabled and not cantChop and lHealth and zzz then
				local can = true
				if (sTable.cST == "Execute" and not config.ExecuteSettings.CanBreak) then can = false end
				if sTable.cST ~= "Execute" and sTable.cST ~= "" then can = false end
				if config.Customs["ExplodeFinish"] and sTable.cST == "Execute" then can = false end
				if Tool:GetAttribute("goldenkatana") and sTable.cST == "Execute"  then can = false end
				if downed and sTable.cST ~= "Execute" then can = false end
				if can then
					if hit.Name == "Head" then
						hL = true			
						local x =  config.BreakSettings["Head"]
						local lDmg = x.Dmg * dMulti2 * hitVF.MeleeProof[hit.Name].Value
						lDmg = lDmg * dReducMulti
						
						if (Tool:GetAttribute("ModdedLimbDamageOverwrite")) then
							lDmg = Tool:GetAttribute("ModdedLimbDamageOverwrite")
						end

						local daHP = hitVF.HealthValues[hit.Name].Value
						if daHP - lDmg < 10 and x.CantBreak then
							lDmg = daHP - 10
							if daHP - lDmg > daHP then
								lDmg = 0
							end
						end
						local calc = lHealth.Value - lDmg

						local bT2 = bT
						if (config.BreakSettings.ExplodeHead or cL.ExplodeHead) 
							or (sTable.cST == "Execute" and config.BreakSettings.ExplodeHead_FINISH) 
							or (hHumanoid:GetAttribute("Infected_ExplodeHead") and config.Customs and config.Customs["Infected_ExplodeHead"]) 
						then 
							bT2 = "Explode" 
							if calc <= 0 then 
								explodedHead = true
							end
						end

						DamageJoint(bT2,lHealth,lDmg,sPlr,{
							handle=Handle,
							cnfig=config.Customs,
							creator=sPlr,
							extraData={
								combo=nMelee.SwingNum,
								isEx=sTable.cST=="Execute"
							},
						}
						)

						if calc <= 0 and config.BreakSettings.CanBreak and daHP > 0 then
							local oT = x.BleedDmg

							--Break("Right Shoulder",(sTable.cST == "Execute" and bT) or "BoneBreak")

							if hPlr and (sTable.cST == "Execute" or not downed) and isAlive then
								local xp = 35
								AddXP(sPlr,xp)
							end

							if oT > 0 then
								DmgOverTime(hitVF,hHumanoid,oT,x.BleedTime,x.BleedStep,config.BreakSettings.BleedKill)
							end
							--
						end
					elseif hit.Name == "Right Arm" then
						hL = true			
						local x =  config.BreakSettings["RArm"]
						local lDmg = x.Dmg * dMulti2 * hitVF.MeleeProof[hit.Name].Value
						lDmg = lDmg * dReducMulti
						
						if (Tool:GetAttribute("ModdedLimbDamageOverwrite")) then
							lDmg = Tool:GetAttribute("ModdedLimbDamageOverwrite")
						end

						local daHP = hitVF.HealthValues[hit.Name].Value
						if daHP - lDmg < 10 and x.CantBreak then
							lDmg = daHP - 10
							if daHP - lDmg > daHP then
								lDmg = 0
							end
						end
						local calc = lHealth.Value - lDmg

						DamageJoint((sTable.cST == "Execute" and bT) or "BoneBreak",lHealth,lDmg,sPlr)

						if calc <= 0 and config.BreakSettings.CanBreak and daHP > 0 then
							local oT = x.BleedDmg

							--Break("Right Shoulder",(sTable.cST == "Execute" and bT) or "BoneBreak")

							if hPlr and (sTable.cST == "Execute" or not downed) and isAlive then
								local xp = 25
								AddXP(sPlr,xp)
							end

							if oT > 0 then
								DmgOverTime(hitVF,hHumanoid,oT,x.BleedTime,x.BleedStep,config.BreakSettings.BleedKill)
							end
						end
					elseif hit.Name == "Left Arm" then
						hL = true			
						local x =  config.BreakSettings["LArm"]
						local lDmg = x.Dmg * dMulti2 * hitVF.MeleeProof[hit.Name].Value
						lDmg = lDmg * dReducMulti
						
						if (Tool:GetAttribute("ModdedLimbDamageOverwrite")) then
							lDmg = Tool:GetAttribute("ModdedLimbDamageOverwrite")
						end

						local daHP = hitVF.HealthValues[hit.Name].Value
						if daHP - lDmg < 10 and x.CantBreak then
							lDmg = daHP - 10
							if daHP - lDmg > daHP then
								lDmg = 0
							end
						end
						local calc = lHealth.Value - lDmg

						DamageJoint(bT,lHealth,lDmg,sPlr)

						if calc <= 0 and config.BreakSettings.CanBreak and daHP > 0 then
							local oT = x.BleedDmg

							--Break("Right Shoulder",(sTable.cST == "Execute" and bT) or "BoneBreak")

							if hPlr and (sTable.cST == "Execute" or not downed) and isAlive then
								local xp = 25
								AddXP(sPlr,xp)
							end

							if oT > 0 then
								DmgOverTime(hitVF,hHumanoid,oT,x.BleedTime,x.BleedStep,config.BreakSettings.BleedKill)
							end
						end
					elseif hit.Name == "Right Leg" then
						hL = true			
						local x =  config.BreakSettings["RLeg"]
						local lDmg = x.Dmg * dMulti2 * hitVF.MeleeProof[hit.Name].Value
						lDmg = lDmg * dReducMulti
						
						if (Tool:GetAttribute("ModdedLimbDamageOverwrite")) then
							lDmg = Tool:GetAttribute("ModdedLimbDamageOverwrite")
						end

						local daHP = hitVF.HealthValues[hit.Name].Value
						if daHP - lDmg < 10 and x.CantBreak then
							lDmg = daHP - 10
							if daHP - lDmg > daHP then
								lDmg = 0
							end
						end
						local calc = lHealth.Value - lDmg

						DamageJoint(bT,lHealth,lDmg,sPlr)

						if calc <= 0 and config.BreakSettings.CanBreak and daHP > 0 then
							local oT = x.BleedDmg

							--Break("Right Shoulder",(sTable.cST == "Execute" and bT) or "BoneBreak")

							if hPlr and (sTable.cST == "Execute" or not downed) and isAlive then
								local xp = 25
								AddXP(sPlr,xp)
							end

							if oT > 0 then
								DmgOverTime(hitVF,hHumanoid,oT,x.BleedTime,x.BleedStep,config.BreakSettings.BleedKill)
							end
						end
					elseif hit.Name == "Left Leg" then
						hL = true			
						local x =  config.BreakSettings["LLeg"]
						local lDmg = x.Dmg * dMulti2 * hitVF.MeleeProof[hit.Name].Value
						lDmg = lDmg * dReducMulti
						
						if (Tool:GetAttribute("ModdedLimbDamageOverwrite")) then
							lDmg = Tool:GetAttribute("ModdedLimbDamageOverwrite")
						end

						local daHP = hitVF.HealthValues[hit.Name].Value
						if daHP - lDmg < 10 and x.CantBreak then
							lDmg = daHP - 10
							if daHP - lDmg > daHP then
								lDmg = 0
							end
						end
						local calc = lHealth.Value - lDmg

						DamageJoint(bT,lHealth,lDmg,sPlr)

						if calc <= 0 and config.BreakSettings.CanBreak and daHP > 0 then
							local oT = x.BleedDmg

							--Break("Right Shoulder",(sTable.cST == "Execute" and bT) or "BoneBreak")

							if hPlr and (sTable.cST == "Execute" or not downed) and isAlive then
								local xp = 25
								AddXP(sPlr,xp)
							end

							if oT > 0 then
								DmgOverTime(hitVF,hHumanoid,oT,x.BleedTime,x.BleedStep,config.BreakSettings.BleedKill)
							end
						end
					end
				end
			end

			if config.Customs["ExplodeFinish"] and sTable.cST == "Execute" then
				local ex = game.ServerStorage.Projectiles.FinishExplosion:Clone()
				ex.CFrame = hit.Parent["HumanoidRootPart"].CFrame
				ex.Creator.Value = sPlr
				ex.Parent = workspace.Debris
				game.Debris:AddItem(ex,10)
				ex.Main.Disabled = false
			end

			if sTable.cST == "" and brokeJoint and hitChar:FindFirstChild("Head") and _G.Scream then
				_G.Scream(hitChar,hitChar["Head"],"Scream" .. math.random(1,5))
			end
			dmg = dmg * dMulti * exDmulti * torsoMLDMulti

			if hitVF then
				meleeProofMulti = hitVF.MeleeProof[hit.Name].Value
				dmg = dmg * meleeProofMulti
			end
			
			local isBackstab = false
			local bsCfg = config.Customs["Backstab"]
			if bsCfg and sTable.cST ~= "Execute" and not downed and isAlive and hitChar ~= sCharacter then
				if nMelee.BackstabCheck(sCharacter,hitChar,sRoot.Position) then
					isBackstab = true
					nMelee.BackstabConsume(sCharacter,hitChar)
					dmg = dmg * (bsCfg.Multi or 2.5)
					if bsCfg.Lethal then dmg = hHumanoid.MaxHealth + 10 end
				end
			end
			
			local willKill = hHumanoid.Health - dmg <= 15 or explodedHead

			local flinchTime = cL.FlinchTime and cL.FlinchTime or 0

			if hHumanoid:GetAttribute("InfectedType") then
				flinchTime += 0.5
			end

			_G.FlinchChar(hitChar,hHumanoid,flinchTime,false,config.DCancelGuns,false,true)
			
			local winds=sCharacter:GetAttribute("Winds")
			if winds and winds>0 then
				sCharacter:SetAttribute("setWinds",0)
				ReplicatedStorage.PlantsStorage.Hooks.remote:FireAllClients("WindUpHit",{char=sCharacter})
			end

			--if sTable.cST ~= "Execute" and _G.DownedCheck(hitChar) then ForceChar(true) return end	
			local isRagdolled = _G.RagdollCheck(hitChar,0.15)

			if Tool.Name == "Clippers" and hit.Name == "Head" and not hitChar:FindFirstChild("hasHelmet") then
				local Directory = ServerStorage.Storage.ClipperDirectory

				local HairStyles = Directory.HairStyles:GetChildren()
				local HairStyle = HairStyles[math.random(1, #HairStyles)]:Clone()

				for _, v in pairs(hitChar:GetChildren()) do
					if v:IsA("Accessory") then
						local Do = false
						for __, vv in pairs(v:GetDescendants()) do
							if vv.Name == "HatAttachment" or vv.Name == "HairAttachment" then
								Do = true
							end
						end
						if Do then
							v:Destroy()
						end
					elseif v:IsA("Hat") then
						v:Destroy()
					end
				end

				local HairStrands = Directory.HairStrands:Clone()
				HairStrands.Parent = hit
				HairStrands:Emit(20)

				local ShaveSound = Directory.Shave:Clone()
				ShaveSound.Parent = hit
				ShaveSound:Play()

				HairStyle.Parent = hitChar

				game.Debris:AddItem(HairStrands, HairStrands.Lifetime.Max)
				game.Debris:AddItem(ShaveSound)
			end

			if hit.Name == "Head" and config.Customs then
				if config.Customs["SantaFinish"] and not hitChar:FindFirstChild("SF_DB") then

					local DB = Instance.new("BoolValue", hitChar)
					DB.Name = "SF_DB"
					game.Debris:AddItem(DB, 0.25)

					local soundsDir = ServerStorage.Storage.SantaSounds

					if soundsDir:FindFirstChild("SantaHit1") then
						local hitSound = soundsDir["SantaHit1"]:Clone()
						hitSound.PlaybackSpeed = hitSound.PlaybackSpeed * math.random(950,1050) / 1000
						hitSound.Parent = hitChar["HumanoidRootPart"]
						hitSound:Play()
						game.Debris:AddItem(hitSound)
					end

					if soundsDir:FindFirstChild("Laugh1") then
						local laughSound = soundsDir["Laugh1"]:Clone()
						laughSound.PlaybackSpeed = laughSound.PlaybackSpeed * math.random(950,1050) / 1000
						laughSound.Parent = sRoot
						laughSound:Play()
						game.Debris:AddItem(laughSound)
					end

					for _, v in pairs(Handle:GetDescendants()) do
						if v:IsA("ParticleEmitter") and v.Name == "Sparks" and v:FindFirstChild("Emit") then
							v:Emit(v:FindFirstChild("Emit").Value)
						end
					end
				end
			end

			if _G.SMains and ((cL.CanKnock and cL.KnockMode and isAlive) or (winds and winds>0)) and not hHumanoid:GetAttribute("NoMeleeKnock") then
				if cL.KnockMode == "Default" or (cL.KnockMode == "Head" and hit.Name == "Head") or (winds and winds>0) then
					
					local addedTime=0
					if winds then addedTime+=winds/2 end

					if not cL.NORD and not hasRBTMVB and not hitVF.NoRagdoll.Value and cL.KnockTime+addedTime > 0 then
						local canKnock = true
						if cL.ConcussKnockMin then
							if hitVF.ConcussionProof.Value <= cL.ConcussKnockMin then
								canKnock = false
							end
						end

						if canKnock then
							knockedChar = true
							_G.SMains.RagdollChar(hitChar,cL.KnockTime+addedTime)
						end
					end
					_G.AffectChar(hitChar,"Stunned",cL.KnockTime+addedTime)

					didStun = true

					if hPlr then
						local xp

						if cL.KnockTime > 0 then
							xp = math.floor(cL.KnockTime+addedTime * 15)
						else
							xp = 10
						end

						xp = math.min(xp,30)

						AddXP(sPlr,xp)
					end		

					if hPlr and cL.ConcussionEffect ~= nil and cL.ConcussionEffect.Enabled then
						local cTime = cL.ConcussionEffect.Time
						local cMulti = cL.ConcussionEffect.Multi

						if hitVF then
							cTime = cTime * hitVF.ConcussionProof.Value
							cMulti = cMulti * hitVF.ConcussionProof.Value
						end

						_G.AffectChar(hitChar,"Stunned",cTime)

						ReplicatedStorage.Events.CONC_EF:FireClient(hPlr,cTime,cMulti,cL.ConcussionEffect.DoLimit,cL.ConcussionEffect.Limit_FadeTime,cL.ConcussionEffect.Limit_Perc)
					end
				end
			end
			
			local zapC = config.Customs["Zap"]
			if _G.SMains and zapC and isAlive and sTable.cST ~= "Execute" and not hHumanoid:GetAttribute("NoMeleeKnock") then
				local charge = Values:FindFirstChild("ZapCharge")

				if charge and charge.Value <= 0 then
					nMelee.TryBattery(sPlr)
				end

				if charge and charge.Value > 0 then
					charge.Value = math.max(0, charge.Value - (zapC.HitCost or 10))
					
					local TIME = zapC.ShockDuration or 1

					if hitChar:FindFirstChild("Taze") then
						hitChar.Taze.Duration.Value = TIME
					else
						local TS = ServerStorage.Tools.Taze:Clone()
						TS.Duration.Value = TIME
						TS.Ragdoll.Value = false
						TS.Parent = hitChar
					end

					if hPlr and cL.ConcussionEffect ~= nil and cL.ConcussionEffect.Enabled then
						local cTime = cL.ConcussionEffect.Time
						local cMulti = cL.ConcussionEffect.Multi

						if hitVF then
							cTime = cTime * hitVF.ConcussionProof.Value
							cMulti = cMulti * hitVF.ConcussionProof.Value
						end

						_G.AffectChar(hitChar,"Stunned",cTime)

						ReplicatedStorage.Events.CONC_EF:FireClient(hPlr,cTime,cMulti,cL.ConcussionEffect.DoLimit,cL.ConcussionEffect.Limit_FadeTime,cL.ConcussionEffect.Limit_Perc)
					end

					if charge.Value <= 0 then
						nMelee.TryBattery(sPlr)
					end
				end
			end
			
			if hitVF and hitVF.Climbing.Value and not hitVF.Currents:FindFirstChild("NStRD") and not hasRBTMVB and not hitVF.NoRagdoll.Value then
				_G.SMains.RagdollChar(hitChar,0.75)
			end

			local ragdolled = brokeJoint or knockedChar or willKill or hHumanoid.Health - dmg < 15

			if (willKill or downed or knockedChar or isRagdolled or (winds and winds>0)) and not (sTable.cST=="Execute" and Tool.Name=="Scissors") then
				--print("GHEKLL YEAH")
				ForceChar(downed,isRagdolled,not isAlive and 0.5)
			end

			if ReplicatedStorage.Values.LegacyDowningSystem.Value then
				isLegacyDowned = downed and sTable.cST ~= "Execute"

				if hHumanoid.Health - dmg < 0.1 and sTable.cST ~= "Execute" then
					dmg = hHumanoid.Health - 0.1
				end
			end

			if not isLegacyDowned and config.Blood.Enabled and cDB then
				local attachment
				if (sTable.cST == "" or sTable.cST == "Execute") then
					attachment = _G.CreateBloodAttachment(hit,lookAt(pos2,pos1))
					attachment.Name = "BleedAttachment"
				end

				if attachment then
					if attachment and attachment.Parent	 then
						attachment.Name = "BleedAttachment"
					end

					_G.CreateBloodHit(attachment)

					if config.Blood.Enabled2 then
						local bloodC2 = nil

						if sTable.cST == "Execute" or explodedHead then
							bloodC2 = deepCopy(config.Blood)
							bloodC2.A.Amount = {bloodC2.A.Amount[1] * 2,bloodC2.A.Amount[2] * 2}
							bloodC2.A.Size = bloodC2.A.Size * 1.35
						end

						_G.CreateBloodTrail(attachment,config.Blood.A,true,{0.25,1})
						_G.CreateBloodTrail(attachment,config.Blood.B,true,{0.5,1})

						bloodC2 = nil
					end

					--if Tool:FindFirstChild("BloodPartss") then
					--	for _,v in pairs(Tool.BloodParts:GetChildren()) do
					--		local p = v.Value

					--		local faces = {"Top"}
					--		if p:IsA("MeshPart") then		
					--			faces = {"Top","Bottom","Left","Right","Front","Back"}		
					--		end

					--		for i,v in pairs(faces) do
					--			local blood = script.BloodSplatters:GetChildren()[math.random(1,#script.BloodSplatters:GetChildren())]:Clone()
					--			if sTable.cST == "Execute" then
					--				blood.Transparency = blood.Transparency / 2
					--			end
					--			blood.Face = v
					--			blood.Parent = p

					--			delay(10,function()
					--				TS:Create(blood,TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Transparency = 1}):Play()
					--				game.Debris:AddItem(blood,3)
					--			end)
					--		end
					--	end
					--end
				end
			end

			if not downed and (not config.Fatal and hHumanoid.Health - dmg <= 15 and sTable.cST ~= "Execute" and not (isBackstab and bsCfg.Lethal)) then 
				dmg = hHumanoid.Health - 14

				if MeleeSettings.PassoverEnabled and not config.NoPassover then
					local pdmg = dmg * (config.PassoverMulti or 1) * meleeProofMulti
					pdmg = math.min(pdmg,config.PassoverCap or 1000)

					local ddd = ((hHumanoid.Health - pdmg) / 1) * MeleeSettings.PassoverMulti
					ddd = -ddd
					ddd = math.max(ddd,0)

					--print(ddd)

					--print("yyeyeaddeddown",ddd)
					hHumanoid:SetAttribute("downdmg",ddd)
				end

				if not downDBs[hitChar] then
					game.ServerStorage.Events3.nBount:Fire("KLGHJRKR90U3893KJZDGNKDFZJKNWU9023JKWRG02",sPlr,20)

					downDBs[hitChar] = true
					delay(30,function()
						downDBs[hitChar] = nil
					end)
				end
			elseif downed and sTable.cST ~= "Execute" then
				dmg = dmg / MeleeSettings.DownedDmgDiv
				if config.DownedMulti then
					dmg = dmg * config.DownedMulti
				end
				dmg = dmg * meleeProofMulti
			end

			if hPlr and combodChar then
				local ev = ReplicatedStorage.Events.ShellShock
				ev:FireClient(hPlr,1,config.Combo.KnockTime + 1.5,1,0,true)
			end

			if (sTable.cST == "Execute"
				--and hPlr
				) 

					and isAlive
					and not rValues.LegacyDowningSystem.Value
					and not hHumanoid:GetAttribute("FinishHPd")
			then
				if Tool.Name~="Scissors" then
					local AMH = sHumanoid.MaxHealth - 14.99
					local AH = sHumanoid.Health

					local H = AH

					local calc

					calc = (H - 14.99) / sHumanoid.MaxHealth
					calc = 1 - calc

					H = Lerp(0,sHumanoid.MaxHealth,calc)
					H = H * (cL.HealMulti or 0.5)

					H = math.floor(H)

					H = math.max(H,0)

					local s = script.XP_Sound:Clone()
					local p = script.XP_Particle:Clone()
					game.Debris:AddItem(s,3)
					game.Debris:AddItem(p,3)

					s.Parent = sRoot
					p.Parent = sRoot

					s:Play()
					p:Emit(20)

					hHumanoid:SetAttribute("FinishHPd",true)

					sHumanoid.Health = sHumanoid.Health + H

					if sVF then
						for _,v in pairs(sVF.HealthValues:GetChildren()) do
							if not v.Destroyed.Value then
								v.Value = v.Value + H
								if v.Value >= v.MaxValue then
									v.Broken.Value = false
								end
							end
						end
					end


					AddXP(sPlr,math.floor(H / 1.5))
				else
					dmg=0
					hitChar:SetAttribute("ForceDytooed",true)
					framework.networking.toClients(nil,false,"DytooMorph",
						{hPlr or hitChar,hitChar,true,
							{
								Vinny=false,
								NoHood=false,
								RequiresShirtOff=true,
								RequiresPantsOff=true,
							}
						}
					)
				end
			end

			if brokeKill then
				hHumanoid:TakeDamage(hHumanoid.MaxHealth + 10)
			else

				if (hHumanoid.Health > 0 and sTable.cST ~= "Execute") then
					--
					local sVF = _G.GVF(sPlr.Name)
					--
					if (_G.CharHasTrait(sPlr, "groundassault")) then
						local speedboost = _G.Create("NumberValue", "SP", sVF.Currents, {{"Value", 1.15}})
						game:GetService("TweenService"):Create(speedboost, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.1), {Value = 1}):Play()
						_G.SafeDestroy(speedboost, 0.5)
					end
					--
					if (_G.CharHasTrait(sPlr, "beatdown")) then
						local v2 = Instance.new("BoolValue")
						v2.Name = "2.39418"
						v2.Parent = sVF.Currents
						game.Debris:AddItem(v2,5)
						game:GetService("ReplicatedStorage").Events.INSTNMA:FireClient(sPlr, math.ceil(config.StaminaUsage/2))
					end
					--
				end
				
				if (Tool) then
					local islegit = not ((Tool:GetAttribute("CmdSpawnedOnly") == nil and false) or Tool:GetAttribute("CmdSpawnedOnly"))
					if (sPlr:GetAttribute("IgnoreDeathLegitimacy")) then islegit = true end
					local tag = sPlr.Name.."_"..Tool.Name
					_G.ApplyDeathLegitimacy(hHumanoid.Parent, tag, islegit, 3)
				end

				hHumanoid:TakeDamage(dmg)
				_G.AddViolenceAct(sPlr, {source = "melee", amount = dmg, who = hitChar.Name})
				
			end

			if parried==true and sTable.cST ~= "Execute" then
				--
				local parryPart=ServerStorage.Storage.Other.Payback.EpicParryPart:Clone()
				parryPart.Position=hit.Position
				parryPart.Parent=workspace.Debris
				parryPart.Parried:Play()
				--
				task.spawn(function()
					for i,v in pairs(parryPart.Attach:GetChildren()) do
						if v:IsA("ParticleEmitter") then
							v:Emit(v:GetAttribute("EmitCount") or 5)
						end
					end
				end)
				--
			end

			if Tool:GetAttribute("Vampirism") then
				--
				sCharacter.Humanoid.Health+=dmg*0.2
				--
			end

			--print(willKill,not explodedHead,hit.Name,hHumanoid:GetAttribute("Infected_ExplodeHead"))
			--if willKill and not explodedHead and hit.Name == "Head" and hHumanoid:GetAttribute("Infected_ExplodeHead") then
			--	print(1111)
			--	if config.Customs and config.Customs["Infected_ExplodeHead"] then
			--		print(2222)
			--		_G.DamageJoint(hit,hitChar,1000,"Explode",nil,nil,sPlr)
			--	end
			--end

			local hMT = hit.Name == "Head"
			--didStun or combodChar or brokeJoint or willKill
			--(knockedChar or brokeJoint or (willKill and not downed))
			local hitmarkType = (sTable.SwingNum == 3 and 3) or nMelee.ComboCount

			--print(hitmarkType,sTable.SwingNum)

			cmEvent:FireClient(sPlr,"Hitmarker",hMT,hitmarkType,dCombo)


			if cL.BleedDmg > 0 and hHumanoid.Health > 0 then
				DmgOverTime(hitVF,hHumanoid,cL.BleedDmg,cL.BleedTime,cL.BleedTick,false)
			end
		end

		nMelee.DidHit = true
	end

	return nMelee
end)


mRemote.OnServerInvoke = OnRemote
mEvent.OnServerEvent:Connect(OnRemote)

EVENTS3["MeleeCom"].Event:Connect(function(tool,arg1,arg2,arg3,arg4)
	local nMelee = cMelees[tool]
	if nMelee then
		if arg1 == "Flinch" then
			nMelee:Flinch(arg2,arg3,arg4)
		elseif arg1 == "StopGrabbing" then
			nMelee:PickupHandler(arg2,"Stop")
		end
	end
end)

Players.PlayerRemoving:connect(function(player)
	cMelees[player] = nil
end)