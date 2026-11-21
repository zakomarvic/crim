local _ = {}

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Doors = workspace:WaitForChild("Map",1000).Doors

local storage = Instance.new("Folder",game.Debris)
storage.Name = "DoorsStorage"

local DOOR_RESPAWN_TIME = 360
local DOOR_RESET_TIME = 2700

local assetStorage = game.ServerStorage.Storage.DoorStuff

function RegenDoor(v)
	if Doors:FindFirstChild(v.Name) then
		Doors[v.Name]:Destroy()
	end
	local nDoor = storage:FindFirstChild(v.Name):Clone()
	v:Destroy()
	nDoor.Parent = Doors
	MonitorDoor(nDoor)
end

function MonitorDoor(v)
	coroutine.wrap(function()
		local z = false

		if v:FindFirstChild("DoorMain") then
			v.DoorMain.Disabled = false
			z = true
		elseif v:FindFirstChild("GarageDoorMain") then
			v.GarageDoorMain.Disabled = false
		elseif v:FindFirstChild("Legacy1_Elevator1") then
			v.Legacy1_Elevator1Main.Disabled = false
			z = true
		elseif v:FindFirstChild("Legacy2_Elevator1") then
			v.Legacy2_Elevator1Main.Disabled = false
		elseif v:FindFirstChild("Elevator1Main") then
			z = true
			v.Elevator1Main.Disabled = false
		end
		
		if z then
			assetStorage.Events:Clone().Parent = v
			assetStorage.Values:Clone().Parent = v
		end
		
		local c
		
		local can = true
		
		c = v.Values.Broken.Changed:Connect(function(x)
			if not x then return end
			c:Disconnect()

			local ct = v.Values:FindFirstChild("RegenTime") and v.Values.RegenTime.Value
		
			if ct then
				wait(ct * 60)
			else
				wait(DOOR_RESPAWN_TIME)
			end

			if v and v.Parent and can then
				if not ServerStorage.Values.NoDoorsAutoRegen.Value then
					can = false
					RegenDoor(v)	
				end
			end
		end)
		
		delay(DOOR_RESET_TIME,function()
			if v and v.Parent and can then
				if not ServerStorage.Values.NoDoorsAutoRegen.Value then
					can = false
					RegenDoor(v)
					c:Disconnect()
				end
			end
		end)
	end)()
end

for i,v in pairs(Doors:GetDescendants()) do
	if v:IsA("BasePart") then
		CollectionService:AddTag(v,"FromDoorsFolder")
	end
end

for i,v in pairs(Doors:GetChildren()) do
	v.Name = v.Name .. "_" .. i
	if v:FindFirstChild("IsGarageDoor") then
		script.GarageDoorMain:Clone().Parent = v
	elseif v:FindFirstChild("Legacy1_Elevator1") then
		script.Legacy1_Elevator1Main:Clone().Parent = v
	elseif v:FindFirstChild("Legacy2_Elevator1") then
		script.Legacy2_Elevator1Main:Clone().Parent = v
	elseif v:FindFirstChild("IsElevator1") then
		script.Elevator1Main:Clone().Parent = v
	else
		script.DoorMain:Clone().Parent = v
	end
	v:Clone().Parent = storage
	MonitorDoor(v)
end

ServerStorage.Events3.RegenAllDoors.Event:Connect(function()
	for i,v in pairs(Doors:GetChildren()) do
		RegenDoor(v)
	end
end)

return _