local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")

local M = {}
M.__index = M

M.Settings = {
	PlaneSettings = {
		Velocity = 100;
		
		DropCount = 2;
		
		ExplodeDelay = {7,20}; -- when a missile comes
		SpinOutDelay = {3,10}; -- when a missile inbound 
		
		A10_Enabled = true;
		A10_Delay = {5.5,7}; -- delay for a10 to come after a missile is spawned
		A10_AddHeight = -3000;
	};
	
	CrateSettings = {
		Velocity = -20
	};
}

local dropLocationsF = script.DropLocations

M.GetRandomInPart = function(part)
	local random = Random.new()
	local randomCFrame = part.CFrame * CFrame.new(random:NextNumber(-part.Size.X/2.2,part.Size.X/2.2), random:NextNumber(-part.Size.Y/2.2,part.Size.Y/2.2), random:NextNumber(-part.Size.Z/2.2,part.Size.Z/2.2))
	return randomCFrame
end

M.MissileStrike = function(...)
	if not M.isSetUp then return end
	
	return M.MissileStrikeM.new(...)
end

M.SupplyPlane = function(...)
	if not M.isSetUp then return end
	
	return M.SupplyPlaneM.new(...)
end

M.SupplyCrate = function(...)
	if not M.isSetUp then return end
	
	return M.SupplyCrateM.new(...)
end

M.SupplyDropMain = function(doExplode)
	if not M.isSetUp then return end
	
	print("New supply drop",doExplode)

	local explodeDelay = doExplode and math.random(M.Settings.PlaneSettings.ExplodeDelay[1] * 10,M.Settings.PlaneSettings.ExplodeDelay[2] * 10) / 10

	local plane,dropData,funcs = M.SupplyPlane(M.Settings.PlaneSettings.DropCount)

	if doExplode then
		delay(explodeDelay,function()
			if plane and plane.Parent and not plane:GetAttribute("Destroyed") and plane.Active.Value then

				local missile_SpawnPart = dropData.Missile_SpawnPart

				if missile_SpawnPart then
					local currentPlaneCF = plane.PrimaryPart.CFrame

					local spawnCF = M.GetRandomInPart(missile_SpawnPart)

					spawnCF *= CFrame.Angles(0,math.rad(math.random(0,360)),0)

					print("missile inbound",explodeDelay)

					delay(math.random(M.Settings.PlaneSettings.SpinOutDelay[1] * 10,M.Settings.PlaneSettings.SpinOutDelay[2] * 10) / 10,function()
						funcs.SpinOut()
					end)

					local missile = M.MissileStrike(spawnCF,plane)
					
					if M.Settings.PlaneSettings.A10_Enabled then
						delay(math.random(M.Settings.PlaneSettings.A10_Delay[1] * 10,M.Settings.PlaneSettings.A10_Delay[2] * 10) / 10,function()
							local p = missile_SpawnPart:Clone()
							p.Size /= 3
							local spawnCF = M.GetRandomInPart(p)
							p:Destroy()

							local location = currentPlaneCF.Position + Vector3.new(0,M.Settings.PlaneSettings.A10_AddHeight,0)
							local orientation = CFrame.new(missile_SpawnPart.CFrame.p,currentPlaneCF.p):ToOrientation()

							ServerStorage.Events3.NASTRIKE2:Fire(nil,location,orientation,0,1,true)
						end)
					end
			
				else
					warn("No Missile_SpawnPart found for",dropData.MapType)
				end
			end
		end)
	end
end

M.SetUp = function(gameSettings)
	if M.isSetUp then return end
	M.isSetUp = true
	
	M.SupplyPlaneM = require(script.SupplyPlane)
	M.SupplyCrateM = require(script.SupplyCrate)
	M.MissileStrikeM = require(script.MissileHandler)
	
	M.DropLocationData = {}
	
	for _,v in pairs(dropLocationsF:GetChildren()) do -- all the maps
		M.DropLocationData[v.Name] = {}
		for i2,v2 in pairs(v:GetChildren()) do -- all the drops
			local t = {}
			t.SpawnPart = v2.SpawnPart
			t.AngleInPart = v2:FindFirstChild("AngleInPart")
			
			t.Missile_SpawnPart = v2:FindFirstChild("Missile_SpawnPart")
			
			t.MapType = v.Name
			
			t.DropConfig = v2:FindFirstChild("DropConfig") and require(v2.DropConfig)
			
			t.DropGroups = {}
			
			for i3,v3 in pairs(v2.DropPointGroups:GetChildren()) do
				t.DropGroups[tonumber(v3.Name) or i3] = v3
			end
			
			M.DropLocationData[v.Name][i2] = t
		end
	end
	
	ServerStorage.Events3.SupplyDrop.Event:Connect(function(...)
		M.SupplyDropMain(...)
	end)
	
	spawn(function()
		
	end)
end


return M