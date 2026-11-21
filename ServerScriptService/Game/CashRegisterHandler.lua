local _ = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = 	game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local registersDir = workspace.Map.BredMakurz

local storage = Instance.new("Folder",game.Debris)
storage.Name = "RegistersStorage"

local PlayerbaseData = ServerStorage:WaitForChild("PlayerbaseData")

local modulesDir = ReplicatedStorage.Modules
local eventsDir = ReplicatedStorage.Events
local eventsDir3 = ServerStorage.Events3

local assetStorage = ServerStorage.Storage.CashRegisterStuff

local safeOpenedEvent = eventsDir3.SafeRegisterOpened
local logRemote = eventsDir3:WaitForChild("OLGR")

local config = {
	RegenTime = 360;
	SpawnStart = 60;
	
	MinPlayersPerc = 2;
}

local cachedOpenings = {}

if RunService:IsStudio() then
	config.SpawnStart = 0
end

local function RegenRegister(v,rt)
	if registersDir:FindFirstChild(v.Name) then
		registersDir[v.Name]:Destroy()
	end
	local nRegister = storage:FindFirstChild(v.Name):Clone()
	v:Destroy()
	nRegister.Parent = registersDir
	MonitorRegister(nRegister,rt)	
end

local function Lerp(a, b, c)
	return a + ((b - a) * c)
end

function MonitorRegister(v)
	--coroutine.resume(coroutine.create(function()
		assetStorage.Events:Clone().Parent = v
		assetStorage.Values:Clone().Parent = v
		
		
		v.Values.MPerc.Value = config.MinPlayersPerc
		
		local respawnTime = (v:FindFirstChild("RegenTime") and v.RegenTime.Value) or config.RegenTime
	
		if v:FindFirstChild("RegenTime") then
			v.RegenTime:Destroy()
		end
	
		if v:FindFirstChild("RegisterMain") then
			v.RegisterMain.Disabled = false
		end
		
		if v:FindFirstChild("MainPart") then
			CollectionService:AddTag(v.MainPart,"RegisterMainPart")
		end
		
		local c
		local can = true
		
		c = v.Values.Broken.Changed:Connect(function(x)
			if not x then return end
			c:Disconnect()
			wait(respawnTime)
			if v and v.Parent and can then
				RegenRegister(v,respawnTime)			
				can = false
			end
		end)
	--end))
end

for i,v in pairs(registersDir:GetDescendants()) do
	if v:IsA("BasePart") then
		CollectionService:AddTag(v,"FromRegistersFolder")
	end
end

ReplicatedStorage:WaitForChild("GameLoaded",1000)

for i,v in pairs(registersDir:GetChildren()) do
	if (ServerStorage.Values.SafesDisabled.Value and string.find(v.Name,"Safe")) or (ServerStorage.Values.RegistersDisabled.Value and string.find(v.Name,"Register")) then
		v:Destroy()
	else
		coroutine.wrap(function()
			v.Name = v.Name .. "_" .. i
			v.Parent = nil	

			wait(config.SpawnStart)

			script.RegisterMain:Clone().Parent = v
			v:Clone().Parent = storage

			v.Parent = registersDir

			MonitorRegister(v)
		end)()
	end
end

local function TrackCashFarmers()
	local MINIMUM_SCORE = 35
	local MINIMUM_DISTANCE = 300
	local CLEAR_AFTER_TIME = 120
	
	local function LogPlayer(plr,logs)
		local dataFolder = PlayerbaseData:FindFirstChild(plr.Name)
		if dataFolder then
			
			local level = dataFolder.Level.Value
			local hasPrime = dataFolder.Prime.Value
			
			local title = "" -- "Potential safe TP farming"
			local fullText = ""
			
			fullText ..= "Prime: " .. tostring(hasPrime)
			fullText ..= "\n"
			fullText ..= "Level: " .. tostring(level)
			fullText ..= "\n\n"
			
			for i,v in pairs(logs) do
				local text = "--LOG #" .. i .. "--"
				text ..= "\n"
				text ..=  "DISTANCE TRAVELLED: " .. v.distance .. " studs"
				text ..= "\n"
				text ..= "TIME TAKEN: " .. v.timeDifference .. "s"
				text ..= "\n"
				text ..= "SCORE: " .. v.calc
				text ..= "\n"
				text ..= "TIMESTAMP: " .. v.timeStamp

				if i < #logs then
					text ..= "\n\n"
				end

				fullText ..= text
			end

			local l_success = logRemote:Invoke("ZKLFXG890ZDFGJKN43SU8IOG","ExploitLog",plr.Name,"STP-LOG",title,fullText,"SafeFarm")
		end
	end
	
	safeOpenedEvent.Event:Connect(function(plr,model)
		if not plr.Character then
			return
		end
		if plr.Character:GetAttribute("HUCMV") then
			return
		end
		if not ReplicatedStorage.Values.DataSaving.Value then
			return
		end
		
		if not cachedOpenings[plr] then
			cachedOpenings[plr] = {
				cache = {};
				logs = {};
			}
			local con
			con = plr.AncestryChanged:Connect(function(_,parent)
				if not parent then
					con:Disconnect()
					local tab = cachedOpenings[plr]
					
					if tab and tab.logs and #tab.logs > 0 then
						LogPlayer(plr,tab.logs)
					end

					cachedOpenings[plr] = nil
				end
			end)
		end
		
		local pos = model.PrimaryPart and model.PrimaryPart.Position
		
		if pos then
			local result = {
				char = plr.Character;
				pos = pos;
				tim = os.time();
				model = model;
			}
			
			for i,v in pairs(cachedOpenings[plr].cache) do
				if v.char ~= result.char or result.tim - v.tim > CLEAR_AFTER_TIME then
					table.remove(cachedOpenings[plr].cache,i)
				end
			end
			
			for i,v in pairs(cachedOpenings[plr].cache) do
				local mag = math.round((v.pos - result.pos).Magnitude)
				local timeDis = result.tim - v.tim
				local calc = math.round(mag / timeDis)
				
				--print(mag,timeDis,calc)
				
				if mag > MINIMUM_DISTANCE and calc >= MINIMUM_SCORE then
					local log = {
						tim = os.time();
						timeStamp = os.date("%X");
						
						distance = mag;
						timeDifference = timeDis;
						calc = calc;
					}
					
					cachedOpenings[plr].cache = {}
					
					table.insert(cachedOpenings[plr].logs,log)
					
					warn("SERVERLOG: " .. "Added STP Log for: " .. tostring(plr.Name))
					
					--print("yeah thats getting logged lol..")
					break
				end
			end
			
			table.insert(cachedOpenings[plr].cache,result)
		end
	end)
end

TrackCashFarmers()

wait(config.SpawnStart)

--local tab = {
--	Title = "Robbery Notice";
--	Text = "All areas for robbery are now open.";
--	Icon = "";
--	Duration = 20;
--}
--ReplicatedStorage.Events.Notification:FireAllClients(tab,"BEEP")	

return _