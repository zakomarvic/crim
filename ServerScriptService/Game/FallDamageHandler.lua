local _ = {}

local TS = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Event = ReplicatedStorage.Events.__DFfDD

local moreSoundsF = ServerStorage.Storage.MoreSounds

local Settings1 = {
	MinDmgHeight = 25;
	MinHeight = 15;
	MaxDmgHeight = 150;
	
	MinKillHeight = 80;
	
	LimbMulti = 1.5;
	LimbRandomiser = 1.1;
}

local Settings2 = {
	MinVel = 10;
	MinVelDmg = 80;
	MinVelDmg2 = 125;
	MaxVelDmg = 255;
	SpikeVel = 30;
	TrampolineVel = 25;
	
	MoreDmgVel = 190;
}

local hits = {}
local rgc = {}
local hitNames = {"Head","Left Arm","Right Arm","Torso","Right Leg","Left Leg"}
local HitDBs = {}

function Lerp(a, b, c)
	return a + ((b - a) * c)
end

function AddHitDB(Name,Character,tim)
	local n = Character.Name
	HitDBs[Name .. n] = true
	delay(tim,function()
		HitDBs[Name .. n] = nil
	end)
end

local function BreakJoint(...)
	_G.BreakJoint(...)
end

local function DamageJoint(...)
	_G.DamageJoint(...)
end

math.randomseed(tick())

function FallingHit(Character,Humanoid,Torso,Head,HitPart,Hit,v,hDB)
	if hits[Character] and hits[Character] > 15 then return end
--	if Humanoid.Health <=0 then return end
	
	--if not (XD or not HitDBs["FH_DB_" .. Hit.Name]) then return end
	
	if Character:FindFirstChildOfClass("ForceField") then return end
	if typeof(Hit) ~= "Instance" or typeof(HitPart) ~= "Instance" then return end
	if not Hit or not HitPart or not Hit:IsA("BasePart") or not HitPart:IsA("BasePart") then return end
	if HitPart.Parent ~= Character then return end
	
	local c = false
	for _,z in pairs(hitNames) do
		if z == HitPart.Name then
			c = true
			break
		end
	end
	if not c then return end
	
	if Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:FindFirstChild("FREEFALL_FORCE") then
		Character.HumanoidRootPart:FindFirstChild("FREEFALL_FORCE"):Destroy()
	end
	
	if not hits[Character] then hits[Character] = 0 end
	
	local vF = _G.GVF(Character.Name)
	local downed = _G.DownedCheck(Character,0.25)
	
	hits[Character] = hits[Character] + 1
	
	local delayT = 5
	if Humanoid.Health <=0 then delayT = 60 end
	delay(delayT,function()
		hits[Character] = nil
	end)
	
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	_G.ZaWarudoWait()

	v = math.floor(v)
	
	--if v < Settings2.MaxVelDmg * 0.76 then
	--	AddHitDB("FH_DB_",Hit,0.35)
	--end
	
	--AddHitDB("FH_DB_",Hit,0.35)
	
	local minVelDmg = Settings2.MinVelDmg
	local minVelDmg2 = Settings2.MinVelDmg2
	
	if ReplicatedStorage.Values.LegacyDowningSystem.Value then
		minVelDmg2 *= 1.35
	end
	
	if v > minVelDmg
		--and (_G.RagdollCheck(Character) or XD) 
	then
		pcall(function()
			local Sound = game.ServerStorage.Storage.PlayerSounds.Torso["Fall" .. math.random(1,6)]:Clone()
			game.Debris:AddItem(Sound,2)
			Sound.Parent = Character.Torso
			Sound:Play()
		end)
		
		local Calc = v  / Settings2.MaxVelDmg
		Calc = math.clamp(1 - Calc,0.001,1)
		Calc = 1 - Calc
		
		--			local Dmg = (Humanoid.MaxHealth + 5) * Calc
		
		local Dmg = v / 2.4
		
		--if Double then Dmg = Dmg * 1.5 end
		if v < minVelDmg2 and Dmg + 1 > Humanoid.Health
		then
			Dmg = (downed and 10) or Humanoid.Health - 1
		elseif v > Settings2.MoreDmgVel then
			Dmg = Dmg * 1.25
		end
		
		local state = Humanoid:GetState()
		
		local a = _G.CreateBloodAttachment(HitPart,HitPart.CFrame)
		
		local destroyed = false
		--if state == Enum.HumanoidStateType.Dead then c = 0 end
		
		local z = v
		if z >= Settings2.MaxVelDmg then z = Settings2.MaxVelDmg end
		
		--_G.SMains.ForceChar(Character,HitPart,Vector3.new(0,z * 0.5,0),0.1)
		--if HitPart.Name ~= "Torso" and HitPart.Name ~= "HumanoidRootPart" then
		--	_G.SMains.ForceChar(Character,Character:FindFirstChild("HumanoidRootPart"),Vector3.new(0,z * 0.1,0),0.1)
		--end				
		
		local perc = v / Settings2.MaxVelDmg
		perc = math.max(perc,0.01)
		perc = math.min(perc,1)
		
		if perc >= 0.8 and HitPart.Parent:FindFirstChild("HumanoidRootPart") then
			local f = moreSoundsF.MoreGore:GetChildren()
			local s1 = f[math.random(1,#f)]:Clone()
			s1.Parent = HitPart.Parent.HumanoidRootPart
			s1:Play()
			game.Debris:AddItem(s1)
		end

		if vF then
			Dmg = Dmg * vF.FallDamageProof.Value
		end

		local gHitDB = HitDBs["FH_DB_1" .. Character.Name]
		if gHitDB then
			Dmg = Dmg * 0.05
		else
			_G.SMains.RagdollChar(Character,perc * vF.FallDamageProof.Value * 1.25)
			AddHitDB("FH_DB_1",Character,0.35)
		end
		
		Dmg = Dmg * _G.GetDmgMulti1(Character)
		
		local willKill = Humanoid.Health - Dmg <= 0

		if Dmg >= Humanoid.Health and not Character:FindFirstChildOfClass("ForceField") then
			Humanoid.Health = 0
		end
		
		local cd = {}
		cd.killer = "[GRAVITY]"
		cd.weapon = nil
		cd.distance = nil
		_G.CombatTagChar(Player,2,"FD" .. math.random(),nil,cd)
		
		Humanoid:TakeDamage(Dmg)
		_G.ApplyDeathLegitimacy(Humanoid.Parent, "FALLDAMAGE", true, 3)
		
		if perc >= 0.25 then
			local lHealth = _G.LimbHealthValue_Check(Character,HitPart)
			local m = Humanoid.Health <=0 and perc >= 0.85 and "Destroy" or "BoneBreak"
			
			if lHealth then
				local lDmg = (perc * 200)
				if vF then
					lDmg = lDmg * vF.FallDamageProof.Value
				end
				
				if HitPart.Name == "Head" then	
					lDmg = lDmg * 0.75
					
					if lHealth.Value - lDmg <= 0 then
						destroyed = true
					end
				
					DamageJoint(HitPart,Character,lDmg,m)
				elseif HitPart.Name == "Right Arm" then
					if lHealth.Value - lDmg <= 0 then
						destroyed = true
					end
					DamageJoint(HitPart,Character,lDmg,m)
				elseif HitPart.Name == "Left Arm"then
					if lHealth.Value - lDmg <= 0 then
						destroyed = true
					end
					DamageJoint(HitPart,Character,lDmg,m)
				elseif HitPart.Name == "Right Leg" then
					if lHealth.Value - lDmg <= 0 then
						destroyed = true
					end
					DamageJoint(HitPart,Character,lDmg,m)
				elseif HitPart.Name == "Left Leg" then
					if lHealth.Value - lDmg <= 0 then
						destroyed = true
					end
					DamageJoint(HitPart,Character,lDmg,m)
				end
			end
		end
		
		_G.CreateBloodHit(
			a -- attachment
		)
		
		
		local x = 10 * perc
		
		local x1,x2 = x * 0.75,x * 1.25
		x1 = math.floor(x1);x2 = math.floor(x2)
		
		local m = 2
		--if XD then x = x * m end
		
		local s = v
		if s >= Settings2.MaxVelDmg then s = Settings2.MaxVelDmg end
		
		_G.CreateBloodTrail(
			Torso.WaistCenterAttachment, -- attachment
			{
				{x1,x2}, -- blood amount
				10 + (s / 10 ), -- Speed
				{-100 * perc,100 * perc}, -- Spread
				5 * perc, -- Size
				5 * perc, -- WidthScale
				Vector3.new(0,3,0), -- upvector
				1, -- amt of times
				0 -- tick
			}
		)
		
		if destroyed and HitPart.Name ~= "Head" then
			if Character:FindFirstChild("Head") then
				_G.Scream(Character,Head,"Scream" .. math.random(1,5))
			end
			_G.DamageOverTime(Humanoid,5,1.5,0.2,true)
		end		
		
		if Calc >= 0.65 then
			return false
		end
	elseif v > Settings2.MinVel then
		pcall(function()
			local Sound = Torso:FindFirstChild("FallSmall")
			if Sound then
				Sound:Destroy()
			end
			Sound = game.ServerStorage.Storage.PlayerSounds.Torso["FallSmall"]:Clone()
			game.Debris:AddItem(Sound,2)
			Sound.Parent = Torso
			Sound:Play()
		end)
	end
	return
end

function FallDamage(Character,Humanoid,Torso,Head,PosA,PosB,AutoKill)
	--if Humanoid:FindFirstChild("FD_IG") then return end
	if Character:FindFirstChildOfClass("ForceField") then return end
	if Humanoid.Health <= 0 then return end
	
	_G.ZaWarudoWait()
	
	if AutoKill then
		Humanoid:TakeDamage(math.huge)
		_G.ApplyDeathLegitimacy(Humanoid.Parent, "FALLDAMAGE", true, 3)
	end
	
	local vF = _G.GVF(Character.Name)
	
	local Mag = PosA - PosB
	if Mag > Settings1.MinHeight then
		--pcall(function()
		--	local Sound = Torso:FindFirstChild("FallSmall")
		--	if Sound then
		--		Sound:Destroy()
		--	end
		--	Sound = game.ServerStorage.Storage.PlayerSounds.Torso["FallSmall"]:Clone()
		--	game.Debris:AddItem(Sound,2)
		--	Sound.Parent = Torso
		--	Sound:Play()
		--end)
		
		if Mag > Settings1.MinDmgHeight and not _G.RagdollCheck(Character) then
			local Perc = Mag / Settings1.MaxDmgHeight
			
			if vF then
				Perc = Perc * vF.FallDamageProof.Value
			end
			
			Perc = math.clamp(1 - Perc,0,1)
			local Dmg = (1 - Perc) * 115
			
			local RBTMVB = vF.Currents:FindFirstChild("RBTMVB")
			
			if RBTMVB then
				Dmg = math.min(Dmg,Humanoid.Health - 25)
			end
			
			if Humanoid.Health - Dmg <= 0 and Mag < Settings1.MinKillHeight then Dmg = Humanoid.Health - 1 end
			
			local Player = game.Players:GetPlayerFromCharacter(Character)
			if Player then
				local cd = {}
				cd.killer = "[GRAVITY]"
				cd.weapon = nil
				cd.distance = nil
				_G.CombatTagChar(Player,2,"FD" .. math.random(),nil,cd)
			end
			
			Humanoid:TakeDamage(Dmg)
			_G.ApplyDeathLegitimacy(Humanoid.Parent, "FALLDAMAGE", true, 3)
			
			if (_G.CharHasTrait(Character, "kangaroolegs")) then
				Dmg*= 0.5 end
			
			local lDmg = Dmg * Settings1.LimbMulti
			
			if RBTMVB then
				lDmg = lDmg * 0.2
			end
					
			if Character:FindFirstChild("Left Leg") then
				local rndm = 1 * math.random((1 / Settings1.LimbRandomiser) * 100,Settings1.LimbRandomiser * 100) / 100
				DamageJoint(Character["Left Leg"],Character,lDmg * rndm,"BoneBreak")
			end
			if Character:FindFirstChild("Right Leg") then
				local rndm = 1 * math.random((1 / Settings1.LimbRandomiser) * 100,Settings1.LimbRandomiser * 100) / 100
				DamageJoint(Character["Right Leg"],Character,lDmg * rndm,"BoneBreak")
			end
			
			pcall(function()
				local Sound = game.ServerStorage.Storage.PlayerSounds.Torso["Fall" .. math.random(1,6)]:Clone()
				game.Debris:AddItem(Sound,2)
				Sound.Parent = Character.Torso
				Sound:Play()
			end)
		end
	end
end

local thDB = {}
function TrampolineHit(Character,Humanoid,Hit)
	if not thDB[Character] then
		thDB[Character] = true
		delay(0.5,function()
			thDB[Character] = false
		end)
		local b = script.Boing:Clone()
		b.Parent = Hit
		b:Play()
		game.Debris:AddItem(b,1)
		
		Humanoid:SetAttribute("TRMZPL",true)
		delay(2,function()
			if Humanoid and Humanoid.Parent then
				Humanoid:SetAttribute("TRMZPL",nil)
			end
		end)
		
		_G.SMains.RagdollChar(Character,1)
	end
end
	
function SpikeHit(Character,Humanoid,HRP,Torso,Head,arg1,arg2,arg3,arg4)
	if Character:FindFirstChildOfClass("ForceField") then return end
	if Humanoid.Health <= 0 then return end
	if typeof(arg2) ~= "Instance" or arg2.Parent ~= Character then return end
	if typeof(arg3) ~= "Instance" or arg3.Name ~= "Spike" then return end
	if arg1 < Settings2.SpikeVel then return end
	if (HRP.Position - arg3.Position).Magnitude > 200 then
		return
	end
	if typeof(arg4) ~= "CFrame" or (HRP.Position - arg4.Position).Magnitude > 200 then
		return
	end
	
	local vF = _G.GVF(Character.Name)
	local RBTMVB = vF.Currents:FindFirstChild("RBTMVB")
	if RBTMVB then
		BarbedHit(Character,Humanoid,HRP,Torso,Head)
		return
	end
	
	local x = Instance.new("BoolValue",Humanoid)
	x.Name = "SH_Hit"
	x.Parent = Humanoid
	
	
	local cd = nil
	cd = {}
	cd.killer = "[SPIKE]"
	--cd.weapon = "GRINDER"
	--cd.distance = math.floor(distance)

	local player = game:GetService("Players"):GetPlayerFromCharacter(Character)
	if player then
		_G.CombatTagChar(player,30,"SPIKEH" .. math.random(),nil,cd)
	end
	
	_G.ZaWarudoWait()
	
	Humanoid.Health = -10
	
	spawn(function()
		FallingHit(Character,Humanoid,Torso,Head,arg2,arg3,300,true)
	end)
	
	--			local w = Instance.new("Weld",arg3)
	--			w.Part0 = arg3
	--			w.Part1 = HRP
	
	if HRP:CanSetNetworkOwnership() then
		HRP:SetNetworkOwner(nil)
		HRP.CFrame = arg4
	end
	
	local p = Instance.new("Part")
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = Vector3.new(1,1,1)
	
	p.Name = ""
	
	p.Anchored = true
	p.Transparency = 1
	
	p.Parent = Character
	
	local w = Instance.new("Weld")
	w.Part0 = HRP
	w.Part1 = p
	w.Parent = HRP
	--HRP.Anchored = true
	
	--TS:Create(HRP,TweenInfo.new(0.75,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out),{CFrame = arg4}):Play()
	
	local s = script.stab:Clone()
	s.Parent = arg3
	s:Play()
	game.Debris:AddItem(s,2)	
end

function BarbedHit(Character,Humanoid,HRP,Torso,Head,arg1,arg2,arg3,arg4,arg5)
	if Character:FindFirstChildOfClass("ForceField") then return end
	if Humanoid.Health <= 0 then return end
	if HitDBs["BarbedWire" .. Character.Name] then return end
	if typeof(arg5) ~= "number" or not tonumber(arg5) then return end

	--AddHitDB("BarbedWire",Character,0.5)
	
	local vf = _G.GVF(Character.Name)

	if not vf or tick() - vf.SpawnT.Value < 2 then
		return
	end
	
	_G.ZaWarudoWait()
	
	local dmg = 3
	local flinchTime = 0.6
	local ragdollTime = 0.2
	local debrisTime = 10
	local bleed = 2
	
	local downed = _G.DownedCheck(Character)
	
	if downed then
		dmg = dmg / 5
	end
	
	dmg= dmg * vf.MeleeProof["Torso"].Value
	bleed = dmg * vf.BleedProof.Value

	--local f = Instance.new("BodyForce")
	--_G.cTag(f,"BM")
	--f.Force = Vector3.new(0,30,0) * arg1
	--f.Parent = Character["HumanoidRootPart"]
	--game.Debris:AddItem(f,0.15)
	
	--spawn(function()
	--	--FallingHit(Character,Humanoid,Torso,Head,arg2,arg3,50,true)
	--end)
	
	local doRG = math.abs(arg5) >= 55

	if doRG then
		_G.Scream(Character,Head,"Scream" .. math.random(1,5),true)
		_G.SMains.RagdollChar(Character,0.3)
	end
	
	Humanoid:TakeDamage(dmg)
	_G.ApplyDeathLegitimacy(Humanoid.Parent, "FALLDAMAGE", true, 3)

	_G.DamageOverTime(Humanoid,bleed,3,1,true)
	--			local w = Instance.new("Weld",arg3)
	--			w.Part0 = arg3
	--			w.Part1 = HRP
	
	
	_G.FlinchChar(Character,Humanoid,flinchTime,nil,true)
	
	local cd = {}
	cd.killer = "[BARBED WIRE]"
	cd.weapon = nil
	cd.distance = nil
	_G.CombatTagChar(game.Players:GetPlayerFromCharacter(Character),10,"BH" .. math.random(),nil,cd)
	
	--_G.GetRagdollV(Character).Value = _G.GetRagdollV(Character).Value + ragdollTime	
	
	local s = moreSoundsF["BWire" .. math.random(1,3)]:Clone()
	s.Parent = HRP
	s:Play()
	game.Debris:AddItem(s,2)	
end

function RagdollTing(Character,Humanoid,Root,Head,lastPos)
	if HitDBs["R_DB_" .. Character.Name] then return end
	if typeof(lastPos) ~= "Vector3" then return end

	AddHitDB("R_DB_",Character,2)
	_G.ZaWarudoWait()
	if Root then
		local rot = _G.ExplosionForce(Root,lastPos - Vector3.new(0,10,0),1,20,1000,true,1,true)
		rot.Name = "FREEFALL_FORCE"
	end
	_G.FlinchChar(Character,Humanoid,1)
	_G.Scream(Character,Head,"Scream" .. math.random(1,5))
	_G.SMains.RagdollChar(Character,1)
	_G.CombatTagChar(game.Players:GetPlayerFromCharacter(Character),20,"RT")
end

function EnableRagdoll(Character)
	if not _G.RagdollCheck(Character) then
		_G.SMains.RagdollChar(Character,0.5)
	end	
end

function GrinderHit(Character,Humanoid,HitPart,Hit)
	if not (HitPart and HitPart.Parent and Hit and Hit.Parent) then return end

	if HitPart.Name ~= "Head" 
		and HitPart.Name ~= "Left Arm" 
		and HitPart.Name ~= "Right Arm" 
		and HitPart.Name ~= "Torso"
		and HitPart.Name ~= "Left Leg" 
		and HitPart.Name ~= "Right Leg"
	then
		return
	end

	if HitPart.Parent ~= Character then
		--local plr = game.Players:GetPlayerFromCharacter(Character)
		--pcall(function()
		--	ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",plr.Name,"Server tamper | attempted to Grinder decap another player",1,true)
		--end)

		--wait(1)
		--plr:Kick(string.rep(",",9999999999))	
		return
	end
	
	if not (HitPart and HitPart.Parent and Hit and Hit.Parent) then return end
	
	local vf = _G.GVF(Character.Name)
	
	if not vf or tick() - vf.SpawnT.Value < 2 then
		return
	end
	
	local t = 0.3
	
	local cd = nil
	cd = {}
	cd.killer = "[GRINDER]"
	--cd.weapon = "GRINDER"
	--cd.distance = math.floor(distance)
	
	local player = game:GetService("Players"):GetPlayerFromCharacter(Character)
	if player then
		_G.CombatTagChar(player,30,"GRINDR" .. math.random(),nil,cd)
	end
	
	_G.SMains.RagdollChar(Character,3)
	_G.FlinchChar(Character,Humanoid,1)
	
	if Humanoid.Health > 0 then
		if not HitDBs["GH_SDB" .. Character.Name] then
			local Head = Character:FindFirstChild("Head")
			local s = _G.Scream(Character,Head,"Grinder" .. math.random(1,3))
			AddHitDB("GH_SDB",Character,s.TimeLength + 1)
			Humanoid:TakeDamage(20)
			_G.ApplyDeathLegitimacy(Humanoid.Parent, "FALLDAMAGE", true, 3)
		end
	else
		t = t * 3
	end
	
	AddHitDB("GH_DB_",Character,t)
	
	DamageJoint(HitPart,Character,150,"Normal")

	--if HitPart.Name == "Head" then
	--	DamageJoint(HitPart,Character,150,"Normal")
	--elseif HitPart.Name == "Left Arm" then
	--	BreakJoint(HitPart,Character,"Left Shoulder")
	--elseif HitPart.Name == "Right Arm" then
	--	BreakJoint(HitPart,Character,"Right Shoulder")
	--elseif HitPart.Name == "Left Leg" then
	--	BreakJoint(HitPart,Character,"Left Hip")
	--elseif HitPart.Name == "Right Leg" then
	--	BreakJoint(HitPart,Character,"Right Hip")
	--end
	
	--if #Hit:GetChildren() <= 10 then
	--	local faces = {"Front","Back","Left","Right","Top","Bottom"}
	--	local face = faces[math.random(1,#faces)]
	--	local blood = script.blood:GetChildren()[math.random(1,#script.blood:GetChildren())]:Clone()
		
	--	blood.Face = face
	--	blood.Parent = Hit
	--	game.Debris:AddItem(blood,100)
	--end
	
	local f = moreSoundsF.MoreGore:GetChildren()
	local s1 = f[math.random(1,#f)]:Clone()
	s1.Parent = HitPart
	s1:Play()
	game.Debris:AddItem(s1)
	
	local s2 = script["GrinderHit" .. math.random(1,3)]:Clone()
	s2.Parent = Hit
	s2:Play()
	game.Debris:AddItem(s2)
	
	local s3 = script["GrinderLoop"]:Clone()
	s3.Parent = Hit
	s3:Play()
	s3.TimePosition = math.random(1,9)
	game.Debris:AddItem(s3,1)
	
	local a = _G.CreateBloodAttachment(HitPart,HitPart.CFrame)
	
	_G.CreateBloodHit(
		a -- attachment
	)
	
	--if Character:FindFirstChild("Torso") then
	--	_G.CreateBloodTrail(
	--		Character.Torso.WaistCenterAttachment, -- attachment
	--		{
	--			{1,4}, -- blood amount
	--			50, -- Speed
	--			{-360,360}, -- Spread
	--			4 * math.random(75,125) / 100, -- Size
	--			5, -- WidthScale
	--			Vector3.new(0,10,0), -- upvector
	--			1, -- amt of times
	--			1 -- tick		
	--		}
	--	)
	--end
end

Event.OnServerEvent:Connect(function(Player,n,arg1,arg2,arg3,arg4,arg5)
	if Player.Character then
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")
		local Torso = Character:FindFirstChild("Torso")
		local HRP = Character:FindFirstChild("HumanoidRootPart")
		local Head = Character:FindFirstChild("Head")
		
		if not HRP or not HRP.Parent or not HRP:FindFirstChild("RootJoint") then return end
		if not (Humanoid and HRP and Torso) then return end
		
		if n == "FlllD" and not HitDBs["F_DB_" .. Character.Name] and not Humanoid:FindFirstChild("Trampolin") then
			local FD = FallDamage(Character,Humanoid,Torso,Head,arg1,arg2,arg3) 
			if FD then
				AddHitDB("F_DB_",Character,0.25)
			end
		elseif n  == "FllH" and not Humanoid:FindFirstChild("Trampolin") then
			FallingHit(Character,Humanoid,Torso,Head,arg1,arg2,arg3,arg4)
		elseif n == "__--r" 
			and Character:FindFirstChild("HumanoidRootPart")
			and Character.HumanoidRootPart:GetNetworkOwner() == Player
			and _G.GetRagdollV(Character) 
			and Character:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead 
			and not Humanoid:FindFirstChild("Trampolin") 
			
		then
			RagdollTing(Character,Humanoid,HRP,Head,arg1)
		elseif n == "-r__r2" then
			EnableRagdoll(Character)
		elseif n == "HITRGP" and _G.GetRagdollV(Character) and not _G.RagdollCheck(Character) and Character:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
			if arg1 and typeof(arg1) == "Instance" and arg1.Name == "RG_Part" and (HRP.Position - arg1.Position).Magnitude < arg1.Size.Magnitude * 1.3 then
				_G.SMains.RagdollChar(Character,1)
				
				if not rgc[Character] then rgc[Character] = 0 end
				
				rgc[Character] = rgc[Character] + 1

				local delayT = 12
				delay(delayT,function()
					rgc[Character] = nil
				end)

				if rgc[Character] and rgc[Character] > 5 then
					Humanoid.Health = 0
				end
			end
		elseif n == "SSsH" then
			SpikeHit(Character,Humanoid,HRP,Torso,Head,arg1,arg2,arg3,arg4)
		elseif n == "BHHh" and arg3 and typeof(arg3) == "Instance" and arg3:IsA("BasePart") and arg3.Name == "BarbedWire" then
			BarbedHit(Character,Humanoid,HRP,Torso,Head,arg1,arg2,arg3,arg4,arg5)
		elseif n == "Tt__h" and arg1 >= Settings2.TrampolineVel and arg2.Name == "Trampoline" and (HRP.Position - arg2.Position).Magnitude < 150 then
			TrampolineHit(Character,Humanoid,arg2)
		elseif n == "G_Gh" and arg2.Name == "Grinder" and not HitDBs["GH_DB_" .. Character.Name] and not Character:FindFirstChildOfClass("ForceField") then
			GrinderHit(Character,Humanoid,arg1,arg2)
		elseif n == "KL_B" then
			Humanoid.Health = 0
			Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end
	end
end)

return _