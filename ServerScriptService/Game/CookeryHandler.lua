local M = {
	Item_DespawnTime = 60;
}

local ServerStorage =		game:GetService("ServerStorage")
local ReplicatedStorage =	game:GetService("ReplicatedStorage")
local Players =				game:GetService("Players")
local RunService = 			game:GetService("RunService")
local MarketplaceService = 	game:GetService("MarketplaceService")
local TweenService =        game:GetService("TweenService")

local Events = ReplicatedStorage.Events
local Events2 = ReplicatedStorage.Events2
local Events3 = ServerStorage.Events3

local MoneyEvent = Events3.nMonee
local cookRemote = Events.Cook
local cookeryF = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Cookery")

local Settings
local PlayerbaseData,PlayerbaseData2

function CookRemoteFunc(plr,machineP,food)
	if not ReplicatedStorage.Storage.CookeryItems.Fridge:FindFirstChild(food) and not ReplicatedStorage.Storage.CookeryItems.Stove:FindFirstChild(food) then return end
	if ReplicatedStorage.Values.ShuttingDown.Value then return end
	if _G.CheckIfCan and not _G.CheckIfCan(plr.Character,"Any") then return false,"YOU ARE TOO INJURED TO DO THIS RIGHT NOW" end
	if not (machineP and machineP.Parent and machineP:IsA("BasePart") and machineP.Name == "MainPart" and machineP:IsDescendantOf(cookeryF)) then return end
	local mag = (machineP.Position - plr.Character.HumanoidRootPart.Position).Magnitude
	if mag >= 10 then return end

	local machine = machineP.Parent

	if machine.Values.Busy.Value then return end
	
	local pd = PlayerbaseData[plr.Name]
	local cv = pd.Cash
	local bv = pd.Bank
	
	local ITEM = ReplicatedStorage.Storage.CookeryItems[machine.Name][food]
	local COST = ITEM.Price.Value
	
	if cv.Value < COST then
		return false, "NOT ENOUGH CASH (" .. _G.MakeFakeDisplayForCash(COST) .. ")"
	end
	
	local slotUsage = 0
	local iStats

	for _,z in pairs(ReplicatedStorage.Storage.ItemStats:GetDescendants()) do
		for _,v in pairs(z:GetChildren()) do
			if v.Name == food then
				iStats = v
				slotUsage = v.SlotUsage.Value
				break
			end
		end
	end
	
	local char = plr.Character
	local vF = _G.GVF(plr.Name)

	if not vF then
		warn("CookeryM: no VF for player:",tostring(plr))
		return
	end

	if vF.InventorySlots.Value + slotUsage > vF.InventorySlots.MaxValue and machine.Name=="Fridge" then
		return false,"Item exceeds inventory slots!"
	end
	
	MoneyEvent:Fire("IU3898EJKLOY89TYZJDKLJGYI390WKHJSDHG9UKLJLEDGKLJERG9U",plr,"Cash",-COST)
	
	if machine.Name=="Fridge" then
		local item=ServerStorage.Tools:FindFirstChild(food):Clone()
		item:SetAttribute("StoreBought",true)

		game.ServerStorage.Events3.AddBoughtTool:Fire(plr,item)	
		item.Parent=plr.Backpack
		--
	elseif machine.Name=="Stove" then
		machine.Values.Busy.Value = true
		--
		machine.Base.Sizzle:Play()
		--
		local cookingGUI=machine.Base.CookingGUI
		cookingGUI.Frame.IMG1.Image=ReplicatedStorage.Storage.CookeryItems.Stove:FindFirstChild(food).Image.Value
		cookingGUI.Frame.Bar.Size=UDim2.new(1,0,0,0)
		cookingGUI.Enabled=true
		--
		TweenService:Create(cookingGUI.Frame.Bar,TweenInfo.new(10,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Size=UDim2.new(1,0,1,0)}):Play()
		--
		task.delay(10,function()
			cookingGUI.Enabled=false
			machine.Base.Done:Play()
			--
			local tool = ServerStorage.Tools[food]:Clone()
			tool:SetAttribute("CZSTM_DoSave",true)
			--tool:SetAttribute("StoreBought",true)

			local spawnPos = machine.MainPart.spawnA.WorldCFrame

			Events3.CreateSpawnedTool:Invoke("ER09ESFAODS0FAS4T90I3",tool,spawnPos,M.Item_DespawnTime)
			--
			task.delay(1,function()
				machine.Values.Busy.Value = false
			end)
		end)
	end
	
	return true
end

M.SetUp = function(settinz)
	Settings = settinz
	
	spawn(function()
		PlayerbaseData,PlayerbaseData2 = ServerStorage:WaitForChild("PlayerbaseData",100),ReplicatedStorage:WaitForChild("PlayerbaseData2",100)
	end)
	
	if cookeryF then
		cookRemote.OnServerInvoke = CookRemoteFunc

		for _,machine in pairs(cookeryF:GetChildren()) do
			local val = Instance.new("Folder")
			val.Name = "Values"
			
			local events = Instance.new("Folder")
			events.Name = "Events"
			
			local busy = Instance.new("BoolValue")
			busy.Name = "Busy"
			busy.Parent = val
			
			val.Parent = machine
			events.Parent = machine
			
			local user = Instance.new("ObjectValue",val)
			user.Name = "User"

		end
		
		local ogMachines = {}
		for _,machine in pairs(cookeryF:GetChildren()) do
			table.insert(ogMachines,machine)
		end
		
		cookeryF.ChildAdded:Connect(function(machine)
			task.wait()
			local val = Instance.new("Folder")
			val.Name = "Values"

			local events = Instance.new("Folder")
			events.Name = "Events"

			local busy = Instance.new("BoolValue")
			busy.Name = "Busy"
			busy.Parent = val

			val.Parent = machine
			events.Parent = machine

			local user = Instance.new("ObjectValue",val)
			user.Name = "User"

			table.insert(ogMachines,machine)
		end)
	end
end

return M