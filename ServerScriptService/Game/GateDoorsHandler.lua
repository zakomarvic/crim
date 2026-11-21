local _ = {}

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local GateDoors = workspace:WaitForChild("Map",1000).GateDoors

local assetStorage = game.ServerStorage.Storage.GateDoorStuff

for i,v in pairs(GateDoors:GetChildren()) do
	v.Name = v.Name .. "_" .. i
	
	assetStorage.Events:Clone().Parent = v
	assetStorage.Values:Clone().Parent = v
	
	local newScript = script.GateDoorMain:Clone()
	newScript.Parent = v
	newScript.Enabled = true
end

return _