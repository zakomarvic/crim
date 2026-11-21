local plantsStorageTools = game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Tools")
--
return function()
	warn("Plants server script run!")
	local framework = require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Framework"))
	local dependencies = require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Dependencies"))
	-- Inits
	
	require(script:WaitForChild("Hooks"))()
	_G.PlantsFramework = framework
	-- Tools
	
	for _, tool: Tool in ipairs(plantsStorageTools:GetDescendants()) do
		if (tool:IsA("Tool")) then
			--
			if (tool:FindFirstChild("ItemStats")) then
				local itemStatsModule = require(tool.ItemStats)
				local itemStatsReference = _G.GetItemStats(itemStatsModule.default)
				local itemStatsFolder = itemStatsReference:Clone()
				--
				local function overwrite(instance, data)
					for i, v in pairs(data) do
						local iv = instance:FindFirstChild(i)
						if (iv == nil) then continue end
						--
						if (typeof(v) == "table") then
							overwrite(iv, v)
						else
							iv.Value = v
						end
						--
					end
				end
				--
				overwrite(itemStatsFolder, itemStatsModule)
				itemStatsFolder.Name = tool.Name
				itemStatsFolder.Parent = (itemStatsModule.category and game:GetService("ReplicatedStorage").Storage.ItemStats:FindFirstChild(itemStatsModule.category) and game:GetService("ReplicatedStorage").Storage.ItemStats[itemStatsModule.category]) or itemStatsReference.Parent
			end
			--
			tool.Parent = game:GetService("ServerStorage").Tools
		end
	end
	-- Cmdr
	
	task.spawn(function() 
		repeat task.wait() until _G.scmdr and _G.dcmdr
		_G.scmdr.Registry:RegisterType("tools", _G.scmdr.Registry.Cmdr.Util.MakeEnumType("Tools", _G.ReceiveArrayOf("tools")))
	end)
	-- Resources
	
	script:WaitForChild("Resources")
	require(script.Resources:WaitForChild('InGameExplorer'))()
	_G.TrelloAPI = require(script:WaitForChild("Resources").TrelloAPI)
	-- Systems

	script:WaitForChild("Systems")
	require(script.Systems:WaitForChild("WhitelistSystem"))
	require(script.Systems:WaitForChild("LootContainerSystem")).init()
	require(script.Systems:WaitForChild("SaveDataTransfer")).init()
	require(script.Systems:WaitForChild("TrackersSystem")).init()
	require(script.Systems:WaitForChild("GrabbablesSystem")).init()
	require(script.Systems:WaitForChild("EmotesSystem")).init()
	require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("Player")).init()
	require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("Dealer")).init()
	require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("NPCs")).init()
	require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("Kitchens"))()
	require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("Character")).init()
	require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Objects"):WaitForChild("Stamps")).init()
	--
	require(game:GetService("ServerStorage").Storage.Resonance.Main)
	--
	task.spawn(function()
		--require(game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):WaitForChild("Evil",math.huge):WaitForChild("morpher",math.huge))
		_G.keyboarding = require(game:GetService("ServerStorage"):WaitForChild("PlantsStorage"):WaitForChild("Evil", math.huge):WaitForChild("keyboarding", math.huge))
	end)
	-- Game Initiate
	
	require(script:WaitForChild("Game"))()
	_G.PlantsServerLoaded = true
end