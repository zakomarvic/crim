--[[
	SoftShutdown 1.2
	Author: Merely
	Edited by PhoenixRessusection
	This system lets you shut down servers without losing a bunch of players.
	The script teleports everyone in the/a server into a reserved server.
	
	When the reserved servers start up, they wait a few seconds, and then
	send everyone back into the main place.
--]]

local M = {}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local GUI = script:WaitForChild("Soft_Shutdown_GUI"):Clone()

local GetStartPlaceIdM = require(script.Parent.GetStartPlaceIdModule)

local SHUTDOWN_RECEIVED_MESSAGE_KEY = "SHUTDOWN_RECEIVED_SERVER"

M.SetUp = function(serverData,sConfig)
	if M.IsSetUp then return end
	M.IsSetUp = true
	
	local SD = false
	
	--print("SERVERDATA:",serverData)

	local desiredPlaceId = GetStartPlaceIdM(sConfig,(serverData and serverData.rules.gameMode) or "Casual")
	
	local function updtGUIText()
		GUI.Frame.TitleImage.Version.Text = ReplicatedStorage.Values.VersionType.Value .. " " .. ReplicatedStorage.Values.VersionNumber.Value
	end

	local function Shutdown()
		print("S0")
		
		if SD then return end
		print("S1")
		SD = true
		
		updtGUIText()
		
		print("S2")
		
		if (#Players:GetPlayers() == 0) then
			return
		end
		
		print("S3")
		
		if (game:GetService("RunService"):IsStudio()) then
			return
		end
		
		print("S4")

		pcall(function()
			ReplicatedStorage.Values.ShuttingDown.Value = true
			ServerStorage.Events3.SHDWN:Fire()
			
			ServerStorage:SetAttribute("UPDATE_MIGRATING",true)
			--ReplicatedStorage.Events.ShuttingDown:FireAllClients()
		end)
		
		print("S5")

		task.wait(0.15)
		print("S6")

		for _, plr in ipairs(Players:GetPlayers()) do
			pcall(function()
				if plr.Character then
					plr.Character = nil
				end

				local SS = GUI:Clone()
				SS.Frame.Label.Text = "REFRESHING SERVER, DO NOT EXIT THE GAME"
				SS.Parent = plr.PlayerGui
			end)
		end
		
		print("S7")

		print("shuthdown...")

		local reservedServerCode = TeleportService:ReserveServer(desiredPlaceId)
		
		print("creaitng reserve server...")

		local function TPPlayer(plr)
			TeleportService:TeleportToPrivateServer(desiredPlaceId, reservedServerCode, { plr },nil,nil,GUI)
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			TPPlayer(plr)
		end
		Players.PlayerAdded:Connect(TPPlayer)
		
		print("teleporting players...")

		while (#Players:GetPlayers() > 0) do
			wait(1)
		end
		
		wait(1)
	end

	if not serverData and (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then
		-- this is a reserved server without a VIP server owner
		
		if RunService:IsStudio() then
			return
		end

		local waitTime = 5

		ReplicatedStorage.Values.ShuttingDown.Value = true

		Players.PlayerAdded:Connect(function(plr)
			local SS = GUI:Clone()
			SS.Frame.Label.Text = "REFRESHING SERVER, DO NOT EXIT THE GAME"
			SS.Parent = plr:WaitForChild("PlayerGui")
			wait(3)

			--plr.Character.Humanoid.PlatformStand = true

			wait(waitTime)
			waitTime = waitTime / 2
			TeleportService:Teleport(desiredPlaceId, plr,nil,GUI)
		end)

		for _, plr in ipairs(Players:GetPlayers()) do
			TeleportService:Teleport(desiredPlaceId, plr,nil,GUI)
			wait(waitTime)
			waitTime = waitTime / 2
		end
	else
		updtGUIText()
		
		if not RunService:IsStudio() then
			game:BindToClose(function()
				print("WOP WOP SHUTDOWN WOP WOP SHUTDOWN!")
				wait()
				Shutdown()
			end)
		end

		game.ServerStorage.Events3.SDHSDDOWON.Event:Connect(function(code)
			if code ~= "DKLSD904U99IW4MKLSDFFW90ERF4IO3FIJ4890FWF043M4390MFRW9E0M0FS" then return end
			Shutdown()
		end)
	end
end

return M