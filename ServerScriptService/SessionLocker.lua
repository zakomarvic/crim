local config = {
	SaveInStudio = false;
	Debug = false;
}

local S = {}
--------------------------------------------------------------------------------

local DATA_STORE_SERVICE =		game:GetService("DataStoreService")
local PLAYERS =					game:GetService("Players")
local RUN_SERVICE =				game:GetService("RunService")
local REPLICATED_STORAGE =		game:GetService("ReplicatedStorage")
local SERVER_STORAGE =			game:GetService("ServerStorage")

local SECONDS_IN_DAY = 86400
local DAY_ONE_START_TIME = 1604620799 --11/5/20 11:59:59 PM UTC https://www.epochconverter.com/

local RESET_INTERVAL = 12*60 -- in seconds

local KICK_MESSAGE = "\n\n Error loading your data, your account was detected in multiple game instances. Please rejoin. \n\n If still receiving error after 5-15 mins, report it at our Communications server."


local fastWait = require(REPLICATED_STORAGE:WaitForChild("Modules").FastWait)
local Events3 = SERVER_STORAGE:WaitForChild("Events3")
local cds = {}
local managingPlayers = {}

--local function GetCurrentDay()
--	return math.floor((os.time() - DAY_ONE_START_TIME)/SECONDS_IN_DAY)
--end

local function GetDataStoreId()
	return DATA_STORE_SERVICE:GetDataStore("^!@JobIdDay-10-" .. game.PlaceVersion .. math.floor(os.time()/RESET_INTERVAL))
end

local function DataStoreRetry(player, func, maxTries,x)
	for tries = 1, maxTries do
		if (player and player.Parent) or x then
			local success, receive = pcall(func)
			if success then
				return success, receive, tries
			else
				wait(10)
			end
		else
			return false, nil, tries
		end
	end
end

local function Print(a1,a2,a3,a4,a5)
	a1 = a1 or ""
	a2 = a2 or ""
	a3 = a3 or ""
	a4 = a4 or ""
	a5 = a5 or ""

	if config.Debug then
		warn("SessionLocker: " .. tostring(a1), tostring(a2), tostring(a3), tostring(a4), tostring(a5))
	end
end

local jobIdDataStore = GetDataStoreId()
local managingPlayers = {}
local restrictSave = {}
local SD = false

local function Shutdown()
	if SD then return end
	if RUN_SERVICE:IsStudio() and not config.SaveInStudio then return end

	SD = true

	for _, player in pairs(PLAYERS:GetPlayers()) do
		if managingPlayers[player] then
			managingPlayers[player] = nil
		end

		if not restrictSave[player] then
			local key = "Player-"..player.userId
			local success, _, tries = DataStoreRetry(
				player,
				function() 
					return jobIdDataStore:SetAsync(key, false) 
				end,
				3
			)
			if success then
				Print("Wiped with game on close")
			end
		end
	end
end

S.PlayerAddedCheck = function(player)
	if RUN_SERVICE:IsStudio() and not config.SaveInStudio then return true end

	local adonisLevel = 0

	local t = tick()

	repeat fastWait(0.2)
	until not player.Parent or (_G.Adonis and _G.Adonis.GetLevel(player) ~= nil) or tick() - t > 2

	if not (player and player.Parent) then return end

	adonisLevel = _G.Adonis and _G.Adonis.GetLevel(player)
	managingPlayers[player] = 0

	local key = "Player-"..player.userId
	local attempts = 0

	Print("ADDED PLAYER")

	local function DoCheck()
		if not (player and player.Parent) then return end
		attempts = attempts + 1

		local success, playerJobId, tries = DataStoreRetry(
			player,
			function() 
				return jobIdDataStore:GetAsync(key) 
			end,
			3
		)

		if success then
			if playerJobId then
				restrictSave[player] = true

				if attempts < 3 then
					wait(10)
					return DoCheck()
				end

				player:Kick(KICK_MESSAGE)

				local data = {
					jobid = game.JobId;
					first = os.time();
					last = os.time();
					id = math.random(-1000000,1000000);
					tries = 0;
				}

				local success, _, tries = DataStoreRetry(
					player,
					function() 
						return jobIdDataStore:UpdateAsync(key,function(oldValue)
							local newValue = oldValue or data

							newValue.tries = newValue.tries + 1
							newValue.last = os.time

							return newValue
						end)
					end,
					3
				)
			else
				local data = {
					jobid = game.JobId;
					first = os.time();
					last = os.time();
					id = math.random(-1000000,1000000);
					tries = 0;
				}

				local success, _, tries = DataStoreRetry(
					player,
					function() 
						return jobIdDataStore:UpdateAsync(key,function(oldValue)
							local newValue = oldValue or data

							return newValue
						end)
					end,
					3
				)

				if success then --recorded player job id
					Print("LOADING PLAYER DATA")
					--LOAD PLAYER DATA

					managingPlayers[player] = 0
					return true
				else
					attempts = attempts + 1
					if attempts < 3 then
						wait(10)
						return DoCheck()
					end
					--local id = player.UserId
					--player:Kick(KICK_MESSAGE)
					--delay(180,function()
					--	local key = "Player-"..id
					--	local success, _, tries = DataStoreRetry(
					--		player,
					--		function() 
					--			return jobIdDataStore:SetAsync(key, false) 
					--		end,
					--		3,
					--		true
					--	)
					--	if success then
					--		Print("Wiped by leaving")
					--	end
					--end)
				end
			end
		else
			restrictSave[player] = true
			player:Kick(KICK_MESSAGE)

			return false
		end
	end

	return DoCheck()
end

S.AddStore = function(player)
	if not managingPlayers[player] then
		return
	end

	managingPlayers[player] += 1 
end

S.RemoveStore = function(player)
	if not managingPlayers[player] then
		return
	end

	managingPlayers[player] -= 1 

	if managingPlayers[player] <= 0 then
		S.PlayerRemoving(player)
	end
end


S.PlayerRemoving = function(player)
	if RUN_SERVICE:IsStudio() and not config.SaveInStudio then return true end
	if not managingPlayers[player] then return end
	
	task.wait(0.1)
	
	managingPlayers[player] = nil
	
	if player:GetAttribute("LEAVE_SAVING") then
		local ev = Instance.new("BindableEvent")

		task.spawn(function()
			if not player:GetAttribute("LEAVE_SAVED") then
				player:GetAttributeChangedSignal("LEAVE_SAVED"):Wait()
			end
			pcall(function()
				if ev then
					ev:Fire()
				end
			end)
		end)
		task.delay(15,function()
			pcall(function()
				if ev then
					ev:Fire()
				end
			end)
		end)
		
		ev.Event:Wait()
		pcall(function()
			ev:Destroy()
			ev = nil
		end)
	end
	
	Print("SAVING PLAYER DATA " .. tostring(player))

	--wait(10)

	if not restrictSave[player] then
		--SAVE PLAYER DATA
		--make sure this step yields
		--only proceed to this AFTER the player's data has been done saving
		local key = "Player-"..player.userId
		local success, _, tries = DataStoreRetry(
			player,
			function() 
				return jobIdDataStore:SetAsync(key, false) 
			end,
			3,
			true
		)
		if success then
			Print("Wiped by leaving")
		end
	end

	restrictSave[player] = nil
end

--S.AddStore = function(player)
--	if not managingPlayers[player] then return end
--	managingPlayers[player] = managingPlayers[player] + 1

--	Print("ADDED",player,	managingPlayers[player])
--end

--S.RemoveStore = function(player)
--	if not managingPlayers[player] then return end

--	managingPlayers[player] = managingPlayers[player] - 1

--	Print("REMOVED",player,	managingPlayers[player])

--	if managingPlayers[player] <= 0 then
--		S.PlayerRemoving(player)
--	end	
--end

S.SetUp = function()
	if S.IsSetUp then return  end
	S.IsSetUp = true
	
	coroutine.wrap(function()
		while fastWait(1) do
			jobIdDataStore = GetDataStoreId()
		end
	end)()

	--PLAYERS.PlayerRemoving:Connect(function(player,x)
	--	if not x then
	--		wait(15)
	--	end

	--	S.PlayerRemoving(player)
	--end)

	game:BindToClose(Shutdown)
	game.ServerStorage.Events3.SDHSDDOWON.Event:Connect(function(code)
		if code ~= "DKLSD904U99IW4MKLSDFFW90ERF4IO3FIJ4890FWF043M4390MFRW9E0M0FS" then return end
		Shutdown()
	end)

	Events3.ClearSLog.Event:Connect(function(userId)
		if cds[userId] then return end
		cds[userId] = true
		
		local success,err = pcall(function()
			return jobIdDataStore:SetAsync("Player-"..userId, false) 
		end)

		if success then
			Print("Wiped by leaving")
		end

		delay(30,function()
			cds[userId] = nil
		end)
	end)
end

return S