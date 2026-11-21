local M = {
	RegenTime = {180,300};
	HP = 100;
	
	GiveTime = {1.5,2.5};
	VelocityRndm = {5,20};
	
	Debounce = 0.25;
	
	StuckChance = 10; -- 1/NUM -- 10
	UnStuckChance = 3; -- chance of it getting unstuck after kick
	
	Colors = {
		Main = Color3.fromRGB(152,180,175);
		Error = Color3.fromRGB(180, 84, 85);
	};
	
	StuckTime = {30,40};
	
	GrenadeDrop = {
		Enabled = true;
		
		Chance = 33; -- 1/NUM -- 20
		ExplodeDelay = 1;
		OnlyOnBreak = true; -- only drop if the hit is gonna break
	};
	
	Item_DespawnTime = 60;
}

local ServerStorage =		game:GetService("ServerStorage")
local ReplicatedStorage =	game:GetService("ReplicatedStorage")
local Players =				game:GetService("Players")
local RunService = 			game:GetService("RunService")
local MarketplaceService = 	game:GetService("MarketplaceService")

local Events = ReplicatedStorage.Events
local Events2 = ReplicatedStorage.Events2
local Events3 = ServerStorage.Events3

local MoneyEvent = Events3.nMonee
local vendingRemote = Events.VendinMachine
local vendingMachineF = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("VendingMachines")

local Settings
local PlayerbaseData,PlayerbaseData2

local currentVendings = {}

function RestoreVendingMachine(machine)
	if ServerStorage.Values.RemoveVendingMachines.Value then
		return
	end
	if not machine.Values.Broken.Value then return end
	
	machine.Values.Health.Value = machine.Values.Health.MaxValue
	machine.Values.Broken.Value = false
	machine.Values.Busy.Value = false
	machine.Values.Stuck.Value = false
	
	machine.MainPart.Spark.Enabled = false
	machine.MainPart.EffectA.Smoke.Enabled = false
	
	machine.MainPart.PointLight.Color = M.Colors.Main
	
	machine.MainPart.IdleLoop:Play()
	machine.MainPart.PointLight.Enabled = true
	machine.Parts.ScreenMesh.LightSurfaceGui.Enabled = true
end

function DisableVendingMachine(machine,wasBroken)
	if machine.Values.Broken.Value then return end
	
	machine.Values.Broken.Value = true
	machine.Values.Health.Value = 0
	

	currentVendings = {}
	
	machine.MainPart.IdleLoop:Stop()
	machine.MainPart.PowerOff:Play()
	machine.MainPart.PointLight.Enabled = false
	machine.Parts.ScreenMesh.LightSurfaceGui.Enabled = false
	
	machine.MainPart.Malfunction1:Stop()
	machine.MainPart.MalfunctionLoop:Stop()
	
	if wasBroken then
		machine.MainPart.ShortCircuit:Play()
		machine.MainPart.Spark.Enabled = true
		machine.MainPart.EffectA.Smoke.Enabled = true
		
		delay(math.random(M.RegenTime[1],M.RegenTime[2]),function()
			RestoreVendingMachine(machine)
		end)
	end
end

function DamageVendingMachine(machine,damage)
	if machine.Values.Broken.Value then return end
	
	machine.Values.Health.Value = machine.Values.Health.Value - damage
	
	--if machine.Values.Health.Value <= 0 then
	--	DisableVendingMachine(machine,true)
	--end
end

function HitVendingMachine(machine,multi,customType,willBreak)
	multi = multi or 1
	
	machine.MainPart.HitS:Play()
	machine.MainPart.Spark:Emit(math.random(math.floor(4 * multi),math.floor(6 * multi)))
	machine.MainPart.EffectA.Smoke:Emit(math.random(math.floor(2 * multi),math.floor(4 * multi)))
	
	if customType == "IsKick" and machine.Values.Stuck.Value then
		
		if M.GrenadeDrop.Enabled then
			local doDrop = math.random(1,M.GrenadeDrop.Chance) == 1
			if doDrop and not (M.GrenadeDrop.OnlyOnBreak and not (machine.Values.Broken.Value or machine.Values.Health.Value <=0)) then
				local s = machine.MainPart.GlitchSound:Clone()
				s.Parent = machine.MainPart
				s:Play()
				game.Debris:AddItem(s,1.2)
				spawn(function()
					SpitGrenade(machine)
				end)
				return
			end
		end
		
		local unstuck = math.random(1,M.UnStuckChance) == 1 
		if unstuck then
			--print("ye unstuck")
			machine.Values.Stuck.Value = false
		end
	end
end

function SpitGrenade(machine)
	local nade = ServerStorage.Tools["Grenade"].Handle:Clone()
	--tool:SetAttribute("StoreBought",true)
	
	local machineP = machine.MainPart

	local spawnPos = CFrame.new(machineP.ExitPosA.WorldPosition)
	spawnPos += machineP.ExitPosA.CFrame.RightVector * (math.random(-10,10) / 10)

	machineP.ExitPosA.CanOut:Play()

	local velAdd = math.random(M.VelocityRndm[1],M.VelocityRndm[2])
	
	nade.HB.Massless = false
	
	local function dot(v)
		v.Velocity = (machineP.ExitPosA.CFrame.RightVector * velAdd)
		v.CFrame = spawnPos
	end
	
	dot(nade)
	for i,v in pairs(nade:GetChildren()) do
		if v:IsA("BasePart") then
			dot(v)
		end
	end
	
	nade.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId(_G.CG_NCC)
	nade.HB.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId(_G.CG_NCC)
	nade.PinPullSound:Play()
	
	spawn(function()
		local Pin = nade.Pin
		Pin.Weld:Destroy()
		Pin.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId(_G.CG_NCC)
		Pin.CanCollide = true
		Pin.Massless = false

		pcall(function()
			Pin:SetNetworkOwner(nil)	
		end)
		game.Debris:AddItem(nade.Pin,5)
		Pin.Parent = workspace.Debris
		task.wait(0)

		local vel = (Pin.Velocity * 0.4)
		vel += (spawnPos.RightVector * math.random(-6,6))
		Pin.Velocity = vel

		task.wait(0.4)
		nade.PinPullSound:Stop()
	end)
	
	nade.Trail.Enabled = true
	nade.X.EM.ZOffset = 8
	
	nade.Parent = workspace.Debris.VParts
	nade:SetNetworkOwner(nil)
	nade.HB.CanCollide = true

	local Slide = nade.Slide
	game.Debris:AddItem(Slide,5)
	Slide.Weld:Destroy()
	Slide.CollisionGroupId = game:GetService("PhysicsService"):GetCollisionGroupId(_G.CG_NCC)
	Slide.CanCollide = true
	Slide.Massless = false
	Slide:SetNetworkOwner(nil)	

	local x = Instance.new("BodyForce")
	x.Force = Vector3.new(0,(workspace.Gravity * Slide:GetMass()) * 0.45,0)
	x.Parent = Slide

	Slide.Parent = workspace.Debris
	Slide.Velocity = ((nade.Velocity * 0.4) + (spawnPos.RightVector * math.random(-6,6)))
	
	local hitDB = false
	local dTouched = false
	local exploded = false
	local touchPart = nade.HB

	local hitSounded = false
	
	local t = tick()
	local spinning = false
	local dTouched = false

	local function spin()
		if spinning then return end
		spinning = true
		local t = tick()
		coroutine.wrap(function()
			while nade.Parent and not nade.Anchored and not exploded and tick() - t < 5 do wait()
				local n = 0.4
				if dTouched then
					--n = 0.1
				end
				nade.RotVelocity = Vector3.new(nade.RotVelocity.X * n,nade.RotVelocity.Y * n,nade.RotVelocity.Z * n)
			end
		end)()
	end
	

	touchPart.Touched:Connect(function(Hit)
		
		if Hit.CanCollide and not Hit:IsDescendantOf(nade) then
			spin()
		end

		if not exploded and not hitDB 
			and (nade.Velocity.Magnitude > 0.5 or not hitSounded)
			and (Hit == workspace.Terrain or (Hit.CanCollide
				and not Hit:IsDescendantOf(workspace.Characters)
				))
		then
			hitDB = true
			hitSounded = true
			dTouched = true
			local s = nade["Bounce" .. math.random(1,4)]
			--s.Pitch = 1.35 * math.random(80,120) / 100
			s:Play()
			wait(0.1)
			hitDB = false
		end
	end)
	

	nade.X.EM.Enabled = true
	nade.X.Light.Enabled = true
	
	task.elay(M.GrenadeDrop.ExplodeDelay,function()
		nade.X.EM.Color = ColorSequence.new(Color3.fromRGB(255,35,0))
		nade.X.Light.Color = Color3.new(1,0,0)
		nade.X.Light.Brightness = 25
		nade.X.Light.Range = 3
		
		task.wait(0.25)
		
		nade.Anchored = true
		
		_G.ZaWarudoWait()

		nade.Transparency = 1
		if nade:FindFirstChild("Base") then
			nade.Base.Transparency = 1
		end
		
		nade.CanCollide = false
		game.Debris:AddItem(nade,1)
		local expPart = game.ServerStorage.Projectiles.GrenadeExplosion:Clone()
		
		expPart:SetAttribute("CustomData_Killer","[REDACTED]")
		expPart:SetAttribute("CustomData_Weapon","Grenade")
		expPart:SetAttribute("HasCustomData",true)
		
		expPart.CFrame = CFrame.new(nade.Position + Vector3.new(0,1.25,0))
		expPart.Creator.Value = nil

		local toolNameV = expPart.Creator:FindFirstChild("Tool")
		if not toolNameV then
			toolNameV= Instance.new("StringValue")
			toolNameV.Name = "Tool"
			toolNameV.Parent = expPart.Creator
		end
		toolNameV.Value = "Grenade"

		expPart.Parent = workspace.Debris
		
		if Slide and Slide.Parent then
			Slide:Destroy()
		end

		expPart.Main.Disabled = false
		task.wait()
		nade.Trail.Enabled = false

		nade.X:Destroy()
		for _,v in pairs(nade:GetChildren()) do
			if not v:IsA("Attachment") and not v:IsA("Trail") then
				game.Debris:AddItem(v,1)
			end
		end
	end)
end

function VendingMachineRemoteFunc(plr,machineP,mode)
	if currentVendings[plr] then return end
	
	if mode ~= "soda" and mode ~= "snack" then return end
	if ReplicatedStorage.Values.ShuttingDown.Value then return end
	if _G.CheckIfCan and not _G.CheckIfCan(plr.Character,"Any") then return false,"YOU ARE TOO INJURED TO DO THIS RIGHT NOW" end
	if not (machineP and machineP.Parent and machineP:IsA("BasePart") and machineP.Name == "MainPart" and machineP:IsDescendantOf(vendingMachineF)) then return end
	local mag = (machineP.Position - plr.Character.HumanoidRootPart.Position).Magnitude
	if mag >= 10 then return end

	local machine = machineP.Parent

	if machine.Values.Busy.Value then return end
	if machine.Values.Broken.Value then return end
	if machine.Values.Stuck.Value then return end
	
	local pd = PlayerbaseData[plr.Name]
	local cv = pd.Cash
	local bv = pd.Bank
	
	local COST = 399
	
	if cv.Value < COST then
		return false,"NOT ENOUGH CASH (".. _G.MakeFakeDisplayForCash(COST).. ")"
	end
	
	currentVendings[plr] = true
	machine.Values.Busy.Value = true
	
	machineP.DollarIn:Play()
	
	MoneyEvent:Fire("IU3898EJKLOY89TYZJDKLJGYI390WKHJSDHG9UKLJLEDGKLJERG9U",plr,"Cash",-COST)
	
	local function DropItem()
		local chosenItem = "Rage-potion"
		
		local gy = false
		
		if mode == "soda" then
			chosenItem = "Cola_" .. math.random(1,2)
			gy = true
		elseif mode == "snack" then
			if math.random(1,2) == 1 then
				chosenItem = "ChocBar_" .. math.random(1,2)
			else
				chosenItem = "Chips_" .. math.random(1,2)
			end
			
			--chosenItem = "Antidote"
		end
		
		local c = math.random(1,100)
		if c <= 1 then
			chosenItem = "C4"
		elseif c <= 5 then
			chosenItem = math.random(1,2) == 1 and "Rage-potion" or "Antidote"
		end
		
		local tool = ServerStorage.Tools[chosenItem]:Clone()
		tool:SetAttribute("CZSTM_DoSave",true)
		--tool:SetAttribute("StoreBought",true)

		local spawnPos = CFrame.new(machineP.ExitPosA.WorldPosition,machineP.ExitPosA.WorldCFrame.LookVector * 1000) * CFrame.Angles(0,math.rad(-45),math.rad(90))
		spawnPos += machineP.ExitPosA.CFrame.RightVector * (math.random(-10,10) / 10)
		
		local spawnedTool = Events3.CreateSpawnedTool:Invoke("ER09ESFAODS0FAS4T90I3",tool,spawnPos,M.Item_DespawnTime)

		machineP.ExitPosA.CanOut:Play()

		local velAdd = math.random(M.VelocityRndm[1],M.VelocityRndm[2])

		spawnedTool.PrimaryPart.Velocity = spawnedTool.PrimaryPart.Velocity + (machineP.ExitPosA.CFrame.LookVector * velAdd)
		
		if gy then
			script.BodyGyro:Clone().Parent = spawnedTool.PrimaryPart
		end
	end
	
	local doStuck = math.random(1,M.StuckChance) == 1
	
	task.delay(0,function()
		if doStuck then
			task.wait(math.random(25,55) / 10)
			
			if not machine.Values.Broken.Value and not machine.Values.Stuck.Value then
				machineP.Malfunction1:Play()
				machineP.Spark:Emit(5)
				task.delay(1,function()
					if not machine.Values.Broken.Value and machine.Values.Stuck.Value then
						machineP.MalfunctionLoop:Play()
					end
				end)
				
				machineP.PointLight.Color = M.Colors.Error
				
				machine.Values.Stuck.Value = true
				
				local t = tick()
				local setStuckTime = math.random(M.StuckTime[1] * 10,M.StuckTime[2] * 10) / 10
				
				repeat task.wait(0.5)
				until tick() - t > setStuckTime or machine.Values.Broken.Value or not machine.Values.Stuck.Value
				
				machine.Values.Stuck.Value = false
				
				machineP.Malfunction1:Stop()
				machineP.MalfunctionLoop:Stop()
			end
		else
			task.wait(math.random(M.GiveTime[1] * 10,M.GiveTime[2] * 10) / 10)
		end
		
		if not machine.Values.Broken.Value then
			machineP.PointLight.Color = M.Colors.Main
			
			DropItem()

			task.wait(1)

			currentVendings[plr] = nil

			task.wait(M.Debounce)

			machine.Values.Busy.Value = false
		end
	end)
	
	return true
end

M.SetUp = function(settinz)
	Settings = settinz
	
	spawn(function()
		PlayerbaseData,PlayerbaseData2 = ServerStorage:WaitForChild("PlayerbaseData",100),ReplicatedStorage:WaitForChild("PlayerbaseData2",100)
	end)
	
	if vendingMachineF then
		vendingRemote.OnServerInvoke = VendingMachineRemoteFunc

		for _,machine in pairs(vendingMachineF:GetChildren()) do
			local val = Instance.new("Folder")
			val.Name = "Values"
			
			local events = Instance.new("Folder")
			events.Name = "Events"
			
			local hitEvent = Instance.new("BindableEvent")
			hitEvent.Name = "Damage"
			hitEvent.Parent = events
			
			local busy = Instance.new("BoolValue")
			busy.Name = "Busy"
			busy.Parent = val
			
			local broken = Instance.new("BoolValue")
			broken.Name = "Broken"
			broken.Parent = val
			
			local stuck = Instance.new("BoolValue")
			stuck.Name = "Stuck"
			stuck.Parent = val
			
			local hp = Instance.new("DoubleConstrainedValue")
			hp.Name = "Health"
			hp.MaxValue = M.HP
			hp.MinValue = 0
			hp.Value = hp.MaxValue
			hp.Parent = val
			
			val.Parent = machine
			events.Parent = machine
			
			hp.Changed:Connect(function()
				RunService.Heartbeat:Wait()
				if hp.Value <= 0 and not broken.Value then
					DisableVendingMachine(machine,true)
				end
			end)
			
			hitEvent.Event:Connect(function(damage,plr,customType)
				local willBreak = hp.Value > 0 and hp.Value - damage <= 0
				hp.Value -= damage
				
				HitVendingMachine(machine,damage > 50 and 2 or 1,customType,willBreak)
			end)
			
			hp.Parent = val
			
			local user = Instance.new("ObjectValue",val)
			user.Name = "User"

			--local screen = atm.Parts:FindFirstChild("Screen")
			--if screen then
			--	screen:GetPropertyChangedSignal("Color"):Connect(function()
			--		local color = screen.Color

			--		if screen:FindFirstChild("PointLight") then
			--			screen.PointLight.Color = color
			--			screen.PointLight.Shadows = false
			--			screen.PointLight.Range = 12

			--			if color == ATM_Settings.Color0 then
			--				screen.PointLight.Brightness = 2
			--			elseif color == ATM_Settings.ColorPend then
			--				screen.PointLight.Brightness = 2.5
			--			elseif color == ATM_Settings.ColorComplete or color == ATM_Settings.ColorError then
			--				screen.PointLight.Brightness = 3.5
			--			end
			--		end
			--	end)
			--end
		end
		
		local ogMachines = {}
		for _,machine in pairs(vendingMachineF:GetChildren()) do
			table.insert(ogMachines,machine)
		end
		
		vendingMachineF.ChildAdded:Connect(function(machine)
			task.wait()
			local val = Instance.new("Folder")
			val.Name = "Values"

			local events = Instance.new("Folder")
			events.Name = "Events"

			local hitEvent = Instance.new("BindableEvent")
			hitEvent.Name = "Damage"
			hitEvent.Parent = events

			local busy = Instance.new("BoolValue")
			busy.Name = "Busy"
			busy.Parent = val

			local broken = Instance.new("BoolValue")
			broken.Name = "Broken"
			broken.Parent = val

			local stuck = Instance.new("BoolValue")
			stuck.Name = "Stuck"
			stuck.Parent = val

			local hp = Instance.new("DoubleConstrainedValue")
			hp.Name = "Health"
			hp.MaxValue = M.HP
			hp.MinValue = 0
			hp.Value = hp.MaxValue
			hp.Parent = val

			val.Parent = machine
			events.Parent = machine

			hp.Changed:Connect(function()
				RunService.Heartbeat:Wait()
				if hp.Value <= 0 and not broken.Value then
					DisableVendingMachine(machine,true)
				end
			end)

			hitEvent.Event:Connect(function(damage,plr,customType)
				local willBreak = hp.Value > 0 and hp.Value - damage <= 0
				hp.Value -= damage

				HitVendingMachine(machine,damage > 50 and 2 or 1,customType,willBreak)
			end)

			hp.Parent = val

			local user = Instance.new("ObjectValue",val)
			user.Name = "User"

			--local screen = atm.Parts:FindFirstChild("Screen")
			--if screen then
			--	screen:GetPropertyChangedSignal("Color"):Connect(function()
			--		local color = screen.Color

			--		if screen:FindFirstChild("PointLight") then
			--			screen.PointLight.Color = color
			--			screen.PointLight.Shadows = false
			--			screen.PointLight.Range = 12

			--			if color == ATM_Settings.Color0 then
			--				screen.PointLight.Brightness = 2
			--			elseif color == ATM_Settings.ColorPend then
			--				screen.PointLight.Brightness = 2.5
			--			elseif color == ATM_Settings.ColorComplete or color == ATM_Settings.ColorError then
			--				screen.PointLight.Brightness = 3.5
			--			end
			--		end
			--	end)
			--end
			table.insert(ogMachines,machine)
		end)
		
		local currentDisableState = false
		local function UpdateDisabled()
			if currentDisableState == ServerStorage.Values.RemoveVendingMachines.Value then
				return
			end
			
			currentDisableState = ServerStorage.Values.RemoveVendingMachines.Value
			
			if currentDisableState then
				for i,v in pairs(ogMachines) do
					DisableVendingMachine(v,false)
					v.Parent = nil
				end
			else
				for i,v in pairs(ogMachines) do
					v.Parent = vendingMachineF
					RestoreVendingMachine(v)
				end
			end
		end
		if ServerStorage.Values.RemoveVendingMachines.Value then
			UpdateDisabled()
		end
		ServerStorage.Values.RemoveVendingMachines.Changed:Connect(UpdateDisabled)

		ServerStorage.Events3.RegenVendingMachines.Event:Connect(function()
			for i,v in pairs(vendingMachineF:GetChildren()) do
				RestoreVendingMachine(v)
			end
		end)
	
	end
end

return M