local Players = game:GetService("Players")
local DatastoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local HTTPService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

local M = {
	LEADERBOARD_MSS_KEY = "COMP_LEADERBOARD_MSsS_2";
	DatastoreKey1 = "cldtest3"; -- DS
	DatastoreKey2 = "cldtest3"; -- MEM
	AutoReset = true;
	ResetTimer = 604800; -- 1 week
	
	DefaultDS_Data = {
		StartTick = 0;
		LbKey = "";
	};
	
	AutoUpdateRate = 15;
}

local leaderboardDataStore = DatastoreService:GetDataStore(M.DatastoreKey1)
local leaderboardSortMapStore
local Events = ReplicatedStorage.Events

local cachedData_DS
local cachedData_LB

local repr = require(ServerScriptService.repr)

local deepCopy = require(ReplicatedStorage.Modules.DeepCopy)

local function CanSave()
	return not RunService:IsStudio() and ReplicatedStorage.Values.DataSaving.Value
end

local function getAllKeyData(map)
	-- the initial lower bound is nil which means to start from the very first item
	local exclusiveLowerBound = nil

	local data = {}

	-- this loop continues until the end of the map is reached
	local succ,err = pcall(function()
		while true do
			-- get up to a hundred items starting from the current lower bound
			local items = map:GetRangeAsync(Enum.SortDirection.Ascending, 100, exclusiveLowerBound)

			-- print all keys retrieved in this call
			for _, entry in ipairs(items) do
				local key = entry.key
				local realVal = entry.value and HTTPService:JSONDecode(entry.value)
				if realVal then
					data[key] = realVal
				end
			end

			-- if the call returned less than a hundred items it means we’ve reached the end of the map
			if #items < 100 then
				break
			end

			-- the last retrieved key is the exclusive lower bound for the next iteration
			exclusiveLowerBound = items[#items].key
		end
	end)
	if not succ then
		warn("error w getAllKeyData",8,err)
	end
	
	return data
end

function M.AddKill(player,playerData,levelData)
	--print("add kill....")
	if not M.HasSetUp then return end
	if not leaderboardSortMapStore then return end
	if not cachedData_DS then return end
	
	--print("addkill2")
	
	local succ,err = pcall(function()
		leaderboardSortMapStore:UpdateAsync(tostring(player.UserId),function(data)
			if not data then
				data = {
					Level = 1;
					Kills = 0;
				}
			else
				data = HTTPService:JSONDecode(data)
			end
			
			data.Kills += 1
			data.Level = levelData.Level
			
			data = HTTPService:JSONEncode(data)
			return data
		end,86400)
	end)
	
	if not succ then
		warn("error with adding kill to leaderboard",err)
	end
end

function UpdateLeaderboard(bypass)
	--print("Update leaderboard..")

	if not bypass and M.BusyUpdating then
		return
	end

	if not cachedData_DS then
		warn("no cachedData_DS set!")
		return
	end
	if not leaderboardSortMapStore then
		warn("lSortMap not set!")
		return
	end

	if not M.lbModel then
		warn("no leaderboard model!")
		return
	end

	ClearLeaderboardUI()

	M.BusyUpdating = true

	local reset = CheckIfReset()
	UpdateMemStore()
	
	cachedData_LB = getAllKeyData(leaderboardSortMapStore)

	--wait(1)

	local addComas = require(ReplicatedStorage.Modules.AddComas)
	
	if not cachedData_DS or not cachedData_LB then
		return
	end

	local checkedData = {}
	for i,v in pairs(cachedData_LB) do
		if typeof(v) == "table" and v.Kills then
			v.UserId = i
			table.insert(checkedData,v)
		end
	end

	table.sort(checkedData,function(a,b)
		return a.Kills > b.Kills
	end)

	for i = 1,25 do
		local data = checkedData[i]

		if data then
			local playerName = nil

			pcall(function()
				playerName = Players:GetNameFromUserIdAsync(data.UserId)
			end)

			if playerName then		
				local frame = script.Frame:Clone()
				local txt = ""

				if i <= 3 then
					txt = txt .. '<font color="rgb(255,165,0)">'
				else
					txt = txt .. '<font color="rgb(255,255,255)">'
				end

				txt = txt .. '#' .. i .. '</font>' .. '  ' .. '@' .. playerName .. '  ' .. '<font color="rgb(170,170,170)">' .. addComas(data.Kills) .. '</font>'

				frame.TextLabel.Text = txt

				frame.Parent = M.lbFrame
			end
		end

		wait()
	end

	M.BusyUpdating = false
end

function ResetNotification()
	if M.LastRest and tick() - M.LastRest < 30 then
		return
	end
	
	M.LastRest = tick()
	
	local tab = {
		Title = "Leaderboard Reset";
		Text = "The leaderboard in Competitive mode has been reset";
		Duration = 60;
		Button1 = "Close";
	}

	Events.Notification:FireAllClients(tab,"Beep2")	
end

function CheckIfReset(updt)
	if M.AutoReset and (cachedData_DS.StartTick + M.ResetTimer) - (tick()) <= 0 then
		local succ,err = SetDefaultCached(true)

		if not succ then
			warn("failed to reset leaderboard data",err)
		else
			warn("successfully reset the leaderboard data")
		end
	
		if succ then
			local data = {
				Key = "0-4323-4239402-23419239392-234329";
				ServerId = game.PrivateServerId;
			}
			
			if CanSave() then
				MessagingService:PublishAsync(M.LEADERBOARD_MSS_KEY,data)
			end
			
			ResetNotification()
			
			UpdateLeaderboard(true)
		end
		
		return true
	end

	return false
end

function UpdateTimer()
	if not cachedData_DS then return end
	
	local t = (cachedData_DS.StartTick + M.ResetTimer) - (os.time())
	local function disp_time(time)
		local days = math.floor(time/86400)
		local hours = math.floor(math.fmod(time, 86400)/3600)
		local minutes = math.floor(math.fmod(time,3600)/60)
		local seconds = math.floor(math.fmod(time,60))


		--return seconds .. ":" .. minutes .. ":" .. hours .. ":" .. days

		return days .. ":" .. hours .. ":" .. minutes .. ":" .. seconds,days <= 0 and hours <= 12 
	end
	local timeTxt,gonnaEnd =  disp_time(math.max(t,0))

	local color = "255,255,255"
	if gonnaEnd then
		color = "255, 101, 103"
	end

	local txt = 'Resets In: <font color="rgb(' .. color .. ')">' .. timeTxt .. '</font>'
	M.timerLabel.Text = txt
	if M.AutoReset and t <= -5 then
		CheckIfReset()
	end
end

function ClearLeaderboardUI()
	for i,v in pairs(M.lbFrame:GetChildren()) do
		if v.ClassName ~= "UIListLayout" then
			v:Destroy()
		end
	end
end

function SetDefaultCached(save)
	print("set default cached")
	cachedData_DS = deepCopy(M.DefaultDS_Data)
	cachedData_DS.StartTick = os.time()
	cachedData_DS.LbKey = string.sub(HTTPService:GenerateGUID(),2,8)
	
	UpdateTimer()
	
	if CanSave() then
		if save then
			local succ,err = pcall(function()
				leaderboardDataStore:SetAsync("Leaderboard",cachedData_DS)
			end)

			if not succ then
				warn("failed to setDefault",err)
				return false
			else
				warn("successfully setDefaklt")
				return true,err
			end
		end
	end
	
	return true
end

function UpdateMemStore(noGet)
	local gd = nil
	
	if not noGet then
		local succ,err
		if CanSave() then
			succ,err = pcall(function()
				gd = leaderboardDataStore:GetAsync("Leaderboard")
			end)
			
			if succ then
				cachedData_DS = gd
			else
				warn("error with updatememstore GetAsync",err)
				return
			end
		else
			succ = true
		end
		
		if succ and not cachedData_DS then
			warn("no cachedData_DS found")
			SetDefaultCached(succ)
		end
	end
	
	local LS_MS_KEY = M.DatastoreKey1 .. "-" .. M.DatastoreKey2 .. "-" .. cachedData_DS.LbKey
	leaderboardSortMapStore = MemoryStoreService:GetSortedMap(LS_MS_KEY)
end

local function SetUpDS()
	cachedData_DS = nil

	local got_DS = false
	local didError = false
	for i = 1,10 do
		local succ,err = pcall(function()
			cachedData_DS = leaderboardDataStore:GetAsync("Leaderboard")
		end)

		if succ then
			got_DS = true
			warn("successflly got cachedData_DS")
			break
		else
			didError = true
			warn("error fetched cachedData_DS",err)
		end

		wait(10)
	end

	if not got_DS then return end
	
	if not cachedData_DS then
		SetDefaultCached(not didError)
	end

	UpdateMemStore()
end

function M.SetUp(GameSettings,doLeaderboard)
	if M.HasSetUp then return end
	if true then return end
	M.HasSetUp = true
	
	print("setup leaderboard")
	
	MessagingService:SubscribeAsync(M.LEADERBOARD_MSS_KEY,function(Message)
		local decodedData = Message.Data

		print("messagingservice ting")

		if decodedData.Key == "0-4323-4239402-23419239392-234329" and decodedData.ServerId ~= game.PrivateServerId then
			print("do reset")
			ResetNotification()
		end
	end)
	
	if doLeaderboard then
		M.lbModel = script.LeaderboardModel:Clone()
		M.lbModel.Parent = workspace:WaitForChild("Map",100):WaitForChild("Parts",100)
		M.lbGui = M.lbModel.UIPart.SurfaceGui
		M.lbFrame = M.lbGui.Frame.ScrollingFrame
		M.timerLabel = M.lbModel.UIPart.SurfaceGui.Frame.BottomBar.TextLabel
		
		SetUpDS()
		UpdateLeaderboard()
		UpdateTimer()
		
		spawn(function()
			while wait(1) do
				UpdateTimer()
			end
		end)
		while wait(M.AutoUpdateRate) do
			UpdateLeaderboard()
		end
	end
end

return M