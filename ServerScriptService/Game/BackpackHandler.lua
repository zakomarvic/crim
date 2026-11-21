local M = {}

local ServerStorage =			game:GetService("ServerStorage")
local ReplicatedStorage =		game:GetService("ReplicatedStorage")
local Players =					game:GetService("Players")
local PhysicsService = 			game:GetService("PhysicsService")

local Events = ReplicatedStorage:WaitForChild("Events")
local Events2=  ReplicatedStorage:WaitForChild("Events2")
local Events3 =  ServerStorage:WaitForChild("Events3")

local initializeEvent =		Events2:WaitForChild("DropInitializer")
local passEvent =			Events:WaitForChild("PAZ_TA")

local tools = {}

local pd = ServerStorage:WaitForChild("PlayerbaseData")

--wait(5)

local NEW_DROP = true

local GameSettings
	--= _G.GameSettings
	
local function isRealNumber(num)
	return (typeof(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end

function newTool(tool,sOwner)
	if tools[tool] then return end
	if not tool:IsA("Tool") then return end
	
	local nTool = {}
	
	nTool.Tool = tool
	nTool.Owner = sOwner
	nTool.Busy = false
	nTool.Config = require(tool:WaitForChild("PassConfig",3))
	
	local cantDrop = Instance.new("BoolValue")
	cantDrop.Name = "CantDrop"
	cantDrop.Parent = tool

	function nTool:PassTool(mPlr,gTool,gChar,throwVel)
		if nTool.Busy then return end
		if gTool ~= tool then return end
		
		local toolLevel = 0
		local toolWeight = 1
		local locked = nil
		
		--if typeof(throwNum) ~= "number" or not isRealNumber(throwNum) or throwNum > 1 or throwNum < -1 then
		--	return
		--end
		if typeof(throwVel) ~= "Vector3" then
			return
		end

		local function cantMsg(msg)
			local tab = {
				Title = "Cant drop";
				Text = msg;
				--Icon = "";
				Duration = 2;
			}
			ReplicatedStorage.Events.Notification:FireClient(mPlr,tab,"lost")			
		end

		if cantDrop.Value or not nTool.Config.Enabled then
			cantMsg("Item cannot be dropped")
			return	
		end
		
		--local gPlr = Players:GetPlayerFromCharacter(gChar)
		
		--local md = pd:FindFirstChild(gChar.Name)
		
		--local GvF = _G.GVF(gChar.Name)

		--if calc < GameSettings.MinCashDropTime then
		--	game.ReplicatedStorage.Events.ClientWarn:FireClient(mPlr,{"You must be in the server for " .. GameSettings.MinCashDropTime - calc .. " more seconds to do this." ,1.5,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 	
		--	return
		--end
		
		--Events3.UpdateInv:Fire(gPlr)
		
		local inventoryCap = nil
		
		for _,z in pairs(ReplicatedStorage.Storage.ItemStats:GetDescendants()) do
			for _,v in pairs(z:GetChildren()) do
				if v.Name == tool.Name then
					toolLevel = v.Level.Value
					toolWeight = v.SlotUsage.Value
					
					--if md.Gamepasses:FindFirstChild("Weaponry") and v.SellStations:FindFirstChild("LegalStore") and v.SellStations.LegalStore:FindFirstChild("OverrideLevel") then
					--	toolLevel = v.SellStations.LegalStore.OverrideLevel.Value
					--end
					
					if (v:FindFirstChild("IsGamepass") and v.IsGamepass.Value)
						--or(not v.SellStations:FindFirstChild("IllegalStore") and not md.Gamepasses:FindFirstChild("Weaponry"))
					then 
						locked = "gamepass"
					end
					
					break
				end
			end
		end
		
		if tool:GetAttribute("CantDrop") then
			locked = true
		end
		
		if locked then
			cantMsg("Item cannot be dropped")
			return	
		end
		
		if ServerStorage.Values.DisableToolDropping.Value then
			cantMsg("Items cannot be dropped right now")
			return
		end
		
		--		if md.Level.Value < toolLevel and not md.Unlocked:FindFirstChild(tool.Name) then
		--			locked = "level"
		--		end
		
		if mPlr.Character 
			and mPlr.Character:FindFirstChild("Humanoid") 
			and _G.CheckIfCan(mPlr.Character) 
			and not _G.CheckIfFlinching(mPlr.Character)
			--and typeof(gChar) == "Instance"
			--and gChar.Parent == workspace.Characters
			--and gChar:FindFirstChild("HumanoidRootPart")
			--and gChar ~= mPlr.Character
		--	and (gChar.HumanoidRootPart.Position - mPlr.Character.HumanoidRootPart.Position).Magnitude < nTool.Config.Range * 1.5
		--	and _G.CheckIfCan(gChar)
		--	and not _G.CheckIfFlinching(gChar)
			and (tool.Parent == mPlr.Character or tool.Parent == mPlr.Backpack)
			and not tool:GetAttribute("THRZW")
			and not tool:GetAttribute("NZPO")
			
		then
			tool:SetAttribute("THRZW",true)
			
			nTool.Busy = true
			
			mPlr.Character.Humanoid:UnequipTools()
			Events3.RemoveBoughtTool:Fire(mPlr,tool)
			
			local t = tick()
			
			if tool:FindFirstChild("DisconREMOTE") and tool.DisconREMOTE.ClassName == "RemoteFunction" then
				tool.DisconREMOTE:InvokeClient(mPlr)
			end
			if mPlr.Character:FindFirstChild("radioEvent") then
				mPlr.Character.radioEvent:Fire("disconnect")
			end
			
			if (tool.Parent ~= mPlr.Backpack and tool.Parent ~= mPlr.Character) then return end
			
			local mChar = mPlr.Character
			local mRoot = mChar and mChar:FindFirstChild("HumanoidRootPart")
			
			--if not gPlr.Parent or not game.Players:FindFirstChild(gPlr.Name) then return end

			for _,v in pairs(tool:GetChildren()) do
				if v:IsA("Motor6D") then
					if v.Part0 and v.Part0:IsDescendantOf(mChar) then
						v.Part0 = nil
					elseif v.Part1 and v.Part1:IsDescendantOf(mChar) then
						v.Part1 = nil
					end
					
				end
			end
			
			tool.Parent = ServerStorage.HoldingTools
			
			local con
			
			local function bruh(_,parent,_,xdr)
				if parent == mPlr.Character or parent == mPlr.Backpack then
					if xdr then
						pcall(function()
							game.ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",tostring(mPlr.Name),"Server tamper: " .. "Possible attempt to dupe-glitch '" .. tostring(tool.Name) .. "'",3,true)
						end)
					end
					game:GetService("RunService").Heartbeat:Wait()
					tool.Parent = ServerStorage.HoldingTools
				end
			end
				
			con = tool.AncestryChanged:Connect(bruh)
			
			delay(0.15,function()
				--if tool.Parent and (tool.Parent == mPlr.Character or tool.Parent == mPlr.Backpack) then
				--	--mPlr.Character.Humanoid:UnequipTools()
					
					--end
				con:Disconnect()
				bruh(nil,tool.Parent,nil,true)
			end)
			
			local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("WeaponHandle") or tool:FindFirstChild("HHandle") or tool:FindFirstChild("Handle1") or tool:FindFirstChild("TrueHandle") or (tool:FindFirstChild("HandleVal") and tool.HandleVal.Value)
			if not handle then
				handle = mRoot.Position
			end
			
			local spawnedTool = Events3.CreateDropTool:Invoke(tool,CFrame.new(handle.Position + (mRoot.CFrame.LookVector)),nil,true,mPlr.Character)
			
			if spawnedTool then
				local mvel = throwVel
				mvel = Vector3.new(math.min(mvel.X,150),math.min(mvel.Y,150),math.min(mvel.Z,150))
				mvel = Vector3.new(math.max(mvel.X,-150),math.max(mvel.Y,-150),math.max(mvel.Z,-150))
				spawnedTool.Parent = workspace.Filter.SpawnedTools
				
				for _,v in pairs(spawnedTool:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Velocity = mvel
						v.CollisionGroup = "NoCharCollide2"
						v.CanCollide = true
						if v:CanSetNetworkOwnership() then
							v:SetNetworkOwner(nil)
						end
					end
				end
			end

			nTool.Owner = nil
			nTool.Busy = false
			
			delay(0.1,function()
				tool:SetAttribute("THRZW",nil)
			end)
	
		end
	end
	
	tools[tool] = nTool
	
	return nTool
end

initializeEvent.Event:Connect(newTool)

passEvent.OnServerEvent:Connect(function(plr,tool,passto,throwNum,throwVel)
	if plr.Character and tools[tool] then
		tools[tool]:PassTool(plr,tool,passto,throwNum,throwVel)
	end
end)

M.SetUp = function(settinz)
	GameSettings = settinz
	require(script.SurfaceAppearanceHandler)()
end

return M
