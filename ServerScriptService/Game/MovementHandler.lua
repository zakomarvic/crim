local M = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepMovementEvent = ReplicatedStorage.Events:WaitForChild("MOVZREP")
local PlayerbaseData2 = ReplicatedStorage:WaitForChild("PlayerbaseData2",1000)

local plrs = {}
local DBs = {}
local oofs = {}

local function DB(Player)
	DBs[Player] = true
	delay(0.1,function()
		if plrs[Player] then
			DBs[Player] = nil
		end
	end)
end

local function newPlr(Player)
	if plrs[Player] then return end
	
	local pd2 = PlayerbaseData2:WaitForChild(Player.Name,1000)

	if not pd2 then return end
	
	pd2:WaitForChild("Loaded")
	
	if not pd2.Loaded.Value then
		pd2.Loaded.Changed:Wait()
	end

	plrs[Player] = true
	oofs[Player] = 0
	DBs[Player] = false	
end

local function incOofs(Player)
	oofs[Player] = oofs[Player] + 1

	if oofs[Player] >= 200 and tick() - ReplicatedStorage.Values.ServerTick.Value < 1 then
		Player:Kick("AE: Spamming replicator")
	else
		delay(1,function()
			if oofs[Player] then
				oofs[Player] = oofs[Player] - 1
			end
		end)
	end
end

local function RepEvent(Player,list)
	if Player and Player.Character and plrs[Player] and oofs[Player] <= 7 then
		--print(2)
		local Humanoid = Player.Character:FindFirstChild("Humanoid") 
		local Head = Player.Character:FindFirstChild("Head") 
		if Humanoid and Head and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			--print(3)
			if typeof(list) ~= "table" then return end

			local g_bm = list[1]
			local g_s = list[2]
			local g_c = list[3]
			local g_ws = list[4]

			--print(4,typeof(g_bm),typeof(g_s),typeof(g_c),typeof(g_ws))

			if typeof(g_bm) ~= "table" or typeof(g_c) ~= "boolean" or typeof(g_s) ~= "boolean" or typeof(g_ws) ~= "number" then return end

			--print(5)

			if #g_bm > 7 then return end

			--print(6)

			local bm = {}
			bm.mHit,bm.mOrigin,bm.cD,bm.H,bm.A,bm.iCS,bm.doSL = g_bm[1],g_bm[2],g_bm[3],g_bm[4],g_bm[5],g_bm[6],g_bm[7]

			if typeof(bm.mHit) ~= "Vector3" or typeof(bm.mOrigin) ~= "Vector3" or typeof(bm.cD) ~= "Vector3" 
				or (typeof(bm.H) ~= "boolean" and bm.H ~= nil) 
				or (typeof(bm.L) ~= "boolean" and bm.L ~= nil) 
				or (typeof(bm.R) ~= "boolean" and bm.R ~= nil) 
				or (typeof(bm.doSL) ~= "boolean" and bm.doSL ~= nil)
				or (typeof(bm.iCS) ~= "boolean" and bm.iCS ~= nil) 
			then 
				return 
			end
			
			DB(Player)
			incOofs(Player)

			--local orig = CFrame.new( 0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			--if (orig.p - bm.cD.Position).Magnitude > 0.1 then
			--	Player:Kick("AE: Possible head change exploit.")
			--	return
			--end

			local vF = _G.GVF(Player.Name)

			vF.Sprinting.Value = g_s
			vF.Crouching.Value = g_c
			vF.RepWalkSpeed.Value = math.min(g_ws,100)
			
			for _,v in pairs(game.Players:GetPlayers()) do
				if v ~= Player and plrs[v] then
					local pd2 = PlayerbaseData2:FindFirstChild(v.Name)
					if pd2 and pd2.Loaded.Value then
						RepMovementEvent:FireClient(v,Player.Character,bm.mHit,bm.mOrigin,bm.cD,bm.H,bm.A,bm.iCS,bm.doSL)
					end
				end
			end
		elseif DBs[Player] and oofs[Player] then
			incOofs(Player)
		end
	end	
end

M.SetUp = function()
	RepMovementEvent.OnServerEvent:Connect(RepEvent)
	
	Players.PlayerAdded:Connect(newPlr)

	Players.PlayerRemoving:Connect(function(Player)
		plrs[Player] = nil
		oofs[Player] = nil
		DBs[Player] = nil
	end)

	for _,v in pairs(Players:GetPlayers()) do
		newPlr(v)
	end
end

return M