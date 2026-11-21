local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local m = {}

--local function DoCollectionServiceTing()
--	local map = workspace:FindFirstChild("Map")
--	local filter = workspace:FindFirstChild("Filter")

--	for _,v in pairs(map:GetChildren()) do

--		for _,z in pairs(v:GetDescendants()) do
--			if z:IsA("BasePart") then
--				CollectionService:AddTag(z,"FromMapFolder")
--			end

--			if v == map.Parts then
--				CollectionService:AddTag(z,"FromMapPartsFolder")
--			elseif v == map.Shopz then
--				CollectionService:AddTag(z,"FromMapShopzFolder")
--			end
--		end
--	end

--	local function monitorCharactersFolder(character)
--		--local c1
--		--local c2

--		--local function disconnect()

--		--end

--		local function DescAdded(d)
--			if d:IsA("BasePart") then
--				CollectionService:AddTag(d,"IsCharFolderPart")

--				if d.Parent == character and (d.Name == "Head" or d.Name == "Torso" or d.Name == "Left Arm" or d.Name == "Right Arm" or d.Name == "Left Leg" or d.Name == "Right Leg" or d.Name == "HumanoidRootPart") then
--					CollectionService:AddTag(d,"IsMainCharPart")

--					if d.Name == "HumanoidRootPart" then
--						CollectionService:AddTag(d,"IsMainCharPart2")
--					end
--				end
--			end
--		end

--		for _,v in pairs(character:GetDescendants()) do
--			DescAdded(v)
--		end

--		character.DescendantAdded:Connect(DescAdded)
--	end

--	workspace.Characters.ChildAdded:Connect(monitorCharactersFolder)
--end

m.SetUp = function()
	--DoCollectionServiceTing()
	
	local RayHandler = require(ReplicatedStorage:WaitForChild("Modules").RayHandler)
	
	wait(1)
	
	RayHandler.SetUp()
end

return m