local CollectionService =	game:GetService("CollectionService")
local PhysicsService = 		game:GetService("PhysicsService")
local ReplicatedStorage = 	game:GetService("ReplicatedStorage")
local ServerStorage = 		game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = 			game:GetService("Players")
local TS = 					game:GetService("TweenService")
local Debris =				game:GetService("Debris")

local EventsFolder = 		ReplicatedStorage.Events

_G.GrabModule = require(ServerStorage.Modules.Combat.GrabModule)
_G.HandcuffModule = require(ServerStorage.Modules.Combat.HandcuffModule)

_G.LimbHealthValue_Check = function(Character,Part)
	local VF = _G.GVF(Character.Name)
	if not VF then return end

	return VF.HealthValues:FindFirstChild(Part.Name)
end

function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
_G.deepCopy = deepCopy





local charStatsFolder = 	ReplicatedStorage:WaitForChild("CharStats",100)

local RemoveHelmetM = require(ServerStorage.Modules.Other.RemoveHelmet)
local RemoveVestM = require(ServerStorage.Modules.Other.RemoveVest)

local GameSettings
local monitorDestroyEVENT = Instance.new("BindableEvent")





local function lookAt(target, eye)
	local forwardVector = (eye - target).Unit
	local upVector = Vector3.new(0, 1, 0)

	local rightVector = forwardVector:Cross(upVector)
	local upVector2 = rightVector:Cross(forwardVector)

	return CFrame.fromMatrix(eye, rightVector, upVector2)
end

local function Lerp(a, b, c)
	return a + ((b - a) * c)
end

function MonitorDestroy(p,t)
	delay(t,function()
		if p and p.Parent then
			p:Destroy()
		end
	end)
end
monitorDestroyEVENT.Event:Connect(MonitorDestroy)

local ActiveRebel = false
local ActiveCope = false

_G.SpawnCope = function()
	task.spawn(function()
		if ActiveCope then
			return false
		end

		ActiveCope = true

		local CopeSpawns = workspace.Map.CopeStatueSpawns:GetChildren()
		local CopeSpawn = CopeSpawns[math.random(1, #CopeSpawns)]

		if workspace.Map:FindFirstChild("CopeStatues") then
			workspace.Map.CopeStatues:Destroy()
		end

		local CopeFolder = Instance.new("Folder", workspace.Map)
		CopeFolder.Name = "CopeStatues"

		local CopeStatue = game:GetService("ServerStorage").Storage.Other.CopeStatue:Clone()

		local Explosion = ServerStorage.Projectiles.MysteryBox_StrikeExplosion:Clone()
		Explosion.CFrame = CopeSpawn.CFrame
		game.Debris:AddItem(Explosion,10)
		Explosion.Parent = workspace.Debris
		Explosion.Main.Disabled = false

		CopeStatue:SetPrimaryPartCFrame(CopeSpawn.CFrame)
		CopeStatue.Parent = CopeFolder

		local RG_P = CopeStatue.RG_Part
		RG_P.Parent = workspace.Filter.Parts.F_Parts

		local Lifetime = _G.CopeLifetime

		local Character = nil
		local EventCon = nil
		local Removed = false

		local function RemoveStatue()
			if not CopeStatue then
				return
			end

			if not CopeStatue.Parent then
				return
			end

			if Removed then
				return
			end

			Removed = true

			pcall(function()
				EventCon:Disconnect()
			end)

			if RG_P and RG_P.Parent then
				RG_P.SpawnAttachment.ParticleEmitter:Emit(50)
				RG_P.SpawnAttachment.Break:Play()
				game.Debris:AddItem(RG_P, 2)
			end

			CopeStatue:Destroy()

			if CopeFolder and CopeFolder.Parent then
				CopeFolder:Destroy()
			end

			delay(2, function()
				ActiveCope = false
			end)
		end

		delay(Lifetime, function()
			RemoveStatue()
		end)

		EventCon = game:GetService("ServerStorage").Events3.NewBRUHMAN.Event:Connect(function(NewBruhmanUser)
			RemoveStatue()
		end)

		while task.wait(0.1) do

			for _, v in pairs(workspace.Characters:GetChildren()) do
				if v and v.Parent and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and _G.GVF(v.Name) and v:FindFirstChild("Torso") and _G.GVF(v.Name).Downed.Value and not _G.GVF(v.Name).Grabbed.Value and (v.Torso.Position - CopeStatue.Altar.Hitbox.Position).Magnitude <= 6 then
					Character = v
				end
			end

			if Character or not ActiveCope or not CopeStatue or not CopeFolder then
				break
			end
		end

		if Character then
			_G.SMains.RagdollChar(Character, 999)

			local aPos = CopeStatue.AlignPosition
			local aOri = CopeStatue.AlignOrientation

			aPos.Position = CopeStatue.Beam.Beam.VFX.BeamPoint.WorldPosition
			aOri.CFrame = CopeStatue.Beam.Beam.VFX.BeamPoint.WorldCFrame

			aPos.Attachment0 = Character.HumanoidRootPart.RootAttachment
			aOri.Attachment0 = Character.HumanoidRootPart.RootAttachment

			CopeStatue.Bruhman.Head.Charge:Play()

			for _, v in pairs(CopeStatue.Beam.Beam.VFX.LightParticles:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end

			CopeStatue.Beam.Beam.VFX.SymbolPoint.Emitter.Enabled = true

			task.wait(2.5)

			local RitualProcess = true

			local Explosion = game:GetService("ServerStorage").Projectiles.GrenadeExplosion:Clone()
			Explosion.CFrame = CopeStatue.Beam.Beam.VFX.BeamPoint.WorldCFrame
			game.Debris:AddItem(Explosion,10)
			Explosion.Parent = workspace.Debris
			Explosion.Main.Disabled = false

			aPos.Attachment0 = nil
			aOri.Attachment0 = nil

			for _, v in pairs(Character:GetDescendants()) do
				if v:IsA("Accessory") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
					v:Destroy()
				end
			end

			for _, v in pairs(Character:GetChildren()) do

				if v:IsA("Shirt") or v:IsA("Pants") then
					v:Destroy()
				end

				if v:IsA("BasePart") then

					local Flame = game:GetService("ServerStorage").Storage.Other.Flames1:Clone()
					game.Debris:AddItem(Flame, Flame.Lifetime.Max + 1)
					Flame.Enabled = true
					Flame.Parent = v

					v.Color = Color3.fromRGB(170, 170, 170)

					game:GetService("TweenService"):Create(v, TweenInfo.new(0.5), {
						Color = Color3.fromRGB(255, 255, 255)
					}):Play()

					delay(1, function()
						if Flame and Flame.Parent then
							Flame.Enabled = false
						end
					end)
				end
			end

			for _, v in pairs(CopeStatue.Beam:GetChildren()) do
				if v.Name ~= "Beam" then
					task.spawn(function()
						while task.wait() do
							if not RitualProcess then
								break
							end
							v.Orientation += Vector3.new(0, 0, math.random(20, 30))
						end
					end)
				end

				v.Transparency = 0
			end

			for _, v in pairs(CopeStatue.Beam.Beam.VFX:GetChildren()) do
				if v:IsA("Beam") then
					v.Enabled = true
				end
			end

			CopeStatue.Bruhman.Head.Beam:Play()

			CopeStatue.Beam.Beam.VFX.BeamPoint.Circle2:Emit(5)
			CopeStatue.Beam.Beam.VFX.SymbolPoint.Emitter.Enabled = false

			for _, v in pairs(CopeStatue.Bruhman.Head.EyesBlack:GetChildren()) do
				game:GetService("TweenService"):Create(v, TweenInfo.new(2), {
					Transparency = 1
				}):Play()
			end

			game:GetService("TweenService"):Create(CopeStatue.Bruhman.Head.Ambience, TweenInfo.new(1), {
				Volume = 0
			}):Play()

			task.wait(2)

			for _, v in pairs(CopeStatue.Bruhman.Head.EyesBlack:GetChildren()) do
				game:GetService("TweenService"):Create(v, TweenInfo.new(3), {
					Transparency = 0
				}):Play()
			end

			for _, v in pairs(CopeStatue.Bruhman.Head.EyesWhite:GetChildren()) do
				game:GetService("TweenService"):Create(v, TweenInfo.new(3), {
					Transparency = 1
				}):Play()
			end

			for _, v in pairs(CopeStatue.Beam.Beam.VFX.LightParticles:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end

			for _, v in pairs(CopeStatue.Beam:GetChildren()) do
				game:GetService("TweenService"):Create(v, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
			end

			task.delay(0.25, function()
				RitualProcess = false
			end)

			for _, v in pairs(CopeStatue.Beam.Beam.VFX:GetChildren()) do
				if v:IsA("Beam") then
					v.Enabled = false
				end
			end

			task.wait(1)

			game:GetService("TweenService"):Create(CopeStatue.Bruhman.ERAD.HandleSymbol, TweenInfo.new(1), {
				Transparency = 1
			}):Play()

			CopeStatue.Altar.Hitbox.ItemSpawn:Emit(10)
			CopeStatue.Altar.Hitbox.Spawn:Play()

			local clonedtool = game:GetService("ServerStorage").Tools["ERADICATOR"]:Clone()
			clonedtool:SetAttribute("BRUHMAN", true)

			game:GetService("ServerStorage").Events3.CreateSpawnedTool:Invoke("ER09ESFAODS0FAS4T90I3", clonedtool, CopeStatue.Altar.Main.Attachment.WorldCFrame, 100, true, nil)
		end
	end)
end

_G.Corrupt = function(Player, Time)
	task.spawn(function()
		if not Player or not Player.Parent or not Player.Character then
			return
		end

		Time = Time or 1

		local FallenStuff = game:GetService("ServerStorage").Storage.FallenStuff
		local Character = Player.Character
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		Humanoid.Health = 0

		task.wait(Time)

		local Dummy, DRoot, DHum, BG, BP, Effects

		local function Setup()
			local Dummy = FallenStuff.NecroDummy:Clone()
			local DHum = Dummy:FindFirstChildOfClass("Humanoid")

			game.Debris:AddItem(Dummy,5)

			for _, v in pairs(Dummy:GetChildren()) do
				if v:IsA("BasePart") then
					pcall(function()
						v.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId("No-Collide5")
					end)
				end
			end

			local DRoot = Dummy:FindFirstChild("HumanoidRootPart")
			DRoot.CFrame = CFrame.new(Character.Torso.Position + Vector3.new(-2, -10, -12))

			Dummy.Parent = workspace.Debris
			DRoot.Anchored = true

			if DRoot:CanSetNetworkOwnership() then
				DRoot:SetNetworkOwner(game.Players:GetPlayerFromCharacter(Character))
			end

			local IdleAnim = DHum:LoadAnimation(FallenStuff.Idle)
			IdleAnim:Play()

			local BP = DRoot.BodyPosition
			local BG = DRoot.BodyGyro

			BG.MaxTorque = Vector3.new(400000, 400000, 400000)
			BP.D = 800
			BG.D = 100

			local FallenEffects = FallenStuff.FallenDeath:Clone()
			game.Debris:AddItem(FallenEffects, 15)
			FallenEffects.PrimaryPart = FallenEffects.OriginPart
			FallenEffects:SetPrimaryPartCFrame(Character.Torso.CFrame)
			FallenEffects.PrimaryPart.Orientation = Vector3.new(0,0,0)
			FallenEffects.PrimaryPart.Position = FallenEffects.PrimaryPart.Position + Vector3.new(0, 3, 0)
			FallenEffects.Parent = workspace.Debris
			FallenEffects.OriginPart.Mine:Play()

			return Dummy, DRoot, DHum, BG, BP, FallenEffects
		end

		local function DoTweens()

			for _, v in pairs(Dummy.Necromancer:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 1

					game:GetService("TweenService"):Create(v, TweenInfo.new(0.5), {
						Transparency = 0
					}):Play()
				end
			end

			task.delay(1, function()

				if Character and Character.Parent then

					local Time = 1.5

					for _, v in pairs(Character:GetDescendants()) do
						if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
							game:GetService("TweenService"):Create(v, TweenInfo.new(Time), {
								Transparency = 0.85 ; Color = Color3.fromRGB(0, 0, 0)
							}):Play()
						elseif v:IsA("Shirt") or v:IsA("Pants") then
							game:GetService("TweenService"):Create(v, TweenInfo.new(Time), {
								Color3 = Color3.fromRGB(0, 0, 0)
							}):Play()
						elseif v:IsA("SpecialMesh") then
							game:GetService("TweenService"):Create(v, TweenInfo.new(Time), {
								VertexColor = Vector3.new(0, 0, 0)
							}):Play()
						elseif v:IsA("Decal") or v:IsA("Texture") then
							game:GetService("TweenService"):Create(v, TweenInfo.new(Time), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end)
		end

		Player:SetAttribute("RespawningPaused",true)

		task.delay(7,function()
			if Player and Player.Parent then
				Player:SetAttribute("RespawningPaused",nil)
			end
		end)

		Dummy, DRoot, DHum, BG, BP, Effects = Setup()

		task.wait(0.6)

		DoTweens()

		DRoot.Anchored = false

		local Corrupting = false
		local Tick = tick()
		local CON = nil

		CON = game:GetService("RunService").Heartbeat:Connect(function()

			if not Effects or not Effects.Parent or not Dummy or not Dummy.Parent or not Dummy:FindFirstChild("Torso") or not Character or not Character.Parent or not BG or not BP or not Character:FindFirstChild("Torso") then

				if Dummy and Dummy.Parent then
					game.Debris:AddItem(Dummy, 0)
				end

				CON:Disconnect()
				return
			end

			BG.CFrame = CFrame.lookAt(Dummy.Torso.Position, Character.Torso.Position)

			if tick() - Tick >= 3 then
				if not Corrupting then

					Corrupting = true

					game.Debris:AddItem(Dummy, 0.2)

					task.delay(0.2, function()

						for _, v in pairs(Effects.Part:GetChildren()) do
							if v:IsA("ParticleEmitter") then
								if v:GetAttribute("EmitCount") then
									v:Emit(v:GetAttribute("EmitCount") * 2)
								else
									v:Emit(40)
								end
							end
						end

						if Character and Character.Parent then
							for _, v in pairs(Character:GetDescendants()) do
								if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
									v.Transparency = 1
								end
							end

							task.wait(3)

							if Character and Character.Parent then
								if Player and Player.Parent then

									Player:LoadCharacter()

									if not Player.Character then
										Player.CharacterAdded:Wait()
									end

									local FallenArmor = game.ServerStorage.Tools.Fallen:Clone()
									FallenArmor.Parent = Player.Character

									task.wait()

									local FallenBlade = game.ServerStorage.Tools._FallenBlade:Clone()
									FallenBlade.Parent = Player.Backpack
								end
							end
						end
					end)
				end

				BP.Position = Character.Torso.Position - Vector3.new(0, 2, 0)
				BP.D = 500
			else
				BP.Position = Character.Torso.Position + Vector3.new(5, 6, 1)
			end
		end)
	end)
end

_G.SpawnRebel = function()
	if ActiveRebel then
		return false
	end

	ActiveRebel = true

	local CreateViewportCharacterM = require(ServerStorage.Modules.Other.CreateViewportCharacter)

	local Dir = ServerStorage.Storage.RebelStuff

	local RebelSpawns = workspace.Filter.RebelDealerSpawns:GetChildren()
	local RebelSpawn = RebelSpawns[math.random(1, #RebelSpawns)]

	local Rebel = Dir.RebelDealer:Clone()

	Rebel.PrimaryPart = Rebel.DealerMan.HumanoidRootPart
	Rebel:SetPrimaryPartCFrame(RebelSpawn.CFrame)
	Rebel.MainPart.CFrame = RebelSpawn.CFrame
	Rebel.Parent = workspace.Map.Shopz

	local RebelHumanoid = Rebel.DealerMan:FindFirstChildOfClass("Humanoid")

	local Lifetime = _G.RebelLifetime

	Rebel.Radio.Intro:Play()

	local tab = {
		Title = "Unknown Alert";
		Text = "Rebel dealer has arrived.";
		Duration = 20;
		Button1 = "Close";
	}

	local fakeChar = CreateViewportCharacterM(Rebel)
	tab.ViewportIcon = fakeChar

	game:GetService("ReplicatedStorage").Events.Notification:FireAllClients(tab, "Beep2")	

	delay(Rebel.Radio.Intro.TimeLength, function()
		Rebel.Radio.Sound:Play()
	end)

	ReplicatedStorage.Events.NewDealer:FireAllClients(Rebel, true)

	delay(Lifetime, function()

		if not Rebel then
			return
		end

		if not Rebel.Parent then
			return
		end

		ReplicatedStorage.Events.NewDealer:FireAllClients(Rebel, false)

		local EquipAnim = RebelHumanoid:LoadAnimation(Dir.Equip)
		local PullAnim = RebelHumanoid:LoadAnimation(Dir.PullPin)

		local RightArm = Rebel.DealerMan:WaitForChild("Right Arm")

		local Handle = Dir.Handle:Clone()
		local Tool6D = Dir.Tool6D:Clone()

		Tool6D.Part0 = RightArm
		Tool6D.Part1 = Handle

		Handle.Parent = Rebel.DealerMan
		Tool6D.Parent = Rebel.DealerMan

		EquipAnim:Play(0.1)
		Handle.Equip:Play()

		delay(0.3, function()
			game:GetService("TweenService"):Create(Rebel.Radio.Sound, TweenInfo.new(3), {
				Volume = 0
			}):Play()

			PullAnim:Play(0.1)
			Handle.PinPullSound:Play()

			task.wait(0.5)

			Tool6D.Part0 = nil
			Handle.HB.Massless = false
			Handle.Parent = workspace.Debris.VParts
			Handle:SetNetworkOwner(nil)
			Handle.HB.CanCollide = true
			Handle.CFrame = (RightArm and RightArm.CFrame) or Handle.CFrame
			Handle.Bounce:Play()

			task.wait(0.75)

			game.Debris:AddItem(Handle, 3)

			local ePart = Dir.SmokeExplosion:Clone()
			ePart.CFrame = Rebel.MainPart.CFrame
			ePart.Parent = workspace.Debris

			for _,v in pairs(Handle:GetChildren()) do
				if not v:IsA("Attachment") and not v:IsA("Trail") then
					game.Debris:AddItem(v,1)
				end
			end

			delay(3, function()
				Rebel:SetPrimaryPartCFrame(RebelSpawn.CFrame * CFrame.new(0, -20, 0))

				delay(0.5, function()
					Rebel:Destroy()
					ActiveRebel = false
				end)
			end)
		end)
	end)
end

local modes = require(script:WaitForChild("modesDefine"))
_G.AffectChar = function(char,mode,tim,name,amount)
	if not char or not char.Parent then return end
	local vf = _G.GVF(char.Name)
	if vf then
		local x
		if (modes[mode]==2) then
			x = Instance.new("NumberValue")
			x.Name = (name ~= nil and mode .. "_" .. name) or mode
			x.Value = amount
			x.Parent = vf.Currents

			if tim ~= math.huge then
				monitorDestroyEVENT:Fire(x,tim)
			end
			return x
		elseif (modes[mode]==1) then
			x = Instance.new("NumberValue")
			x.Name = "DRSTNCE"
			x.Value = amount
			x.Parent = vf.Currents

			if tim ~= math.huge then
				monitorDestroyEVENT:Fire(x,tim)
			end
			return x			
		else
			x = Instance.new("BoolValue")
			x.Name = mode

			if mode == "ADT" and char and char:FindFirstChild("Humanoid") then
				x.Parent = char.Humanoid
			else
				x.Parent = vf.Currents
			end

			if tim ~= math.huge then
				monitorDestroyEVENT:Fire(x,tim)
			end
			return x 		
		end
	end

	return nil
end

_G.GetDmgMulti1 = function(char)
	if not char or not char.Parent then return 1 end
	local vf = _G.GVF(char.Name)

	if vf then
		local n = 1

		for _,v in pairs(vf.Currents:GetChildren()) do
			if string.find(v.Name,"DmgM1") then
				n = n * v.Value
			end
		end

		return n
	end

	return 1
end


_G.cTag = function(Obj,str,tim)
	CollectionService:AddTag(Obj,str)
	if tim then
		delay(tim,function()
			if Obj and Obj.Parent then
				CollectionService:RemoveTag(Obj,str)
			end
		end)
	end
end

_G.gTag = function(Obj,str)
	return CollectionService:HasTag(Obj,str)	
end

_G.SMains = {
	ForceChar = function(Char,Part,Force,Time,x)
		Force = Force * Part:GetMass()

		local Plr = Players:GetPlayerFromCharacter(Char)

		if not x and Plr and Char:FindFirstChild("Humanoid") and Char:FindFirstChild("Humanoid").Health > 0 then
			ReplicatedStorage.Events.FT_:FireClient(Plr,Part,Force,Time)
		else
			local bf = Instance.new("BodyForce")
			bf.Force = Force
			_G.cTag(bf,"BM")
			bf.Parent = Part
			Debris:AddItem(bf,Time)			
		end
	end;

	ForceT = function(p,Force,neededM,angDiv,dontRemove,customTim)
		local FORCE_GRANULARITY = 1
		neededM = neededM or 1
		angDiv = angDiv or 1

		local currentVelocity = p.Velocity
		local imp = Force
		local deltaVelocity = imp / p:GetMass() -- m * del-v = F * del-t = Impulse


		local forceNeeded = 196.2 * p:GetMass() -- F = ma
		forceNeeded = forceNeeded * neededM

		local delta = p.Position - (lookAt(p.Position - Force, p.CFrame.p) * CFrame.new(0,-1,5)).p
		local normal = (delta == Vector3.new(0,0,0))
			and Vector3.new(0,1,0)
			or  delta.unit

		local radius = p.Size.magnitude / 2	
		local r = 0	
		local frac = 1 - math.max(0, math.min(1, (r-2)/radius))

		local surfaceArea = radius * radius
		local impulse = normal * Force * surfaceArea * (1.0 / 4560.0)


		---------
		local rotImpulse = impulse * 0.5 * radius
		local currentRotVelocity = p.RotVelocity
		local momentOfInertia = (2 * p:GetMass() * radius * radius / 5) -- moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
		local deltaRotVelocity = rotImpulse / momentOfInertia 

		local networkOwner = nil
		pcall(function()
			networkOwner = p:GetNetworkOwner()
		end)

		local hasPlr = (networkOwner ~= nil and p:IsDescendantOf(workspace.Characters)) and networkOwner

		local torqueNeeded = 20 * momentOfInertia -- torque = r x F, want about alpha = 20 rad/s^2, alpha * P = torque
		local ROT_MAXTORQUE = Vector3.new(torqueNeeded, torqueNeeded, torqueNeeded) * 10 * frac
		local ROT_ANGULARVELOCITY = ((currentRotVelocity + deltaRotVelocity) * 1000) * angDiv

		local bodyV_MAXFORCE = Vector3.new(forceNeeded, forceNeeded * 1.1, forceNeeded) * 3 * frac
		local bodyV_VELOCITY = currentVelocity + deltaVelocity

		local lTim = customTim or 0.2

		if hasPlr then
			local nam1 = "ForceT_Ang"
			local nam2 = "ForceT_bodyV"

			if dontRemove then
				nam1 = nam1  .. "_DR"
				nam2 = nam2 .. "_DR"
			end

			local e = {
				["BodyAngularVelocity"] = {
					Paras = {
						MaxTorque = ROT_MAXTORQUE;
						AngularVelocity = ROT_ANGULARVELOCITY;
						Name = nam1;

					};
					Time = lTim/FORCE_GRANULARITY
				};
				["BodyVelocity"] = {
					Paras = {
						MaxForce = bodyV_MAXFORCE;
						Velocity = bodyV_VELOCITY;
						Name = nam2;
					};
					Time = lTim/FORCE_GRANULARITY;
				}
			}
			ReplicatedStorage.Events.CFRCE:FireClient(hasPlr,p,e)
		else
			for _,v in pairs(p:GetChildren()) do
				if v.Name == "ForceT_Ang" or v.Name == "ForceT_bodyV" then
					v:Destroy()
				end
			end

			local rot = Instance.new('BodyAngularVelocity')
			rot.Name = "ForceT_Ang"
			_G.cTag(rot,"BM")

			rot.MaxTorque = ROT_MAXTORQUE
			rot.angularvelocity =  ROT_ANGULARVELOCITY

			local bodyV = Instance.new('BodyVelocity')
			bodyV.Name = "ForceT_bodyV"
			_G.cTag(bodyV,"BM")

			if dontRemove then
				bodyV.Name = bodyV.Name .. "_DR"
				rot.Name = rot.Name .. "_DR"
			end

			bodyV.MaxForce =  bodyV_MAXFORCE
			bodyV.Velocity =  bodyV_VELOCITY

			rot.Parent = p
			game.Debris:AddItem(rot, 0.2/FORCE_GRANULARITY)
			--------------
			bodyV.Parent = p
			game.Debris:AddItem(bodyV, 0.2/FORCE_GRANULARITY)			
		end
	end;

	RagdollChar = function(Char,t)
		if Char and Char.Parent and _G.GVF and _G.GVF(Char.Name) then
			_G.GVF(Char.Name).RagdollTime.Value = _G.GVF(Char.Name).RagdollTime.Value + (t and t or 0)
		end
	end;

	CreateArmor = function(char,partName)
		local vF = char and _G.GVF(char.Name)

		if vF then
			if partName == "Head" or partName == "Left Arm" or partName == "Right Arm" or partName == "Torso" or partName == "Left Leg" or partName == "Right Leg" then
				vF.ArmoredParts[partName].Value = true
			end
		end
	end,

	RemoveArmor = function(char,partName)
		local vF = char and _G.GVF(char.Name)

		if vF then
			if partName == "Head" or partName == "Left Arm" or partName == "Right Arm" or partName == "Torso" or partName == "Left Leg" or partName == "Right Leg" then
				vF.ArmoredParts[partName].Value = false
				vF.ArmoredParts[partName]:SetAttribute("Multi",1)

			end
		end
	end,

	IsArmored = function(char,partName,x)
		local vF = char and _G.GVF(char.Name)

		local isArmored = false
		local armorDmgMulti = nil
		if vF then
			if partName == "Head" or partName == "Left Arm" or partName == "Right Arm" or partName == "Torso" or partName == "Left Leg" or partName == "Right Leg" then
				isArmored = vF.ArmoredParts[partName].Value

				armorDmgMulti = vF.ArmoredParts[partName]:GetAttribute("Multi")

				local hpV
				if partName == "Head" then
					hpV = vF.ArmorHP.Head
				else
					hpV = vF.ArmorHP.Body
				end

				if isArmored and x then
					if hpV.Value <= 0 then
						return false
					end
				end

				return isArmored,armorDmgMulti,hpV.Value > 0
			end
		end
	end,

	DamageArmor = function(char,typ,amt,playerWhoBroke)
		local vF = char and _G.GVF(char.Name)

		if vF then
			local both = vF.ArmorHP:GetAttribute("Both")

			if both then
				vF.ArmorHP["Body"].Value = vF.ArmorHP["Body"].Value - amt
				vF.ArmorHP["Head"].Value = vF.ArmorHP["Body"].Value
			else
				vF.ArmorHP[typ].Value = vF.ArmorHP[typ].Value - amt
			end

			local broke = vF.ArmorHP[typ].Value <= 0

			if broke then
				if playerWhoBroke then
					local xp = 50
					xp = math.min(xp,100)
					ServerStorage.Events3.AyuP:Fire("KLJ8902209SANK8234LDFG0OKJAKA984231ZZ04LGXBNBZ1U912",playerWhoBroke,xp)
				end

				if both or typ == "Body" then
					if vF.Armor_BodyOBJ.Value and vF.Armor_BodyOBJ.Value.Parent and vF.Armor_BodyOBJ.Value:FindFirstChild("BrokenM") then
						local armor = vF.Armor_BodyOBJ.Value
						require(armor.BrokenM)(char,"Broken")
					end
				end	
				if both or typ == "Head" then
					if vF.Armor_HeadOBJ.Value and vF.Armor_HeadOBJ.Value.Parent and vF.Armor_HeadOBJ.Value:FindFirstChild("BrokenM") then
						local armor = vF.Armor_HeadOBJ.Value
						require(armor.BrokenM)(char,"Broken")
					end
				end

				if vF.ArmorHP[typ]:GetAttribute("DestroyOnBreak") == true then
					coroutine.wrap(function()
						--wait()
						if both or typ == "Head" then
							RemoveHelmetM(char,vF.Armor_HeadOBJ.Value.Name)
						end
						if both or typ == "Body" then
							RemoveVestM(char,vF.Armor_BodyOBJ.Value.Name)
						end
					end)()
				end

				--for _,v in pairs(Players:GetPlayers()) do
				--	REMOTES.Effect:FireClient(v,"ArmorBreak",player,hit,hHumanoid,shot.Directions[index],pos,normal)
				--end
			end

			return true,broke
		end
	end,

	NewDisplayItem = function(char,item)
		local CheckM = ServerStorage.Modules:FindFirstChild("RetrieveExoticData")
		local IsExotic,E_Name
		local itemName = item.Name

		if item:GetAttribute("exotic") and (itemName ~= "Wrench" or itemName ~= "Balisong" or itemName ~= "Rambo") then
			IsExotic,E_Name = require(CheckM).GetItem(item)

			if IsExotic then
				itemName = E_Name
			end
		end

		local dif = char:FindFirstChild("DisplayItems")

		local f = ServerStorage.Storage.DisplayItems

		if item:GetAttribute("ripper") then
			itemName = "Chainsaw_Rip"
		end

		if item:GetAttribute("voidedge") then
			itemName = "Voidedge"
		end

		if item:GetAttribute("goldenkatana") then
			itemName = "Katana_Gold"
		end
		
		if item:GetAttribute("trickshot") then
			itemName = "Mare_Trickshot"
		end
		
		if item:GetAttribute("cupid") then
			itemName = "bfg_cupid"
		end
		
		if item:GetAttribute("hellfire") then
			itemName = "Ithaca_Hellfire"
		end
		
		if item:GetAttribute("m4a1_heritage") then
			itemName = "m4a1_heritage"
		end
		
		if item:GetAttribute("m4a1_subzero") then
			itemName = "m4a1_subzero"
		end
		
		if item:GetAttribute("customModel") then
			if item:GetAttribute("customModel") ~= true then
				itemName = item:GetAttribute("customModel")
			end
		end

		if dif and f:FindFirstChild(itemName) and f[itemName]:FindFirstChild("Parts") then
			if not dif:FindFirstChild(itemName) then
				local nf = f:FindFirstChild(itemName):Clone()

				local function RigPartFolder(Part)
					local function FindInFolder(FindPart)
						for i,v in pairs(nf.Parts:GetChildren()) do
							if v.Name == FindPart.Name then
								return v
							end
						end
					end
					local FolderToRig = FindInFolder(Part)
					if FolderToRig ~= nil then
						for i,RigPart in pairs(FolderToRig:GetDescendants()) do
							if RigPart:IsA("BasePart") then
								if RigPart.Name ~= "OriginPart" then
									--RigPart.Anchored = false
									--RigPart.Massless = true
									--RigPart.CanCollide = false
									--RigPart.CastShadow = false
									--RigPart.CanTouch = false
									RigPart:SetAttribute("di_Part",true)

									local Weld = Instance.new("Weld",RigPart)
									Weld.Name = RigPart.Name .. "_Weld"
									Weld.Part0,Weld.Part1 = Part,RigPart

									Weld.C0 = FolderToRig["OriginPart"].CFrame:Inverse()
									Weld.C1 = RigPart.CFrame:Inverse()

									RigPart.Anchored = false
									RigPart.Massless = true
									RigPart.CanCollide = false
								else
									game.Debris:AddItem(RigPart,0.5)
								end
							end
						end
					end
				end

				local function Rig()
					for i,cpart in pairs(char:GetChildren()) do
						if cpart:IsA("BasePart") then
							RigPartFolder(cpart)
						end
					end	
				end

				Rig()

				if not item:GetAttribute("voidedge") then
					local appliedSkin = item:GetAttribute("AppliedSkin")
					if appliedSkin then
						ServerStorage.Events3.ApplySkin_DM:Invoke(nf,appliedSkin,Players:GetPlayerFromCharacter(char))
					end
				end

				nf.Parent = dif

				return nf
			else
				return dif:FindFirstChild(itemName)
			end
		end
	end,
}


_G.CVF = function(p)
	local v
	if not charStatsFolder then return end

	if not charStatsFolder:FindFirstChild(p.Name) then
		v = ServerStorage.Storage.ValuesFolder:Clone()
		v.Name = p.Name
		v.Parent = charStatsFolder
		return v
	else
		v = charStatsFolder[p.Name]
		v:ClearAllChildren()
		for _,x in pairs(ServerStorage.Storage.ValuesFolder:GetChildren()) do
			x:Clone().Parent = v
		end
	end
	return v
end

_G.NPC_Handler = function(npc,doRandomAvatar)
	local CharacterHandler = require(ServerScriptService.CharacterHandler)

	CharacterHandler.NewCharacter(npc,_G.CVF(npc),true,doRandomAvatar)
end

_G.LimbHealthFull = function(Character)
	local VF = _G.GVF(Character.Name)
	if not VF then return end


	local f = true

	for _,v in pairs(VF.HealthValues:GetChildren()) do
		if v.Value < v.MaxValue or v.Broken.Value then
			f = false
			break
		end		
	end

	return f
end

_G.LimbCheck = function(Character,n,m)
	local VF = _G.GVF(Character.Name)
	if not VF then return end

	local f = false

	for _,v in pairs(VF.HealthValues:GetChildren()) do
		if v.Name == n then	
			if (m == "Broken" and v.Broken.Value) or (m == "Destroyed" and v.Destroyed.Value) then
				f = true
				break
			end
		end		
	end

	return f
end

_G.GVF = function(Name)
	Name = (typeof(Name) == "Instance" and Name.Name) or Name
	return ReplicatedStorage.CharStats:FindFirstChild(Name)
end

_G.RagdollCheck = function(Character,t)
	--t = t or 0
	local vf =  _G.GVF(Character.Name)
	if vf and vf:FindFirstChild("RagdollTime") then

		local x = true

		if t then
			x = tick() - vf.RagdollTime.Tick.Value >= t
		end

		return (vf.RagdollTime.RagdollSwitch.Value or vf.RagdollTime.Value > 0 or vf.RagdollTime.SRagdolled.Value) and x
	end
	return false
end

_G.GetRagdollV = function(Character)
	if _G.GVF(Character.Name) and _G.GVF(Character.Name):FindFirstChild("RagdollTime") then 
		return _G.GVF(Character.Name).RagdollTime
	end
end

_G.DownedCheck = function(Character,n)
	local vF =_G.GVF(Character.Name) 
	n = n or 0

	if vF then

		local downed = vF.Downed.Value

		local t = tick() - vF.Downed.Tick.Value

		return downed and t >= n
	end
	return false,0
end


_G.InCombatCheck = function(plr,m,n)
	local vf = _G.GVF(plr.Name)
	if not vf then return end

	local inCombat = false

	local isCombatZone = false

	if m then
		for _,v in pairs(vf.Tags:GetChildren()) do
			if string.find(v.Name,"inCombat_") then
				inCombat = true
				if v:FindFirstChild("CZ") then
					isCombatZone = true
				end
			end
		end
	end

	local inC = ((not n and vf.Tags:FindFirstChild("creator")) or (m and inCombat))

	return inC,isCombatZone
end


function TagCharMain(char,humanoid,player,vf,Time,toolName,hitDistance,keepText)
	if char.Name == player.Name or not player:IsA("Player") then return end

	local oC = vf.Tags:FindFirstChild("creator")

	--print("TAGCHARMAIN1",oC and oC:GetAttribute("ccc"))

	_G.AssistChar(char,oC and oC.Value,Time,toolName,nil,oC and oC:GetAttribute("ccc"))

	_G.UntagChar(char,"creator")

	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"

	Creator_Tag:SetAttribute("tick",tick())
	Creator_Tag:SetAttribute("ccc",(player and player.Parent and player.Character and player.Character:GetAttribute("ccc")))

	--print("TAGCHARMAIN2",Creator_Tag:GetAttribute("ccc"))

	local nplr = typeof(player) == "Instance" and player
	Creator_Tag.Value = nplr or nil

	if toolName ~= nil then
		local toolNameV= Instance.new("StringValue")
		toolNameV.Name = "Tool"
		toolNameV.Value = toolName
		toolNameV.Parent = Creator_Tag
	end

	if hitDistance ~= nil and typeof(hitDistance) == "number" then
		local distanceV = Instance.new("IntValue")
		distanceV.Name = "Distance"
		distanceV.Value = hitDistance
		distanceV.Parent = Creator_Tag
	end

	if keepText then
		local ktV = Instance.new("BoolValue")
		ktV.Name = "KeepText"
		ktV.Value = true
		ktV.Parent = Creator_Tag
	end

	Creator_Tag.Parent = vf.Tags

	local con1,con2

	local charTRUE,tagTRUE = true,true

	con1 = char.AncestryChanged:Connect(function(_,parent)
		if not parent then
			charTRUE = false
			con1:Disconnect()
		end
	end)
	con2 = Creator_Tag.AncestryChanged:Connect(function(_,parent)
		if not parent then
			tagTRUE = false
			con2:Disconnect()
		end
	end)

	local function yedo()
		wait(Time)
		repeat wait(1) until (not charTRUE or not tagTRUE) or (not _G.RagdollCheck(char) and not _G.DownedCheck(char) and humanoid.Health > 5)
		Creator_Tag:Destroy()			
	end
	local Func = coroutine.create(function()
		yedo()
	end)
	coroutine.resume(Func)

	spawn(function()
		yedo()
	end)	
end

function AssistCharMain(char,player,vf,Time,toolName,hitDistance,customccc)
	if char.Name == player.Name then return end

	local Assist_Tag =  Instance.new("ObjectValue")
	Assist_Tag.Name = "assist"

	Assist_Tag:SetAttribute("tick",tick())
	Assist_Tag:SetAttribute("ccc",customccc or (player and player.Parent and player.Character and player.Character:GetAttribute("ccc")))

	--print("ASSIST",player.Name,customccc,Assist_Tag:GetAttribute("ccc"))

	local nplr = typeof(player) == "Instance" and player
	Assist_Tag.Value = nplr or nil

	if toolName ~= nil then
		local toolNameV= Instance.new("StringValue")
		toolNameV.Name = "Tool"
		toolNameV.Value = toolName
		toolNameV.Parent = Assist_Tag
	end

	Assist_Tag.Parent = vf.Tags

	local humanoid = char:FindFirstChild("Humanoid")

	local con1,con2

	local charTRUE,tagTRUE = true,true

	con1 = char.AncestryChanged:Connect(function(_,parent)
		if not parent then
			charTRUE = false
			con1:Disconnect()
		end
	end)
	con2 = Assist_Tag.AncestryChanged:Connect(function(_,parent)
		if not parent then
			tagTRUE = false
			con2:Disconnect()
		end
	end)

	local function yedo()
		wait(Time)
		repeat wait(1) until (not charTRUE or not tagTRUE) or (not _G.RagdollCheck(char) and not _G.DownedCheck(char) and humanoid.Health > 5)
		Assist_Tag:Destroy()			
	end
	coroutine.wrap(function()
		yedo()
	end)()
end

local tagCharEVENT = Instance.new("BindableEvent")
tagCharEVENT.Event:Connect(TagCharMain)

local assistCharEVENT = Instance.new("BindableEvent")
assistCharEVENT.Event:Connect(AssistCharMain)

_G.CombatTagChar = function(player,Time,customName,isCombatZone,customData)
	if not (player and player.Parent and player.ClassName == "Player") then return end

	local vf = _G.GVF(player.Name)
	local char = player.Character
	local humanoid = char:FindFirstChild("Humanoid")	

	if not humanoid or humanoid.Health <=0 or not char or not char.Parent or not vf then return end

	customName = customName or ""	

	local Combat_Tag = Instance.new("ObjectValue")
	game.Debris:AddItem(Combat_Tag,Time)
	Combat_Tag.Name = "inCombat_" .. customName

	if customData then
		Combat_Tag:SetAttribute("HasCustomData",true)
		Combat_Tag:SetAttribute("SetTime",time())

		Combat_Tag:SetAttribute("CustomData_Killer",customData.killer)
		Combat_Tag:SetAttribute("CustomData_Distance",customData.distance)
		Combat_Tag:SetAttribute("CustomData_Weapon",customData.weapon)
	end

	local nplr = typeof(player) == "Instance" and player
	pcall(function()
		Combat_Tag.Value = nplr
	end)
	Combat_Tag.Parent = vf.Tags

	if isCombatZone then
		local b = Instance.new("BoolValue")
		b.Name = "CZ"
		b.Parent = Combat_Tag
	end

	monitorDestroyEVENT:Fire(Combat_Tag,Time)

	return Combat_Tag
end

_G.TagChar = function(char,player,Time,minHP,o,toolName,hitDistance,keepText)
	local humanoid = char:FindFirstChild("Humanoid")
	local vf = _G.GVF(char.Name)
	if not player or not player.Parent or not humanoid or not char or not char.Parent or not vf then return end

	local c = true
	if not o then
		if humanoid.Health <= minHP and vf.Tags:FindFirstChild("creator") then
			c = false
		end
	elseif o and vf.Tags:FindFirstChild("creator") then
		c = false
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

	if c then
		tagCharEVENT:Fire(char,humanoid,player,vf,Time,toolName,hitDistance,keepText)
	else
		_G.AssistChar(char,player,Time,toolName)
	end
end

_G.AssistChar = function(char,player,Time,toolName,hitDistance,customccc)
	local vf = _G.GVF(char.Name)
	if not player or not player.Parent or not char or not char.Parent or not vf then return end

	--	for _,v in pairs(vf.Tags:GetChildren()) do
	--		if v.Name == "assist" and v.Value == player then
	--			v:Destroy()
	--		end
	--	end

	--	print("ASSIST__1",player,customccc)

	_G.UntagChar(char,"assist",player)

	assistCharEVENT:Fire(char,player,vf,Time,toolName,nil,customccc)
end

_G.UntagChar = function(char,n,player)
	local vf = _G.GVF(char.Name)
	if not vf then return end

	if n == "creator" then
		for i,v in pairs(vf.Tags:GetChildren()) do
			if v.Name == "creator" then
				v:Destroy()
			end
		end
	elseif n == "assist" then
		local t = {}
		for _,v in pairs(vf.Tags:GetChildren()) do
			if v.Name == "assist" then
				table.insert(t,v)
			end
		end
		for i = 1, math.floor(#t/2) do
			local j = #t - i + 1
			t[i], t[j] = t[j], t[i]
		end

		local n = 0
		for i,v in pairs(t) do
			if v.Value == player then
				v:Destroy()
			else
				--if n > GameSettings.MaxAssists then
				--	v:Destroy()
				--end
				n = n + 1
			end
		end
	end
end

_G.GetTag = function(plr)
	local vf = _G.GVF(plr.Name)
	if not vf then return end
	if vf.Tags:FindFirstChild("creator") then
		return vf.Tags.creator
	end
end

_G.GetSecondaryTag = function(plr)
	local vf = _G.GVF(plr.Name)
	if not vf then return end

	local gt = nil
	local maxT = 0

	for i,v in pairs(vf.Tags:GetChildren()) do
		if v:GetAttribute("HasCustomData") and v:GetAttribute("SetTime") then
			if v:GetAttribute("SetTime") > maxT then
				maxT = v:GetAttribute("SetTime")
				gt = v
			end
		end
	end

	if gt then
		local t = {}

		local tag = gt

		t.killer = tag:GetAttribute("CustomData_Killer");
		t.distance = tag:GetAttribute("CustomData_Distance");
		t.weapon = tag:GetAttribute("CustomData_Weapon");

		return t
	end
end

_G.GetAssists = function(plr,killer)
	local vf = _G.GVF(plr.Name)
	if not vf then return {} end
	if plr.Character and plr.Character:GetAttribute("NoKillAssists") then
		return {}
	end

	local l = {}
	for _,v in pairs(vf.Tags:GetChildren()) do
		if v.Name == "assist" then
			if v.Value ~= killer then
				table.insert(l,v)
			end
		end
	end

	table.sort(l,function(a,b)
		return a:GetAttribute("tick") > b:GetAttribute("tick")
	end)

	local l2 = {}
	local checkedx = {}

	for _,v in pairs(l) do
		if #l2 >= GameSettings.MaxAssists then
			break
		end

		if v.Value and not checkedx[v.Value] then
			local c = true

			checkedx[v.Value] = true

			--print(v.Value.Name,v.Value.Character and v.Value.Character:GetAttribute("ccc"),v:GetAttribute("ccc"))

			if ServerStorage.Values.NoAssistIfDie.Value then
				if not (v.Value and v.Value.Character and v.Value.Character:GetAttribute("ccc") == v:GetAttribute("ccc") and v.Value.Character:FindFirstChild("Humanoid") and v.Value.Character:FindFirstChild("Humanoid").Health > 0) then
					c = false
				end
				--print("yeno",c)
			end

			if c then
				table.insert(l2,v)
			end
		end
	end

	checkedx = nil
	return l2
end

_G.TeamCheck = function(Player,gPlayer)
	if typeof(Player) == "BrickColor" or typeof(gPlayer) == "BrickColor" then
		if typeof(Player) == "BrickColor" and typeof(gPlayer) == "BrickColor" then -- are both brickcolors
			return Player == gPlayer -- same team color
		elseif typeof(Player) == "BrickColor" and gPlayer.Parent then
			if gPlayer.Neutral then
				return false
			else
				return Player == gPlayer.TeamColor
			end
		elseif Player.Parent and typeof(gPlayer) == "BrickColor" then
			if Player.Netural then
				return false
			else
				return Player.TeamColor == gPlayer
			end
		end
	else
		if not Player or not Player.Parent or not gPlayer or not gPlayer.Parent then return end

		if (Player.Neutral==false and gPlayer.Neutral==false and Player.Team.Name=="Inmates" and gPlayer.Team.Name=="Inmates") then
			return false
		end

		if Player == gPlayer then
			return false
			--elseif (Player.Neutral and gPlayer.TeamColor == BrickColor.new("Earth green")) or (gPlayer.Neutral and Player.TeamColor == BrickColor.new("Earth green")) then
			--	return true
		elseif (Player.Character and gPlayer.Character) and Player.Character:FindFirstChild("IsRCU") and gPlayer.Character:FindFirstChild("IsRCU") then
			return true
			--elseif (Player.Character and gPlayer.Character) and Player.Character:FindFirstChild("IsURM") and gPlayer.Character:FindFirstChild("IsURM") then
			--	return true
		elseif (Player.Character and gPlayer.Character) and Player.Character:GetAttribute("Fallen") and gPlayer.Character:GetAttribute("Fallen") then
			return true
		elseif Player.TeamColor ~= gPlayer.TeamColor or ((Player.Neutral == true and gPlayer.Neutral == true)) then
			return false
		end
	end


	return true
end

_G.MonitorSound = function(a,b,c,d,e,f,g,h)
	ReplicatedStorage.Events.MonitorSound:FireAllClients(a,b,c,d,e,f,g,h)
end

function ZaWarudoWait()
	ReplicatedStorage.Values.ZaWarudo:GetPropertyChangedSignal("Value"):Wait()
end
_G.ZaWarudoWait = function()
	if ReplicatedStorage.Values.ZaWarudo.Value then
		ZaWarudoWait()
	else 
		return false
	end
end

_G.CheckIfCan = function(Character,arm,ct1,ct2,blahblahfall)
	local Humanoid = Character and Character.Parent and Character:FindFirstChild("Humanoid")
	local vf = Humanoid and _G.GVF(Character.Name)

	if not vf then return false end

	local state = Humanoid:GetState()	

	if ReplicatedStorage.Values.ZaWarudo.Value and ReplicatedStorage.Values.ZaWarudo.Owner.Value ~= Players:GetPlayerFromCharacter(Character) then

		return false
	elseif not Character:FindFirstChild("HumanoidRootPart") or (not Character:FindFirstChild("Torso") and not Character:FindFirstChild("UpperTorso")) or not Character:FindFirstChild("Head") then
		print("torso")
		return false
	elseif not _G.AliveCheck(Character,ct2) or (arm ~= "Any" and (not Character:FindFirstChild(arm or "Right Arm") and not Character:FindFirstChild(arm or "RightHand"))) then
		print("head")
		return false
	elseif _G.RagdollCheck(Character,ct1) then
		print("ragdoll")
		return false
	elseif _G.DownedCheck(Character,ct2) then
		print("down")
		return false
	elseif vf and vf.Handcuffed.Value then
		print("cuff")
		return false

	elseif not blahblahfall and (state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp or state == Enum.HumanoidStateType.Seated) and not Character.HumanoidRootPart.Anchored then
		print("state")
		return false
	else
		local plr = Players:GetPlayerFromCharacter(Character)
		local pd = plr and _G.GetPlayerData(plr)
		if plr and pd and pd.Shadowed.Value then
			return false
		end
	end
	return true
end

_G.AliveCheck = function(Character,ct)
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	local Head = Character and Character:FindFirstChild("Head")
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	local Torso = Character and (Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso"))

	local deadTick = (Humanoid and Humanoid:GetAttribute("DeathTick")) or 0
	ct = ct or 0

	local isDead = Humanoid and (Humanoid:GetState() == Enum.HumanoidStateType.Dead) and tick() - deadTick >= ct

	return ((Humanoid and not isDead) and Head and HumanoidRootPart and Torso)
end

_G.CreateBloodTrail = function(a,b,c,d,e,f)
	EventsFolder.BloodTrailEvent:FireAllClients(a,b,c,d,e,f)
end

_G.CreateBloodHit = function(Attachment,multi)
	if not Attachment or not Attachment.Parent or not Attachment.Parent.Parent then return end
	EventsFolder.BloodHitEvent:FireAllClients(Attachment,multi)
end

_G.CreateBloodAttachment = function (parent,cf)
	local Attachment = Instance.new("Attachment")
	Attachment.Name = "_"
	Attachment.Parent = parent
	Attachment.WorldCFrame = cf
	game.Debris:AddItem(Attachment,30)
	return Attachment
end

local tot = 0
_G.DamageOverTime = function(Humanoid,Dmg,Time,STEP,CanKill,cantCancel,forever)
	local vF = _G.GVF(Humanoid.Parent.Name)

	local bleedVal

	local o = vF and vF.Currents:FindFirstChild("Bleeding")
	if o then
		o:Destroy()
	end

	local bleeding = true

	if vF then
		bleedVal = Instance.new("BoolValue")
		bleedVal.Name = "Bleeding"
		if cantCancel then
			bleedVal.Name = "Bleeding2"
		end
		bleedVal.Parent = vF.Currents
		game.Debris:AddItem(bleedVal,100)

		local bleedCon
		bleedCon = bleedVal.AncestryChanged:Connect(function(_,parent)
			if not parent then
				bleedCon:Disconnect()
				bleeding = false
			end
		end)
	end

	local Func = coroutine.create(function()
		--Step = 0.15
		local t = 0
		local currentDamage

		local function doEnd()
			return Humanoid == nil or Humanoid.Parent == nil or (t >= Time and not forever) or ((Humanoid.Health <= 10 or Humanoid.Health - currentDamage <= 10) and not CanKill) or (not cantCancel and not bleeding)
		end

		repeat wait(STEP)
			t = t + STEP
			currentDamage = (forever and Dmg) or (Dmg/(Time/STEP)) -- Insert here
			if doEnd() then break end
			tot = tot + currentDamage

			if vF and vF:FindFirstChild("Currents") and not vF.Currents:FindFirstChild("AntiBleed") or cantCancel then
				Humanoid:TakeDamage(currentDamage) -- ?
			end
		until doEnd()
		if bleedVal and bleedVal.Parent then
			bleedVal:Destroy()
		end
	end)

	coroutine.resume(Func)
end

_G.Scream = function(Character,Part,Name,noCancel)
	if Character and Part and Part.Parent then

		local isScreaming = false

		for _,v in pairs(Part:GetChildren()) do
			if string.find(v.Name,Name) or string.find(string.sub(v.Name,0,string.len(v.Name) -1),string.sub(Name,0,string.len(Name) -1)) then
				if noCancel then
					isScreaming = true
				else
					v:Stop()
				end

			end
		end

		if noCancel and isScreaming then
			return
		end

		local hum = Character:FindFirstChild("Humanoid")

		local o = game.ServerStorage.Storage.PlayerSounds.Head:FindFirstChild(Name)
		local s = o:Clone()
		game.Debris:AddItem(s,o.TimeLength + 1)
		s.Parent = Part

		local vF = _G.GVF(Character.Name)
		if hum.Health > 0 and not (vF and vF.HealthValues.Head.Broken.Value) then
			s:Play()
		end

		return s

		--if Part:FindFirstChild(Name) then
		--	Part[Name]:Play()
		--	return Part[Name]
		--end
	end
end

local brokenz = {}
local jointNames = {
	["Head"] = "Neck";
	["Left Arm"] = "Left Shoulder";
	["Right Arm"] = "Right Shoulder";
	["Left Leg"] = "Left Hip";
	["Right Leg"] = "Right Hip";
}

_G.DamageJoint = function(hit,hitChar,Dmg,Mode,noSound,cantSurvive,attackingPlr,noBreak,...)
	if not (hit and hit.parent) then return end

	local Humanoid = hitChar:FindFirstChild("Humanoid")

	local hitPlr = Players:GetPlayerFromCharacter(hitChar)
	local Values = _G.GVF(hitChar.Name)

	if not jointNames[hit.Name] then return end

	if Values then
		Values.Downed.Resisting.Value = false

		local hV = Values.HealthValues[hit.Name]
		
		if (_G.CharHasTrait(hitChar, "strongbones")) then
			Dmg *= 0.5 end
		if (_G.CharHasTrait(hitChar, "fragilebones")) then
			Dmg *= 2 end
		if (_G.CharHasTrait(hitChar, "kangaroolegs")) and (hV=="Left Leg" or hV=="Right Leg") then 
			Dmg*= 0.5 end

		if noBreak and hV.Value > 0 then
			hV.Value = math.max(hV.Value - Dmg,1)
		else
			hV.Value = hV.Value - Dmg 
		end

		local can = true
		if Mode == "BoneBreak" and (hV.Broken.Value or hV.Destroyed.Value) then
			can = false
		end
		if (Mode == "Destroy" or Mode == "Explode") and hV.Destroyed.Value then
			can = false
		end

		if can and hV.Value <=0 then		
			_G.BreakJoint(hit,hitChar,Mode,noSound,cantSurvive,...)
		end
	end
end

_G.BreakJoint = function(hit,hitChar,Mode,noSound,cantSurvive,...)
	--coroutine.resume(coroutine.create(function()
	if not (hit and hit.parent) then return end

	local n = jointNames[hit.Name]

	if not n then return end

	local Humanoid = hitChar:FindFirstChild("Humanoid")

	--		if not brokenz[hitChar] then
	--			brokenz[hitChar] = {}
	--			local c
	--			c = hitChar.AncestryChanged:Connect(function(_,parent)
	--				if not parent then
	--					brokenz[hitChar] = nil
	--					c:Disconnect()
	--				end
	--			end)
	--		end
	--		
	local hitPlr = Players:GetPlayerFromCharacter(hitChar)
	local Values = _G.GVF(hitChar.Name)

	if hitPlr and not noSound then
		_G.CombatTagChar(hitPlr,30,"BRKJ")
	end

	--_G.SMains.RagdollChar(hitChar,1)

	local isBroken = false
	local isBroken2 = false

	Values.Downed.Resisting.Value = false

	if Values.HealthValues:FindFirstChild(hit.Name) and Values.HealthValues[hit.Name].Broken.Value then
		isBroken = true
	end
	if Values.HealthValues:FindFirstChild(hit.Name) and Values.HealthValues[hit.Name].Destroyed.Value then
		isBroken2 = true
	end

	--hit.Massless = true

	local isBoneBreak = Mode == "BoneBreak"

	if isBoneBreak and not isBroken then
		local bsc = hitChar.HumanoidRootPart.CTs:FindFirstChild("RGCT_" .. n)

		if n == "Neck" then
			if hitChar.Torso:FindFirstChild(n) then 
				hitChar.Torso[n].Enabled = false
			elseif Values and Values.Motors:FindFirstChild(n) then
				Values.Motors[n].Enabled = false
			end

			if bsc then
				local at = bsc.Attachment1

				if not at:FindFirstChild("OriginOri") then
					local v = Instance.new("Vector3Value")
					v.Name = "OriginOri"
					v.Value = at.Orientation
					v.Parent = at
				end

				if hit.Name == "Head" then
					at.Orientation = Vector3.new(-70,math.random(-65,65),0)
				elseif hit.Name == "Left Leg" or hit.Name == "Right Leg" then
					at.Orientation = Vector3.new(math.random(-10,10),math.random(-75,75),math.random(-45,45))
				else
					at.Orientation = Vector3.new(math.random(-45,45),math.random(-45,45),math.random(-20,20))
				end

				local x = 2

				if hit.Name == "Left Leg" or hit.Name == "Right Leg" then
					--x = x * 2
				end

				bsc.TwistLimitsEnabled = true

				if not bsc:FindFirstChild("ori_UpperAngle") then
					local v = Instance.new("IntValue")
					v.Name = "ori_UpperAngle"
					v.Value = bsc.UpperAngle
					v.Parent = bsc
				end

				if not bsc:FindFirstChild("ori_TwistLowerAngle") then
					local v = Instance.new("IntValue")
					v.Name = "ori_TwistLowerAngle"
					v.Value = bsc.TwistLowerAngle
					v.Parent = bsc
				end

				if not bsc:FindFirstChild("ori_TwistUpperAngle") then
					local v = Instance.new("IntValue")
					v.Name = "ori_TwistUpperAngle"
					v.Value = bsc.TwistUpperAngle
					v.Parent = bsc
				end

				bsc.UpperAngle = bsc.UpperAngle / (x * 2)
				bsc.TwistLowerAngle = bsc.TwistLowerAngle / x
				bsc.TwistUpperAngle = bsc.TwistUpperAngle / x
			end

			if hit:FindFirstChild("Collider") then
				hit.Collider.CanCollide = false
			end


			if not noSound then
				local s = game.ServerStorage.Storage.MoreSounds.GoreSnap:Clone()
				s.PlaybackSpeed = s.PlaybackSpeed * math.random(900,1100)
				s.Parent = hit
				game.Debris:AddItem(s)
				s:Play()	
			end	
		end

		if not noSound then
			local s = game.ServerStorage.Storage.MoreSounds["BoneBreak" .. math.random(1,4)]:Clone()
			s.PlaybackSpeed = s.PlaybackSpeed * math.random(900,1100) / 1000
			s.Parent = hit

			game.Debris:AddItem(s)
			s:Play()
		end

	elseif Mode == "Explode" and hit.Transparency ~= 0.99 and not isBroken2 then
		hit.Transparency = 0.99
		hit.Size = Vector3.new()

		if hit.Name == "Head" and Humanoid then
			Humanoid:TakeDamage(Humanoid.MaxHealth + 10)
			Humanoid.Health = -100

			if hit:FindFirstChild("face") then
				hit.face:Destroy()
			end
			for _,v in pairs(Humanoid:GetAccessories()) do
				v:Destroy()
			end

			if hitChar:FindFirstChild("hasHelmet") and hitChar.hasHelmet.ClassName == "ObjectValue" then
				for  _,v in pairs(hitChar.hasHelmet.Value:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end

			--if Values.Armor_BodyOBJ.Value then
			--	for  _,v in pairs(Values.Armor_BodyOBJ.Value:GetDescendants()) do
			--		if v:IsA("BasePart") then
			--			v.Transparency = 1
			--		end
			--	end
			--end

			if Values.Armor_HeadOBJ.Value then
				for  _,v in pairs(Values.Armor_HeadOBJ.Value:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end

			if hit:FindFirstChild("FaceCenterAttachment") then
				_G.CreateBloodHit(hit["FaceCenterAttachment"],2)
			end

			local a = hit["FaceCenterAttachment"]
			local b = { -- Main
				Amount = 		{5,10};
				Speed = 		7;
				Spread = 		{-45,45};
				Size = 			7; -- Pool Size
				WidthScale =	3;
				UpVector = 		Vector3.new(0,-7.5,0);
				RepeatCount =	1; -- Amount of times to do
				RepeatTick =	0; -- Wait time between ticks
				MaxYAngle =		50;
			};
			_G.CreateBloodTrail(a,b,true,{0.5,1})
		end

		Values.HealthValues[hit.Name].Destroyed.Value = true
		Values.HealthValues[hit.Name].Broken.Value = true
		Values.HealthValues[hit.Name].Value = 1


	elseif not isBoneBreak and hitChar.HumanoidRootPart:FindFirstChild("CTs") and hitChar.HumanoidRootPart.CTs:FindFirstChild("RGCT_" .. n) and not isBroken2 then
		Values.HealthValues[hit.Name].Destroyed.Value = true
		Values.HealthValues[hit.Name].Broken.Value = true
		Values.HealthValues[hit.Name].Value = 1

		--	game.Debris:AddItem(hitChar.HumanoidRootPart.CTs["RGCT_" .. n],0)
		hitChar.HumanoidRootPart.CTs["RGCT_" .. n].Enabled = false
		if hitChar.Torso:FindFirstChild(n) then 
			hitChar.Torso[n].Enabled = false
			--game.Debris:AddItem(hitChar.Torso[n],0)
		elseif Values and Values.Motors:FindFirstChild(n) then
			Values.Motors[n].Enabled = false
			--game.Debris:AddItem(Values.Motors[n],0)
		end

		game.Debris:AddItem(hit,10)
		--
		if ... and typeof(...)=="table" then
			local atTable=...
			if atTable.handle and atTable.cnfig and atTable.cnfig.GrappleHead and atTable.creator and atTable.extraData and (atTable.extraData.combo==atTable.cnfig.GrappleHead.Combo or atTable.extraData.isEx==true) then
				--
				for i, v in pairs(hit:GetChildren()) do
					if v:IsA("BasePart") then
						v:Destroy()
					end
				end
				--
				hit.CollisionGroup = "No-Collide"
				hit.CanQuery = false
				hit.CFrame = atTable.handle.Tip.WorldCFrame
				hit.Velocity = Vector3.new(0, 0, 0)
				hit:SetAttribute("NoNetworkOwnerSet", true)
				--
				for i, v in pairs(hit:GetChildren()) do
					if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") then
						v:Destroy()
					end
				end
				--
				--
				--
				local weld = Instance.new("Weld")
				weld.Part0 = atTable.handle
				weld.Part1 = hit
				weld.C0=CFrame.new(0, 3.75, 0)*CFrame.Angles(0,math.rad(90),0)
				weld.Parent = atTable.handle
				--
				if hit:CanSetNetworkOwnership() then
					hit:SetNetworkOwner(atTable.creator)
				end
				--
				task.spawn(function()
					local timePassed = tick()
					repeat
						game:GetService("RunService").Heartbeat:Wait()
						if hit and hit.Parent and atTable.creator and atTable.creator.Parent then
							if hit:CanSetNetworkOwnership() then
								hit:SetNetworkOwner(atTable.creator)
							end
						end
					until (tick() - timePassed) >= 0.25 or hit == nil or hit.Parent == nil or atTable.creator == nil or atTable.creator.Parent == nil
				end)
			end
		end
	end

	if not isBoneBreak then
		local g = {}

		local z = ServerStorage.Storage.GoreBodies[n]:Clone()
		z.Name = "Gore_" .. z.Name
		z.Parent = hitChar
		table.insert(g,z)

		if ServerStorage.Storage.GoreBodies:FindFirstChild(n .. "2") then
			local z2 = ServerStorage.Storage.GoreBodies[n .. "2"]:Clone()
			z2.Name = "Gore_" .. z.Name
			z2.Parent = hitChar
			table.insert(g,z2)
		end
		ReplicatedStorage.Events.GorePart:FireAllClients(hitChar,g)
	end

	if hitChar and hitChar.Parent and hitChar:FindFirstChild("Torso") and hitChar.Torso["RGAB_" .. n] ~= nil then
		local a = hitChar.Torso["RGAB_" .. n]:Clone()
		a.Name = "BleedAttachment"
		a.Parent = hitChar.Torso
		game.Debris:AddItem(a,15)


		if not noSound then
			local b = { -- Main
				Amount = 		{2,3};
				Speed = 		15;
				Spread = 		{-50,50};
				Size = 			2.65; -- Pool Size
				WidthScale =	2;
				UpVector = 		Vector3.new(0,-5,0);
				RepeatCount =	1; -- Amount of times to do
				RepeatTick =	0.5; -- Wait time between ticks
				MaxYAngle =		50;
			};

			_G.CreateBloodTrail(a,b,true,{0.2,1})

			local b = { -- Main
				Amount = 		{1,1};
				Speed = 		5;
				Spread = 		{-50,50};
				Size = 			1.25; -- Pool Size
				WidthScale =	1.25;
				UpVector = 		Vector3.new(0,-7.5,0);
				RepeatCount =	10; -- Amount of times to do
				RepeatTick =	0.5; -- Wait time between ticks
				MaxYAngle =		50;
			};

			_G.CreateBloodTrail(a,b,true,{0.2,1})
		end
	end
	if not hit.Anchored and (Mode ~= "BoneBreak") then
		pcall(function()
			if hit.Name == "Head" and not hit:GetAttribute("NoNetworkOwnerSet") then
				hit:SetNetworkOwner(nil)
			end
			if hit:FindFirstChild("Collider") then
				hit.Collider.CanCollide = true
			end
		end)
	end

	if Values.HealthValues:FindFirstChild(hit.Name) and Values.HealthValues:FindFirstChild(hit.Name):FindFirstChild("Broken") and not Values.HealthValues[hit.Name].Destroyed.Value then
		Values.HealthValues[hit.Name].Broken.Value = true
		Values.HealthValues[hit.Name].Value = 0
	end
	--		brokenz[hit] = true	
	--		local c
	--		c = hit.AncestryChanged:Connect(function(_,parent)
	--			if not parent then
	--				brokenz[hit] = nil
	--				c:Disconnect()
	--			end
	--		end)

	if not noSound and Mode ~= "BoneBreak" then
		local _c = ServerStorage.Storage.MoreSounds.MoreGore:GetChildren()
		local gS = _c[math.random(1,#_c)]:Clone()
		--ServerStorage.Storage.PlayerSounds["Gore" .. math.random(1,3)]:Clone()
		gS.Parent = hit
		gS:Play()

		game.Debris:AddItem(gS)
	end

	if hit.Name == "Head" then
		for _,v in pairs(hitChar:FindFirstChild("Head"):GetChildren()) do
			local n = v.Name
			local sub = string.sub(n,1,6)
			if sub == "Scream" then
				v.Volume = 0
				v.PlaybackSpeed = 0
			end
		end
	elseif Mode ~= "BoneBreak" then
		_G.Scream(hitChar,hitChar["Head"],"Scream" .. math.random(1,5))
	end

	local startHP = math.huge

	--	local function BleedOutCheck(x)
	--		if (
	--			not x 
	--			and (
	--					(Values.HealthValues["Left Leg"].Broken.Value and Values.HealthValues["Right Leg"].Broken.Value)
	--					)
	--					or (Values.HealthValues["Left Leg"].Destroyed.Value and Values.HealthValues["Right Leg"].Destroyed.Value) 
	--					or (Values.HealthValues["Head"].Broken.Value) 
	--			--or (Values.HealthValues["Left Arm"].Destroyed.Value and Values.HealthValues["Right Arm"].Destroyed.Value)
	--			)
	--		and Humanoid.Health <= startHP
	--		and Humanoid.Health > 0
	--		then
	--			return true
	--		end

	--		return false
	--end


	if Humanoid.Health > 0 and not (_G.LimbCheck(hitChar,"Head","Destroyed"))
		and (
			(_G.LimbCheck(hitChar,"Right Leg","Destroyed") and _G.LimbCheck(hitChar,"Left Leg","Destroyed"))
				or
				(_G.LimbCheck(hitChar,"Head","Broken"))
		)

	then
		Humanoid.Health = 14.99
		delay(0,function()
			if Humanoid.Health > 0 then
				Humanoid.Health = 24.99
			end
		end)
	end

	--delay(0,function()
	--	if Humanoid.Health > 0 and not cantSurvive and BleedOutCheck() and Values and not Values.Currents:FindFirstChild("BLEEDINOUT") then
	--		startHP = Humanoid.Health


	--	if BleedOutCheck(true) then
	--			--Humanoid.Health = 14.99
	--			--if Values.Currents:FindFirstChild("Bleeding") then
	--			--	Values.Currents.Bleeding:Destroy()
	--			--end
	--			--wait()
	--			--for i = 1,4 do
	--			--	if Humanoid.Health <= 0 then
	--			--		break
	--			--	end
	--			--	Humanoid.Health = 24.99
	--			--	if Values.Currents:FindFirstChild("Bleeding") then
	--			--		Values.Currents.Bleeding:Destroy()
	--			--	end
	--			--	wait()
	--			--end	

	--			if Humanoid.Health <= 0 then return end

	--			local gui = game.ReplicatedStorage.Storage.GUIs.BleedOutGUI:Clone()

	--			if (Values.HealthValues["Left Leg"].Destroyed.Value and Values.HealthValues["Right Leg"].Destroyed.Value) then
	--				gui.Frame.IMG1.Visible = false
	--				gui.Frame.IMG2.Visible = true
	--				gui.Parent = hitChar.Torso
	--				gui.Adornee = hitChar.Torso
	--				gui.StudsOffset = Vector3.new(0, 0, 1.5)
	--				gui.Frame.Position = UDim2.new(0.5,0,0.485,-5)
	--			elseif hitChar:FindFirstChild("Head") then	

	--				gui.Parent = hitChar.Head
	--				gui.Adornee = hitChar.Head
	--			end

	--			if gui.Parent then
	--				--TS:Create(gui.Frame.Bar,TweenInfo.new(60,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,1,0)}):Play()
	--				gui.PlayerToHideFrom = hitPlr or nil
	--				gui.Enabled = true
	--			end

	--			startHP = Humanoid.Health
	--			if hitChar:FindFirstChild("Health") then
	--				_G.cTag(hitChar.Health,"CD")
	--				hitChar.Health.Disabled = true
	--			end

	--			local a  = hitChar.Torso["RGAB_" .. n]:Clone()
	--			a.Name = "BleedAttachment"
	--			a.Parent = hitChar.Torso

	--			local z = Instance.new("BoolValue")
	--			z.Name = "BLEEDINOUT"
	--			z.Parent = Values.Currents

	--			local zCon
	--			local zActive = true

	--			zCon = z.AncestryChanged:Connect(function(_,parent)
	--				if not parent then
	--					zCon:Disconnect()
	--					zActive = false				
	--				end
	--			end)

	--			local del = 0
	--			delay(del,function()
	--				if Humanoid.Parent then
	--					delay(61,function()
	--						if Values and Values.Parent and BleedOutCheck(true) and zActive then
	--							Humanoid:TakeDamage(math.huge)
	--						end
	--					end)
	--				_G.DamageOverTime(Humanoid,0.105,10000,0.25,true,false,true)
	--				end
	--			end)

	--			local t = tick()

	--			_G.CreateBloodTrail(
	--				a, -- attachment
	--				{
	--					{1,1}, -- blood amount
	--					15, -- Speed
	--					{-60,60}, -- Spread
	--					2, -- PoolSize
	--					1.25, -- WidthScale
	--					Vector3.new(0,3,0), -- upvector
	--					120,
	--					0.375
	--				},
	--				false,
	--				{0.2,1}
	--			)

	--			local con

	--		con = Humanoid.HealthChanged:Connect(function(h)

	--			local s = hitChar.Head:FindFirstChild("SonicDrowning")
	--				if s then
	--					s:Destroy()
	--				end
	--				s = game.ServerStorage.Storage.PlayerSounds.Head:FindFirstChild("SonicDrowning"):Clone()
	--				s.Parent = hitChar.Head

	--				local MH = Humanoid.MaxHealth
	--				MH = math.max(MH,0)

	--				local AMH = MH - 24.99
	--				local AH = Humanoid.Health

	--				local H = AH

	--				local calc = H / 25
	--				H = Lerp(0,100,calc)

	--				local Size = UDim2.new(1 - H/AMH,0,1,0)
	--				gui.Frame.Bar:TweenSize(Size,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.1)

	--				if s and BleedOutCheck(true) and h > 0 and h < 30 then
	--					if (h < 5 and h > 3) and not s.Playing and tick() - t > 30 then
	--						s:Play()
	--					elseif h > 5 and s.Playing then
	--						s:Stop()
	--					end
	--				else
	--				--	print("nah",tick() - t)
	--					if Humanoid.Health <= 0 and s and s.Playing and s.TimePosition < 12 then
	--						s:Destroy()
	--					end
	--					if gui and gui.Parent then
	--						gui:Destroy()
	--					end
	--					if z and z.Parent then
	--						z:Destroy()
	--					end
	--					if a and a.Parent then
	--						a:Destroy()
	--					end
	--					con:Disconnect()
	--					con = nil						
	--				end
	--			end)
	--		else
	--			Humanoid.Health = 1
	--		end
	--	end
	--end)
	--end))
end

_G.FlinchChar = function(hitChar,Humanoid,gTime,noAnim,isGun,noSlowDown,doCancel)
	local vf = _G.GVF(hitChar.Name)
	if not vf then return end
	local currents = vf.Currents

	if not Humanoid then
		Humanoid = hitChar:FindFirstChild("Humanoid")
	end

	gTime = gTime or 1
	
	-- High
	
	if (currents:FindFirstChild("HIGH")) then
		local high = currents.HIGH.Value
		local highTimeRemoval = ((high/100)*0.6)
		gTime -= highTimeRemoval
		if (gTime <= 0.2) then
			noAnim = true
			noSlowDown = true end
	end
	--
	if (gTime>0) then
		local fv = Instance.new("BoolValue")
		fv.Name = "Flinching"
		game.Debris:AddItem(fv,gTime)
		if isGun then
			local x = Instance.new("BoolValue")
			x.Name = "FromGun"
			x.Parent = fv
		end
		if doCancel then
			local x = Instance.new("BoolValue")
			x.Name = "DoCancel"
			x.Parent = fv
		end

		local tool = hitChar:FindFirstChildOfClass("Tool")

		if not noSlowDown or Humanoid:GetAttribute("NoFlinchSD") then
			local slowDown = _G.AffectChar(hitChar,"SP",gTime,"Flinch",0.25)
			game.Debris:AddItem(slowDown,gTime)
		else
			local b = Instance.new("BoolValue")
			b.Name = "NSD"
			b.Parent = fv
		end

		fv.Parent = currents

		local FD_DB = Instance.new("BoolValue")
		FD_DB.Name = "FD_DBB"
		FD_DB.Parent = currents
		game.Debris:AddItem(FD_DB,gTime * 1)

		local plr = game.Players:GetPlayerFromCharacter(hitChar)

		local downed = _G.DownedCheck(hitChar)
		local ragdolled = _G.RagdollCheck(hitChar)

		vf.Downed.Resisting.Value = false

		local g = false
		if plr then
			--if not downed and not ragdolled and not Humanoid.Sit and not Humanoid.PlatformStand and Humanoid.Health > 0 then
			--	--ReplicatedStorage.Events.ChangeState:FireClient(plr,Enum.HumanoidStateType.Running,3)
			--end

			if tool then
				if Humanoid.Health > 0 and not noAnim and not downed and not ragdolled and Humanoid and Humanoid.Parent and tool:FindFirstChild("CustomFlinch") and #tool["CustomFlinch"]:GetChildren() > 0 then
					g = true

					if not (tool:FindFirstChild("NoFlinch") and tool.NoFlinch.Value) then
						pcall(function()
							local t = tool["CustomFlinch"]:GetChildren()
							local a = Humanoid:LoadAnimation(t[math.random(1,#t)].Value)
							a.Priority = Enum.AnimationPriority.Movement
							a:Play(0.1)
						end)
					end
				end
				game.ServerStorage.Events3.MeleeCom:Fire(tool,"Flinch",hitChar,isGun,doCancel)
				if tool:FindFirstChild("ServerEvent") then
					tool.ServerEvent:Fire("Flinch",isGun,doCancel)
				end
			end
			ReplicatedStorage.Events.OnFlinched:FireClient(plr)
		end

		if hitChar:FindFirstChild("RiotVoice") then
			hitChar.RiotVoice.Event:Fire("Flinch")
		end

		if not noAnim and not downed and not ragdolled and not g and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Humanoid:IsDescendantOf(workspace) then
			if (tool and not (tool:FindFirstChild("NoFlinch") and tool.NoFlinch.Value)) or not tool then
				local n = "FlinchA"
				if tool and tool:FindFirstChild("NoFlinchAnim") then
					n = "FlinchB" 
				end
				n = n .. math.random(1,2)
				pcall(function()
					local a = Humanoid:LoadAnimation(script[n])
					a.Priority = Enum.AnimationPriority.Movement
					a:Play(0.1)
				end)
			end
		end
	end
	--
end

_G.CheckIfFlinching = function(hitChar,fromGun,doCancel)
	if _G.GVF(hitChar.Name) then
		local c = _G.GVF(hitChar.Name).Currents:FindFirstChild("Flinching")
		if c and not ((fromGun and c:FindFirstChild("FromGun")) or (doCancel and c:FindFirstChild("DoCancel"))) then
			return true
		end
	end
	return false
end

_G.GetPlayerData = function(plr)
	return game.ServerStorage.PlayerbaseData:FindFirstChild(plr.Name)
end

_G.SetNameTag = function(char,a,b)
	local tag = char and char.Parent and char:FindFirstChild("Head") and char.Head:FindFirstChild("NameGUI")
	if tag then

	end
end

_G.GamepassCheck = function(plr,name)
	local gamepasses = require(ReplicatedStorage.Modules.Gamepasses)
	local md = ReplicatedStorage.PlayerbaseData2:FindFirstChild(plr.Name)

	if not md  then return end

	if typeof(name) == "number" then
		for i,v in pairs(gamepasses) do
			if i == name then
				name = v[1]
				break
			end
		end		
	end


	return md.Gamepasses:FindFirstChild(name)
end

_G.ExplosionForce = function(p,ExpPosition,Distance,Radius,Force,isInCharacter,divForce,JUST_ANG)
	--Vector3 delta = (p->getCoordinateFrame().translation - position);
	Force = Force * 3000
	local FORCE_GRANULARITY = 1
	local r = 0

	local distance_factor = Distance / Radius
	distance_factor = 1 - distance_factor
	Force = math.clamp(Force * distance_factor, Force / 8.5, Force)

	local delta = p.Position - (lookAt(ExpPosition, p.CFrame.p) * CFrame.new(0,-1,5)).p
	--Vector3 normal = 
	--	(delta == Vector3::zero())
	--	? Vector3::unitY()
	--	: delta.direction();
	local normal = (delta == Vector3.new(0,0,0))
		and Vector3.new(0,1,0)
		or  delta.unit

	--float radius = p->getRadius();
	local radius = p.Size.magnitude / 2				

	--float surfaceArea = radius * radius;
	local surfaceArea = radius * radius

	--Vector3 impulse = normal * blastPressure * surfaceArea * (1.0f / 4560.0f); // normalizing factor
	local impulse = normal * Force * surfaceArea * (1.0 / 4560.0)

	-- How much force to apply (for characters, ramp it down towards the edge)
	local frac;

	if isInCharacter then
		frac = 1 - math.max(0, math.min(1, (r-2)/Radius))
	else
		frac = 1
	end				

	--p->getBody()->accumulateLinearImpulse(impulse, p->getCoordinateFrame().translation);
	local currentVelocity = p.Velocity
	local deltaVelocity = impulse / p:GetMass() -- m * del-v = F * del-t = Impulse

	local forceNeeded = 196.2 * p:GetMass() -- F = ma
	forceNeeded = forceNeeded / divForce

	--p->getBody()->accumulateRotationalImpulse(impulse * 0.5 * radius); // a somewhat arbitrary, but nice torque
	local rotImpulse = impulse * 0.5 * radius
	local currentRotVelocity = p.RotVelocity
	local momentOfInertia = (2 * p:GetMass() * radius * radius / 5) -- moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
	local deltaRotVelocity = rotImpulse / momentOfInertia 

	local torqueNeeded = 20 * momentOfInertia -- torque = r x F, want about alpha = 20 rad/s^2, alpha * P = torque

	local networkOwner = nil
	pcall(function()
		networkOwner = p:GetNetworkOwner()
	end)

	local hasPlr = not JUST_ANG and networkOwner ~= nil and (game.Players:FindFirstChild(p.Parent.Name) or game.Players:FindFirstChild(p.Parent.Parent.Name))

	local torqueNeeded = 20 * momentOfInertia -- torque = r x F, want about alpha = 20 rad/s^2, alpha * P = torque

	local ROT_MAXTORQUE = Vector3.new(torqueNeeded, torqueNeeded, torqueNeeded) * 10 * frac
	local ROT_ANGULARVELOCITY = currentRotVelocity + deltaRotVelocity
	local bodyV_MAXFORCE,bodyV_VELOCITY = Vector3.new(forceNeeded, forceNeeded, forceNeeded) * 10 * frac,currentVelocity + deltaVelocity

	local rot
	if hasPlr then
		local e = {
			["BodyAngularVelocity"] = {
				Paras = {
					MaxTorque = ROT_MAXTORQUE;
					AngularVelocity = ROT_ANGULARVELOCITY
				};
				Time = 0.2/FORCE_GRANULARITY
			};
			["BodyVelocity"] = {
				Paras = {
					MaxForce = bodyV_MAXFORCE;
					Velocity = bodyV_VELOCITY
				};
				Time = 0.2/FORCE_GRANULARITY;
			}
		}

		ReplicatedStorage.Events.CFRCE:FireClient(hasPlr,p,e)
	else
		rot = Instance.new('BodyAngularVelocity')
		_G.cTag(rot,"BM")

		rot.maxTorque = ROT_MAXTORQUE
		rot.angularvelocity = ROT_ANGULARVELOCITY

		rot.Parent = p

		game.Debris:AddItem(rot, 0.2/FORCE_GRANULARITY)	

		local bodyV = Instance.new('BodyVelocity')
		_G.cTag(bodyV,"BM")

		if not JUST_ANG then
			bodyV.maxForce = bodyV_MAXFORCE
			bodyV.velocity = bodyV_VELOCITY
			bodyV.Parent = p
			game.Debris:AddItem(bodyV, 0.2/FORCE_GRANULARITY)
		end
	end

	if JUST_ANG then
		return rot
	end
end

for i, f in pairs(require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GetGlobals"))) do
	_G[i] = f end

wait(1)
GameSettings = _G.GSAT345NIJ384TU034TRWEFGKFGS
