local Domain = "https://webhook.lewisakura.moe/api/webhooks/"
--Int

_G.LibraryM = require(game:GetService("ServerScriptService"):WaitForChild("Library"))
--// Permissions:

_G.PermsList = {
	["Creators"] = {
		--
		"CoolGuy59999994", -- alt
		"2lives1", -- 2lies
		"TopCop81",
		--
	};

	["Owners"] = {
	};

	["HeadAdmins"] = {
	};

	["Admins"] = {
	};

	["SeniorModerators"] = {
	};

	["Moderators"] = {
	};
}

_G.Ohioians = {
	"j_s2rx",
	"infchiu",
	"stephanietyler79",
	"jannpablo",
	"psykono",
	"neuro7317",
	"lightismyguide",
	"definenotes",
	"thesnakeshadow",
	"thelivingdefiance",
	"forgottenpathfinder",
	"nerfhabs",
	"specoopsguy",
	"faust_l0l",
	"silvertao",
	"hashintine",
	"colorsaltacc",
	"heroblin",
	"tecnoxcraft",
	"zizypoilu",
	"zakomarvic",
	"s1nfonica",
	"paperfisho",
	"bridgeworked",
	"collxrrs",
	"pyramidnurse",
	"hopling_meh",
	"hannatwenty2",
	"iambigtrader",
	"efflorescedego",
	"handmedown67",
	"extractorium",
	"cavadxan56",
	"avampyr",
	"zx00z",
	"aeriilyyy",
	"celestiallyra",
	"n_otveryoriginal",
	"coney_cowboy",
	"6rz7",
	"d_1xn",
	"blanknight4",
	"purificationzz",
	"maxthecoollil",
	"k1ngwya",
	"chained654",
	"savasvarnas",
	"khezu_ro",
	"roastedhunter223",
	"funnyllla",
	"jermtt",
	"pitek_1500",
	"j4t2",
	"adriancoolman2",
	"m4w0rldbl0x",
	"avalaxus",
	"crimsonrare",
	"moth_mi1k",
	"hvskyz",
	"dutchmisfit",
	"vulns",
	"bloodextreme",
	"zerotowo0",
	"pwunct",
	"nyanchalantlori",
	"rellnquishment",
	"dralexbdp",
	"whitekoishi",
	"fragmentofruined",
	"nebulla0_0",
	"deeranged",
	"2lives1",
	"damietriace",
}

--[[if ((game.PrivateServerId == "") and (not game:GetService("RunService"):IsStudio())) then
	workspace:ClearAllChildren()

	game:GetService("ReplicatedFirst"):ClearAllChildren()
	game:GetService("ServerScriptService"):ClearAllChildren()
	game:GetService("ReplicatedStorage"):ClearAllChildren()
	game:GetService("ServerStorage"):ClearAllChildren()
	game:GetService("Players"):ClearAllChildren()
else
	--require(18689846415)()
end]]

local function GetTableChance(Table)
	local totalchance = 0

	for var_name,var_value in pairs(Table) do
		totalchance = totalchance+var_value
	end

	return totalchance
end

local function PickRandomFromTable(Table)
	local chance = math.random(0, GetTableChance(Table))

	for var_name,var_value in pairs(Table) do
		chance = chance - var_value

		if chance <= 0 then
			return var_name
		end
	end
end

local WorldEventHandler = require(script.WorldEventHandler)

_G.PickRandomFromTable = PickRandomFromTable

--Cash/XP/Data

_G.AllowanceCashMulti = 1
_G.AllowanceXPMulti = 1
_G.RegisterCashMulti = 2.325
_G.KillCashMulti = 0.5
_G.KillXPMulti = 1
_G.StartMoney = 15000000

_G.MasterKey = "OhioG_Data_V1.0.1"
_G.MainData = "DATA.OHIOG.VRELEASE1.0.1"

--Cases/Skins

_G.KilltrackChance = 10 --10
_G.AllowForceSkin = false
_G.ForceSkin = "beretta_wooden"

--Game-Stats

_G.PresentSpawnChance = 4
_G.FinishSpeedMulti = 1
_G.RebelSpawnTime = 2700
_G.UnlockPriceDiv = 10
_G.RebelLifetime = 480 -- 300
_G.DataQueue = 0

_G.SlayerSpawnTime = 18000
_G.SlayerTimePerc = 30
_G.SlayerSpawned = false
_G.SlayerUpdate = true
_G.SlayerChance = 100
_G.SlayerForce = 200
_G.SlayerUser = nil

_G.BossBarMaxTime = 3600
_G.BossBarActive = false

_G.TeddyMode = ""

_G.WE = function(...)
	return WorldEventHandler:init(...)
end

_G.GetData = function(dataStoreName, UserId)
	local key,val = nil,nil

	local success,response = pcall(function()
		local orderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore(dataStoreName .. "/" .. UserId)
		local dataStore = game:GetService("DataStoreService"):GetDataStore(dataStoreName .. "/" .. UserId)

		local pages = orderedDataStore:GetSortedAsync(false, 1)
		local data = pages:GetCurrentPage()
		if data[1] ~= nil then
			key = data[1]["key"]
			val = dataStore:GetAsync(data[1]["key"]) 
		end
	end)

	return key,val
end

--[[_G.NewJoinData = function(Player)

	local PlayerIsTeenager = game:GetService("PolicyService"):GetPolicyInfoForPlayerAsync(Player).AreAdsAllowed
	local PlayerVerified = _G.LibraryM.PVC(Player)
	local PlayerCountry = _G.LibraryM.GPC(Player)

	local TimeZone = os.date("%Z")
	local NewTimeZone = ""
	local Attempts = 0

	for i = 1, string.len(TimeZone) do
		if i == 1 then
			NewTimeZone = NewTimeZone .. string.sub(TimeZone, 1, 1)
		else
			if string.sub(TimeZone, i, i) == " " then
				NewTimeZone = NewTimeZone .. string.sub(TimeZone, i + 1, i + 1)
			end
		end
	end

	local Time = os.date("%I:%M:%S %p ") .. NewTimeZone .. " (" .. TimeZone .. ")"

	local FollowData = "This player didn't join off of someone."

	if Player.FollowUserId ~= nil and Player.FollowUserId ~= 0 then
		if Player:IsFriendsWith(Player.FollowUserId) then
			FollowData = "This player joined off of a friend. (" .. Player.FollowUserId .. ")"
		else
			FollowData = "This player joined off of a stranger."
		end
	end

	local JoinMode = 1

	local _, PlayerGameData = _G.GetData(_G.MasterKey, Player.UserId)
	local MainData = PlayerGameData["MainData" .. _G.MainData]

	if MainData.TimePlayed <= 60 then
		JoinMode = 2
	end

	local Title = JoinMode == 2 and "JOIN DATA (NEW) < 60 " .. MainData.TimePlayed or "JOIN DATA " .. MainData.TimePlayed
	local Color = JoinMode == 2 and 16777215 or 1

	local Data = {
		['embeds'] =  {
			{
				['color'] = Color,
				['title'] = Title,
				['description'] = "-------------------------------------------------",
				['url'] = "https://www.roblox.com/users/".. Player.UserId .. "/profile",
				['fields'] =   {
					{
						['name'] = "PLAYER:",
						['value'] = Player.DisplayName .. " (@" .. Player.Name .. ") | " .. Player.UserId
					},
					{
						['name'] = "JOIN METHOD:",
						['value'] = FollowData
					},
					{
						['name'] = "TIME STAMP:",
						['value'] = Time
					},
					{
						['name'] = "ACCOUNT AGE:",
						['value'] = Player.AccountAge .. " Days."
					},
					{
						['name'] = "-------------------------------------------------",
						['value'] = ""
					},
					{
						['inline'] = true,
						['name'] = "VERIFIED",
						['value'] = PlayerVerified
					},
					{
						['inline'] = true,
						['name'] = "TEENAGER",
						['value'] = PlayerIsTeenager
					},
					{
						['inline'] = true,
						['name'] = "COUNTRY",
						['value'] = PlayerCountry
					},
				},
			}
		}
	}

	local function SubmitData()
		if Attempts >= 3 then
			warn(Player.Name .. "'s Data Couldn't Be Sent.")
			return
		end

		_G.DataQueue += 1
		Attempts += 1

		delay(3, function()
			_G.DataQueue -= 1
		end)

		task.wait(_G.DataQueue)

		local FinalData = game:GetService("HttpService"):JSONEncode(Data)

		local Success, Response = pcall(function()
			game:GetService("HttpService"):PostAsync(_G.Webhooks.Joined, FinalData)
		end)

		if not Success then
			SubmitData()
		end
	end

	if not game:GetService("RunService"):IsStudio() then
		SubmitData()
	end
end]]

_G.ReturnData = function(Name)
	pcall(function()
		local UserId = game:GetService("Players"):GetUserIdFromNameAsync(Name)

		local _, PlayerGameData = _G.GetData(_G.MasterKey, UserId)
		local MainData = PlayerGameData["MainData" .. _G.MainData]

		return PlayerGameData, MainData
	end)
end



local CollectionS = game:GetService("CollectionService")
local RepStorage =game:GetService("ReplicatedStorage")
local MemoryS =	game:GetService("MemoryStoreService")
local MessageS = game:GetService("MessagingService")
local SSS =	game:GetService("ServerScriptService")
local PhysicsS = game:GetService("PhysicsService")
local ServerS = game:GetService("ServerStorage")
local StarterP = game:GetService("StarterPack")
local SoundS = game:GetService("SoundService")
local HTTPs = game:GetService("HttpService")
local Playerz = game:GetService("Players")
local RunS = game:GetService("RunService")

function DP(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DP(v)
		end
		copy[k] = v
	end
	return copy
end

local d_MOMENTO = not RunS:IsStudio()

local DS_Settings = {
	MasterKey = _G.MasterKey, -- 

	NoStudioData = false,
	StudioMaxedOutStats = false,
	MainDataKey = _G.MainData,
	MoneyKey =	"MONEY.1",
	LevelKey =	"LEVEL.1",
	OtherKey = "OTHER.1",
	TempDataKey = "TEMP.1",
	ClientSettingsKey = "CS.T.6",

	TwitterCodeKey = "TWITTER.1",
	DoubleXP_PlayerKey = "DX1.0",

	DailyLogin_PlayerKey = "DL.0",

	TestingPlaceIds = {
		8966730058,
	},

	GroupId = 4165692,

	TesterCodeThing = "1.0",
}

local GameSettings = {
	VersionNumber = "V0.0.8-E",
	VersionType = "",

	PermDoubleXP = false,
	WeekendDoubleXP = false,

	SafeMulti = 1,

	TestingConfigs = {
		SetMoney = 2500000,
		SetLevel = 125,
	},

	Restock = {
		IllegalStore = {
			Min = 4,
			Max = 6,

			Randomise = true,
		},
		CUStore = {
			Min = 4,
			Max = 6,

			Randomise = true,
		},
		LosDealer = {
			Min = 4,
			Max = 6,

			Randomise = true,
		},
		CasinoStore = {
			Min = 4,
			Max = 6,

			Randomise = true,
		},
		LegalStore = {
			Min = 8,
			Max = 8,

			Randomise = false,
		},
		
		WAStore = {
			Min = 4,
			Max = 6,

			Randomise = true,
		},
		
	},

	AllowanceTime = 15,
	Allowance = 200000,

	Allowance_XP = 600, -- og was 1k

	GamepassAllowanceMulti = 1.5,
	GroupAllowanceMulti = 1.1,
	PremiumAllowanceMulti = 1.3,

	MinDeposit = 1, -- was  50
	MinWithdraw = 1, -- was 50
	MaxWithdraw = 99999900, -- was 1000000

	StartMoney = _G.StartMoney,

	CashLossPercentage = 0.35,
	CL_CashLossPercentage = 0.35,

	CL_BankLoss = 0,
	BankLoss = 0,
	MaxCashDeathDrop = 99900, -- 500
	CashDeathDropTimer = 180, -- 120

	LevelMulti = 1,
	MaxLevel = 1000,

	MinCashToBank = 100, -- 500

	KillCash_Min = 10000,
	KillCash_Max = 1000000,
	KillXP_Min = 80,
	KillXP_Max = 150,

	AssistXP_Multi = 0.35,
	AssistKill_Multi = 0.35,

	KillBounty = 100,
	AssistBounty = 50,
	MaxBounty = 10000000,
	BountyReducAmt = 1,

	NoBountyInCombatZones = true,

	KillBountyXPPerc = 0.35,
	AssistBountyCashPerc = 0.35,
	AssistBountyXPPerc = 0.2,

	BountyLossPerc = 0,

	MaxAssists = 6,
	NoAssistIfDie = true,

	START_XP = 1000,
	START_LEVELUP_REWARD = 500,

	MaxNonPrimeLevel = 999, -- no xp after this in non-prime servers

	DoubleXP_MaxTime = 18000, -- seconds

	MinRegisterBreakTime = 0,
	MinCashDropTime = 0,

	MinRentingLevel = 1, --used to be 10
	MinAccountAge = 50, --days

	AutoSaveTime = 5, -- mins

	RespawnTime = 2,

	MinRespawnDist = 250,
	MinRespawnToPlayerDist = 100,

	PackageSettings = {
		Package = "Whitelist",
		Head = "Whitelist",
		NoBlackBodyColor = true,
	},

	CashDropSettings = {
		MinDropAmount = 10,
		MaxDropAmount = 10000000,
		Max2DropAmount = 10000000,

		DropCooldown1 = 2, -- seconds
		DropCooldown2 = 0, -- minutes

		PickupCooldown = 0.7,
	},

	MaxServerLootDrops = false, --game.GameId == 1857700501 or RunS:IsStudio(), -- Count it as a full server for the max drops.

	DoubleXP_AutoExpireHours = 7200000, -- 72

	NoStudioMomento = true, -- Doesnt allow testing when put on false

	RandomAvatarEnabledForNewPlayers = false, -- random avatar 100% of the time when enabled

	ItemExpiration = {
		Enabled = true,
		MaxTime = 604800, -- 7 days 604800
	},

	GamemodeRules = {
		["Standard"] = {LootCashMulti = 20, KillCashMulti = 5, KillXPMulti = 5},
		["Casual"] = {},
		["Competitive"] = {},
		["Infection"] = {},
	},
	DefaultGamemode = "Standard",

	TestMapEnabled = false,
	TestMap = "TEST_MAP",

	ShopFromBank = {
		Enabled = true,
		MinFee = 50,
	},

	MinResupplyCooldown = 5, -- seconds (guns,armor)
	
	CuffSettings = {
		Enabled = true,
		JailTime = 30,          -- total seconds a player stays cuffed
		CountOfflineTime = false, -- true: time spent offline counts down; false: it pauses while they're gone
		AutoRelease = true,      -- release cuffs when JailTime runs out (also applies to normal cuffing)
		RestorePosition = false, -- true: put them back where they logged out
		ReapplyDelay = 2,        -- seconds after spawning before cuffs are re-applied
	},
}

for i,v in pairs(GameSettings.GamemodeRules) do
	if script.GamemodeRules:FindFirstChild(i) then
		GameSettings.GamemodeRules[i] = require(script.GamemodeRules[i])
	end
end

GameSettings.GamemodeRules["B-Casual"] = DP(GameSettings.GamemodeRules.Casual)
GameSettings.GamemodeRules["M-Casual"] = DP(GameSettings.GamemodeRules.Casual)
GameSettings.GamemodeRules["P-Casual"] = DP(GameSettings.GamemodeRules.Casual)
GameSettings.GamemodeRules["MG-Casual"] = DP(GameSettings.GamemodeRules.Casual)
GameSettings.GamemodeRules["P-Casual"] = DP(GameSettings.GamemodeRules.Casual)
GameSettings.GamemodeRules["C-Standard"] = DP(GameSettings.GamemodeRules.Standard)
GameSettings.GamemodeRules["G-Standard"] = DP(GameSettings.GamemodeRules.Standard)
GameSettings.GamemodeRules["M-Standard"] = DP(GameSettings.GamemodeRules.Standard)

if GameSettings.DefaultGamemode == "Infection" then
	GameSettings.TestMapEnabled = false
end

local SHUTDOWN_MESSAGE_KEY = "SHUTDOWN_RESERVE_SERVER"
local SHUTDOWN_RECEIVED_MESSAGE_KEY = "SHUTDOWN_RECEIVED_SERVER"

local GetStartPlaceIdM = require(script.GetStartPlaceIdModule)














_G.GSAT345NIJ384TU034TRWEFGKFGS = GameSettings

local PlayerManager,ShopAtmHandler

local IS_STUDIO = RunS:IsStudio()
local thisServerData

local function HandleRebelDealer()
	task.spawn(function()
		local Tick = tick()

		while task.wait(0.5) do
			if tick() - Tick > _G.RebelSpawnTime then

				Tick = tick()

				_G.SpawnRebel()
			end
		end
	end)
end

local SlayerM = require(game:GetService("ServerStorage"):WaitForChild("Modules").Combat.SlayerModule)

_G.SpawnSword = function(Visual)
	SlayerM.Spawn(Visual)
end

local SL_Tick = tick()

local function HandleSlayerStone()
	task.spawn(function()
		while task.wait(0.5) do
			if not _G.SlayerSpawned then
				local TotalTime = _G.SlayerSpawnTime
				local TimeDisc = #game:GetService("Players"):getPlayers() * _G.SlayerTimePerc

				TotalTime -= TimeDisc

				if tick() - SL_Tick > TotalTime then
					game:GetService("ServerStorage"):WaitForChild("Events3"):WaitForChild("SpawnSword"):Fire(true, true)
				end
			end
		end
	end)
end

local ChargeT = nil
local code = nil

local function Cancel()
	pcall(function()
		ChargeT:Cancel()
	end)
end

local function ZapPlayer(player, DoFling)
	if not player.Character:FindFirstChild("DB_SlayerZap") and not player.Character:FindFirstChildOfClass("ForceField") then
		local DB = Instance.new("BoolValue", player.Character)
		DB.Name = "DB_SlayerZap"
		game.Debris:AddItem(DB, 1.5)
		local hitForce = _G.SlayerForce

		local VF = _G.GVF(player.Name)

		if VF then
			_G.SMains.RagdollChar(player.Character,3)

			if DoFling then
				_G.ExplosionForce(player.Character.Torso,workspace.Map.SlayerStones.Stone.Position - Vector3.new(0,5,0),1,10,hitForce,false,1)
			end

			local z = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.OofZap:Clone()
			z.Parent = player.Character.HumanoidRootPart
			z:Play()
			game.Debris:AddItem(z)

			local z = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.ZapS:Clone()
			z.Parent = player.Character.HumanoidRootPart
			z:Play()
			game.Debris:AddItem(z)

			local p = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.ParticleEmitter:Clone()
			p.Parent = player.Character.HumanoidRootPart
			p:Emit(35)
			game.Debris:AddItem(p)

			_G.Scream(player.Character,player.Character["Head"],"Scream" .. math.random(1,5))

			local tvf = _G.GVF(player.Character.Name)

			if tvf then
				local poisV = Instance.new("NumberValue")
				poisV.Name = "FLAMESKRATA"
				poisV:SetAttribute("NoIcon",true)
				poisV.Value = 0.5
				game.Debris:AddItem(poisV,2)
				poisV.Parent = tvf.Currents
			end

			local v = player.Character
			local TIME = 2

			local Mag = (workspace.Map.SlayerStones.Stone.Handle.CFrame.p - player.Character.HumanoidRootPart.CFrame.p).Magnitude

			local t = {
				"la";
				"ra";
				"ll";
				"rl";
				--"n";
			}

			_G.AffectChar(v,"Stunned",TIME)

			for i,z in pairs(t) do
				game.ServerStorage.Events3.LimbTing:Fire(v,"damage",z,10)
			end

			for i,z in pairs(game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.Particles:GetChildren()) do
				z = z:Clone()
				z.Parent = v.Torso
				if z:IsA("ParticleEmitter") then
					game.Debris:AddItem(z,0.5)
					z:Emit(20)
				else
					game.Debris:AddItem(z,0.15)
					z.Enabled = true

				end
			end

			local ConcussionEffect = {
				Enabled = true;
				Time = 1;
				Multi = 0.8;
				DoLimit = true;
				Limit_FadeTime = 1;
				Limit_Perc = 0.1;
			}

			local cTime = ConcussionEffect.Time
			local cMulti = ConcussionEffect.Multi

			if VF then
				cTime = cTime * VF.ConcussionProof.Value
				cMulti = cMulti * VF.ConcussionProof.Value
			end

			game:GetService("ReplicatedStorage").Events.CONC_EF:FireClient(player,cTime,cMulti,ConcussionEffect.DoLimit,ConcussionEffect.Limit_FadeTime,ConcussionEffect.Limit_Perc)

			local sc = game:GetService("ServerStorage").Storage.Scripts.BurningScript:Clone()
			sc.IsFrostbite.Value = true
			sc.Time.Value = TIME
			sc.Dmg.Value = 5

			sc.Parent = v
			sc.Disabled = false
		end
	end
end

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PIC_S").OnServerEvent:Connect(function(player, sword)

	if not player.Character then
		return
	end

	local Handle = workspace.Map.SlayerStones.Stone.Handle

	if sword == "Start" then
		if _G.SlayerUser ~= nil and _G.SlayerUser:IsA("Player") then
			if player ~= _G.SlayerUser and _G.SlayerUser and _G.SlayerUser.Character and _G.SlayerUser.Character:FindFirstChild("Humanoid") and (_G.SlayerUser.Character.Torso.Position - workspace.Map.SlayerStones.Stone.Handle.Position).Magnitude < 10 and not _G.RagdollCheck(_G.SlayerUser.Character) and not _G.DownedCheck(_G.SlayerUser.Character) then

				game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(player, {
					"ONE AT A TIME" .. string.reverse(".RN") ,1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"
				})

				ZapPlayer(player, false)

				return false
			else
				Cancel()

				Handle.Charge.TimePosition = 0
				Handle.Charge.Volume = 1
				Handle.Charge:Play()

				code = math.random()

				task.spawn(function()

					local Tick = tick()
					local J = code

					while task.wait() do

						if J ~= code then
							break
						end

						if tick() - Tick >= 2 then

							pcall(function()
								Handle.Blade.LightningPart:Emit(1)
								Handle.Zap:Play()
							end)

							local tim = math.random(5, 40) / 15

							task.wait(tim)
						end
					end
				end)
				_G.SlayerUser = player
				return true
			end
		else
			Cancel()

			Handle.Charge.TimePosition = 0
			Handle.Charge.Volume = 1
			Handle.Charge:Play()

			code = math.random()

			task.spawn(function()
				local Tick = tick()
				local J = code
				while task.wait() do
					if J ~= code then
						break
					end
					if tick() - Tick >= 2 then

						pcall(function()
							Handle.Blade.LightningPart:Emit(1)
							Handle.Zap:Play()
						end)

						local tim = math.random(5, 40) / 15

						task.wait(tim)
					end
				end
			end)

			_G.SlayerUser = player

			return true
		end
	elseif sword == "End" then
		if _G.SlayerUser ~= nil and _G.SlayerUser:IsA("Player") then
			if player == _G.SlayerUser then

				local Last = Instance.new("BoolValue", player.Character)
				Last.Name = "LastUser"
				game.Debris:AddItem(Last, 0.25)

				Cancel()

				ChargeT = game:GetService("TweenService"):Create(workspace.Map.SlayerStones.Stone.Handle.Charge, TweenInfo.new(1), {
					Volume = 0
				})

				ChargeT:Play()

				_G.SlayerUser = nil

				code = math.random()

				return true
			end
		end
	elseif sword:IsA("BasePart") and sword.Name == "Handle" then
		if player.Character:FindFirstChild("LastUser") then
			local Chance = _G.SlayerChance	
			local Got = false

			if Chance <= 1 then
				Got = true
			else
				if math.random(Chance) == math.random(Chance) then
					Got = true
				end
			end

			code = math.random()

			local Handle = workspace.Map.SlayerStones.Stone.Handle
			local OG_AP = Handle.posA.WorldCFrame

			Handle.posA.WorldCFrame = Handle.posA.WorldCFrame * CFrame.new(0, 100, 0)

			local FF = Instance.new("ForceField", player.Character)
			FF.Visible = false

			task.wait(1)

			delay(0.5, function()
				Handle.posA.WorldCFrame = OG_AP
			end)

			if Got then
				game:GetService("ReplicatedStorage").Events.NewSword:FireAllClients(workspace.Map.SlayerStones.Stone, false)

				local SoundPart = Instance.new("Part", workspace.Debris)
				SoundPart.Size = Vector3.new(0.1, 0.1, 0.1)
				SoundPart.Transparency = 1
				SoundPart.CanCollide = false
				SoundPart.Anchored = true
				SoundPart.CFrame = workspace.Map.SlayerStones.Stone.CFrame

				local SoundTo = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets:WaitForChild("SpawnSlayer"):Clone()
				SoundTo.Parent = SoundPart
				SoundTo.Volume = 3
				SoundTo:Play()

				local Beam = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.Beam:Clone()
				Beam.Parent = workspace.Debris
				Beam.Beam1.Enabled = true
				Beam.Beam2.Enabled = true

				local Ball = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.Ball:Clone()
				Ball.Parent = workspace.Debris

				local TimePos = SoundTo.TimePosition

				local FakeAudio = SoundTo:Clone()
				FakeAudio.Parent = SoundPart
				FakeAudio.Volume = 0.01
				FakeAudio.TimePosition = TimePos

				for _, v in pairs(workspace.Characters:GetChildren()) do
					if v and v.Parent and v.Parent:FindFirstChildOfClass("Humanoid") and game:GetService("Players"):GetPlayerFromCharacter(v.Parent) and v.Parent.Humanoid.Health > 0 and v.Parent:FindFirstChild("Torso") and (v.Parent.Torso.Position - workspace.Map.SlayerStones.Stone.Position).Magnitude <= 15 then
						if game:GetService("Players"):GetPlayerFromCharacter(v) then
							ZapPlayer(game:GetService("Players"):GetPlayerFromCharacter(v), true)
						end
					end
				end

				local CON = Ball.Touched:Connect(function(A)
					if A and A.Parent and A.Parent:FindFirstChildOfClass("Humanoid") and A.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
						if game:GetService("Players"):GetPlayerFromCharacter(A.Parent) then
							ZapPlayer(game:GetService("Players"):GetPlayerFromCharacter(A.Parent), true)
						end
					end
				end)

				game:GetService("TweenService"):Create(Ball, TweenInfo.new(0.25), {Transparency = 0}):Play()

				game:GetService("ReplicatedStorage").Events.ExplosionEffect:FireAllClients(SoundPart,FakeAudio,
					{
						FakeAudio --s
						,6 -- time
						,100 -- distance
						,1
						,7
						,7
						,1
					}
				)

				game.Debris:AddItem(Beam, 1)
				game.Debris:AddItem(SoundPart, 10)

				Handle.CFrame = workspace.Map.SlayerStones.Stone.Attachment0.WorldCFrame
				Handle.CanQuery = false

				game:GetService("ReplicatedStorage").Events.GotSwordE:FireAllClients(Handle)

				Handle.Blade.ParticleEmitter.Enabled = true
				Handle.Blade.ParticleEmitterGlow.Enabled = true
				Handle.Blade.LightningPart.Enabled = true
				Handle.Blade.PointLight.Enabled = true

				delay(4, function()
					Handle.Burn:Play()
					Handle.Blade.Burn:Emit(50)

					Handle.Blade.ParticleEmitter.Enabled = false
					Handle.Blade.ParticleEmitterGlow.Enabled = false
					Handle.Blade.LightningPart.Enabled = false
					Handle.Blade.PointLight.Enabled = false
					Handle.Blade.Transparency = 1

					pcall(function()
						CON:Disconnect()
					end)

					if Ball and Ball.Parent then
						game:GetService("TweenService"):Create(Ball, TweenInfo.new(0.25), {Transparency = 1}):Play()
					end

					game.Debris:AddItem(Handle, 4)

					pcall(function()

						task.wait(2)

						if player then
							for _, v in pairs(player.Backpack:GetChildren()) do
								if v:IsA("Tool") then
									v:Destroy()
								end
							end

							local CONFIG = {
								PoisonReleaseDelay = 300;
								PoisonDamageMulti = 10;
								PoisonRateMulti = 10;
							}

							local delayT = 3600
							local dmgMulti = 10
							local rateMulti = 10

							player.Character:SetAttribute("DEATH_START_TICK",game:GetService("ReplicatedStorage").Values.ServerTick.Value)
							player.Character:SetAttribute("DEATH_MAX_TIME",delayT)

							task.delay(delayT,function()
								if player.Character and player.Character.Parent then
									local poisionS = game:GetService("ServerStorage").Tools.POISON_HANDLER:Clone()
									poisionS:SetAttribute("CustomColor",Color3.fromRGB(255, 119, 0))
									poisionS:SetAttribute("CustomName","REDACTED")
									poisionS:SetAttribute("CantCure",true)
									poisionS:SetAttribute("DamageMulit",dmgMulti)
									poisionS:SetAttribute("RateMulti",rateMulti)
									poisionS:SetAttribute("KillOnDown",true)
									poisionS.Parent = player.Character
									poisionS.Disabled = false
								end
							end)

							local ui = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.DeathTimerUI:Clone()
							ui.Parent =  player.PlayerGui
							ui.DeathTimerLS.Disabled = false

							local BURN = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.GOTBURN:Clone()
							BURN.Parent = player.Character.HumanoidRootPart
							BURN:Emit(50)
							game.Debris:AddItem(BURN, BURN.Lifetime.Max)

							local BOOM = game:GetService("ServerStorage").Modules.Combat.SlayerModule.Assets.BOOM:Clone()
							BOOM.Parent = player.Character.HumanoidRootPart
							BOOM:Play()
							game.Debris:AddItem(BOOM)

							local AMR = game:GetService("ServerStorage").Tools.SlayerArmour:Clone()
							AMR.Parent = player.Character

							local SWD = game:GetService("ServerStorage").Tools.SlayerSword:Clone()
							SWD.Parent = player.Backpack

							if FF and FF.Parent then
								FF:Destroy()
							end
						end
					end)

					task.wait(5)

					game:GetService("ServerStorage"):WaitForChild("Events3"):WaitForChild("SpawnSword"):Fire(false)
				end)

				return true
			else
				if FF and FF.Parent then
					FF:Destroy()
				end

				game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(player, {
					"YOU ARE NOT WORTHY. (you get inf tries)" ,1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"
				})

				workspace.Map.SlayerStones.Stone.Handle.Fail:Play()

				ZapPlayer(player, true)

				return false
			end
		end
	end
	return true
end)

game:GetService("ServerStorage"):WaitForChild("Events3"):WaitForChild("SpawnSword").Event:Connect(function(A, B)

	_G.SlayerSpawned = A

	if not A then

		SL_Tick = tick()

		_G.SlayerUser = nil
	elseif A and B ~= nil then
		task.spawn(function()
			_G.SpawnSword(B)
		end)
	end
end)

local function HandleServerListData()
	local matchSortMapStore = MemoryS:GetSortedMap("TestSM_1_2")
	local ruleSortMapStore = MemoryS:GetSortedMap("TestRM_1_2")

	local function getJobId()
		local jobId = game.PrivateServerId
		if jobId == "" then
			jobId = "Ohio"
		end
		return jobId
	end

	local function getShortServerId(id)
		return string.sub(id,0,7)
	end

	local playerList = {}
	local playerData = {}
	local serverLive = true

	local whitelist = nil

	local function updateServerData()
		if not thisServerData then return end

		local n = {}
		for i,v in pairs(Playerz:GetPlayers()) do
			local data = playerData[v]
			if data then
				table.insert(n,{v.UserId,data})
			end
		end

		thisServerData.data.playerList = n

		thisServerData.data.maxPlayers = math.min(ServerS.Values.MaxPlayers.Value,Playerz.MaxPlayers)
		--thisServerData.data.lastUpdated = os.time()

		thisServerData.data.updateMigrating = (ServerS:GetAttribute("UPDATE_MIGRATING") and true) or nil
		thisServerData.data.serverLocked = (ServerS:GetAttribute("SERVER_LOCKED") and true) or nil
		thisServerData.data.menuHide = (ServerS:GetAttribute("SERVER_MENU_HIDE") and true) or nil

		if whitelist and #whitelist > 0 then
			thisServerData.data.whitelist = DP(whitelist) 
		else
			thisServerData.data.whitelist = nil
		end

		return thisServerData
	end

	local function createServerData(noJob,customrules)
		local t = {}

		t.rules = {gameMode = "Standard"}

		local countryCode =  "US"
		local latitude = 0
		local longitude =  0

		local data = {
			serverId = getJobId(),
			placeId = game.PlaceId,

			accessCode = 0,

			playerList = {},
			maxPlayers = 75,

			vip = nil,
			vipOwner = nil,
			prime = nil,

			countryCode = countryCode,
			--regionName = regionName,
			lat = latitude,
			lon = longitude,

			--lastUpdated = os.time(),
		}

		t.data = data

		ServerS.Values.MaxPlayers.Value = data.maxPlayers

		return t
	end

	local function Update()

		local id = getJobId()

		local udata = updateServerData()

		local TableInJson = HTTPs:JSONEncode(udata)

		local success,erro = pcall(function()
			matchSortMapStore:UpdateAsync(id,function(data)
				return TableInJson
			end,15)
		end)

		if not success then
			warn("error 21F90DPK",erro,#TableInJson)
		end
	end

	local function Shutdown()
		if not serverLive then return end
		serverLive = false
		pcall(function()
			matchSortMapStore:RemoveAsync(getJobId())
		end)
	end

	thisServerData = createServerData()

	if thisServerData then
		local success,erro = pcall(function()
			local udata = updateServerData()
			local TableInJson = HTTPs:JSONEncode(udata)
			matchSortMapStore:SetAsync(getJobId(),TableInJson,15)
		end)

		spawn(Update)
		spawn(function()
			while serverLive do
				Update()
				wait(3)
			end
		end)

		game:BindToClose(function()
			Shutdown()
		end)
	else
		warn("couldnt find server data, now refreshing")
	end

	local function TPBack(plr,cr)
		--[[local desiredPlaceId = game.GameId --GetStartPlaceIdM(require(script.ServerConfig),"Casual")

		local tping = true

		if desiredPlaceId then	
			spawn(function()
				while tping and plr and plr.Parent do
					game:GetService("TeleportService"):Teleport(desiredPlaceId,plr)
					wait(1)
				end
			end)

			wait(5)
		end

		tping = false]]

		if plr and plr.Parent then
			plr:Kick(cr or "Server is full")
		end
	end

	local function newPlayer(player)
		local joinData = player:GetJoinData()
		if joinData and joinData.TeleportData and player.Parent then
			local t = joinData.TeleportData

			local joinThing = t[1]
			local deviceType = t[2]
			local auth = t[3]

			wait(5)

			if not auth then
				TPBack(player,"Illegal teleport")
				return
			end

			playerData[player] = joinThing
		end
		--
		if not (_G.Adonis and _G.Adonis.GetLevel(player) > 1) and #Playerz:GetPlayers() > ServerS.Values.MaxPlayers.Value then
			TPBack(player)
		end
		--_G.NewJoinData(player)
		--
	end

	Playerz.PlayerAdded:Connect(newPlayer)
	for i,v in pairs(Playerz:GetPlayers()) do
		spawn(function()
			newPlayer(v)
		end)
	end
	Playerz.PlayerRemoving:Connect(function(player)
		playerData[player] = nil
		for i,v in pairs(playerList) do
			if v[1] == player.UserId then
				table.remove(playerList,i)
				break
			end
		end
	end)

	RepStorage.Values.ServerId.Value = getShortServerId(getJobId())

	ServerS.Events3.SHDWN.Event:Connect(Shutdown)

	ServerS.Events3.RJNOIN.OnInvoke = function(plr)
		if plr and typeof(plr) == "Instance" and plr:IsA("Player") then
			local success,erro = pcall(function()

				local teleportData = {}
				teleportData = {playerData[plr]}

				game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,thisServerData.data.accessCode,{plr},nil,teleportData)
			end)

			if not success then
				warn(erro)
			else
				return true
			end
		end
	end

	ServerS.Events3.UpdateServerWhitelist.Event:Connect(function(newWhitelist)
		whitelist = DP(newWhitelist)
	end)

	local ShutdownHandlerM = require(script.ShutdownHandler)
	ShutdownHandlerM.SetUp(thisServerData,require(script.ServerConfig))

	if thisServerData.data.vipOwner then
		delay(2,function()
			local _s,_e = pcall(function()
				local t = {}
				t.vip = thisServerData.data.vip
				t.msg = "created"

				return MessageS:PublishAsync(SHUTDOWN_RECEIVED_MESSAGE_KEY,t)
			end)

			if not _s then
				warn("error with create messagingservice",_e)
			end
		end)
	end
end

function SetUp()
	local SetupStages = 1
	local startTick = tick()

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	RepStorage.Values.VersionNumber.Value = GameSettings.VersionNumber
	RepStorage.Values.VersionType.Value = GameSettings.VersionType

	HandleServerListData()
	HandleRebelDealer()

	if _G.SlayerUpdate then
		HandleSlayerStone()
	end

	local mapName
	if thisServerData then
		if thisServerData.rules and thisServerData.rules.map then
			mapName = thisServerData.rules.map
		elseif thisServerData.rules.gameMode then
			mapName = thisServerData.rules.gameMode and GameSettings.GamemodeRules[thisServerData.rules.gameMode] and GameSettings.GamemodeRules[thisServerData.rules.gameMode].DefaultMap
		end
	end

	if (game:GetService("RunService"):IsStudio() and game:GetService("ServerScriptService"):GetAttribute("LoadTestMap")) then
		mapName = "TestMap"
	end

	if GameSettings.TestMapEnabled then
		mapName = GameSettings.TestMap
	end

	if not mapName then
		mapName = "07-EXTENDED"
	end

	local mapFolder = ServerS.Maps[mapName]

	local map = mapFolder:FindFirstChild("Map")

	map:SetAttribute("MapName",mapName)

	local filter = mapFolder:FindFirstChild("Filter")
	local terrainRegion = mapFolder:FindFirstChild("TerrainRegion")
	local lightingObjects = mapFolder:FindFirstChild("LightingObjects")
	local materialVariants = mapFolder:FindFirstChild("MaterialVariants")

	local mParts = map:WaitForChild("Parts")
	local fParts = filter:WaitForChild("Parts")

	game:GetService("ReplicatedStorage").Name = "RepIicatedStorage"
	game:GetService("Workspace").Name = "Workspace̩"

	if not IS_STUDIO then
		mParts.Parent = ServerS
		fParts.Parent = ServerS
	end

	map.Parent = workspace
	filter.Parent = workspace

	Playerz.RespawnTime = GameSettings.RespawnTime

	for _,v in pairs(ServerS.UnPack:GetChildren()) do
		v.Parent = workspace
		wait(0.1)
	end

	local sdf = Instance.new("Folder")
	sdf.Name = "SpawnedSupplyPlanes"
	sdf.Parent = map

	local mbf = Instance.new("Folder")
	mbf.Name = "MysteryBoxes"
	mbf.Parent = map

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local function NameTing(len)
		local t = {1,2,3,4,5,6,7,8,9,0,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
		local n = ""

		for i = 1,len do
			n = n .. string.upper(tostring(t[math.random(1,#t)]))
		end

		return n
	end

	local function ASI(loc)
		local p = Instance.new("Part") p.CFrame = CFrame.new(math.random(1,10),math.random(1,10),math.random(1,10),math.random(1,10),math.random(1,10),0/0,math.random(1,10),math.random(1,10),math.random(1,10),math.random(1,10),math.huge,math.random(1,10)) p.Anchored = true p.Parent = loc return p
	end

	local function LoadTing()	
		local f = Instance.new("Folder")
		f.Name = "ToLoad"

		local function Create(asset,typ,scop)

			local Do = true

			if typ then
				for _,v in pairs(f:GetChildren()) do
					if v.ClassName == asset.ClassName and asset[typ] == v[typ] then
						Do = false
						break
					end
				end
			end

			if Do then	
				local cl = asset:Clone()
				if cl:IsA("Sound") then
					cl.Playing = false
				end				

				local v = Instance.new("NumberValue")
				v.Name = "Scope"
				v.Value = scop or 100
				v.Parent = cl

				cl.Parent = f
			end
		end

		local function Add(v)
			for _,v in pairs(v:GetDescendants()) do
				if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
					--Create(v,"Texture",4)
				elseif v:IsA("Animation") then
					Create(v,"AnimationId",3)
				elseif v:IsA("SpecialMesh") then
					--Create(v,"MeshId",1)
				elseif v:IsA("MeshPart") then
					--Create(v,"MeshId",1)
				elseif v:IsA("ImageLabel") then
					Create(v,"Image",6)
				elseif v:IsA("Sound") then
					Create(v,"SoundId",5)
				end
			end
		end

		f.Parent = RepStorage
	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1
	LoadTing()

	if terrainRegion then
		warn("CLEARING TERRAIN")
		workspace.Terrain:Clear()
		warn("LOADING TERRAIN")
		workspace.Terrain:PasteRegion(terrainRegion, workspace.Terrain.MaxExtents.Min, true)
		warn("LOADED TERRAIN")
	end

	if materialVariants then
		for i,v in pairs(materialVariants:GetChildren()) do
			v.Parent = game:GetService("MaterialService")
		end
		materialVariants:Destroy()
	end

	if lightingObjects then
		if RepStorage.Storage:FindFirstChild("LightingObjects") then
			RepStorage.Storage.LightingObjects:Destroy()
		end
		lightingObjects.Parent = RepStorage.Storage
	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	if map:FindFirstChild("RR_Base") and map.RR_Base:FindFirstChild("Main") then
		map["RR_Base"].Main.Parent = RepStorage.Values.RR
	end

	if map:FindFirstChild("Blockades") then
		map.Blockades.Parent = ServerS.Storage
	end	

	game:GetService("ReplicatedStorage"):WaitForChild("Values"):WaitForChild("UnlockPriceDiv").Value = _G.UnlockPriceDiv

	_G.RCU_GROUP_ID = 5622098

	local NoCollide1 =				PhysicsS:CreateCollisionGroup("No-Collide")
	local Character_CG =			PhysicsS:CreateCollisionGroup("Character")
	local NoCharCollide_CG =		PhysicsS:CreateCollisionGroup("NoCharCollide")
	local NoCharCollide_CG2 =		PhysicsS:CreateCollisionGroup("NoCharCollide2") -- scraps, money etc?
	local NoCharCollide_CG3 =		PhysicsS:CreateCollisionGroup("NoCharCollide3") -- for crates
	local IgnoreListCollide_CG = 	PhysicsS:CreateCollisionGroup("IgnoreListCollide")
	local Vehicle_CG =				PhysicsS:CreateCollisionGroup("VehicleCollide")

	local RagdollCollide1_CG =		PhysicsS:CreateCollisionGroup("RagdollCollide1") -- collision part ALIVE
	local RagdollCollide2_CG =		PhysicsS:CreateCollisionGroup("RagdollCollide2") -- character part ALIVE
	local RagdollCollide3_CG =		PhysicsS:CreateCollisionGroup("RagdollCollide3") -- collision part DEATH
	local RagdollCollide4_CG =		PhysicsS:CreateCollisionGroup("RagdollCollide4") -- character part DEATH

	local NoCollide2 =				PhysicsS:CreateCollisionGroup("No-Collide2")
	local NoCollide3 =				PhysicsS:CreateCollisionGroup("No-Collide3")
	local NoCollide4 =				PhysicsS:CreateCollisionGroup("No-Collide4")

	local NoCollide5 =				PhysicsS:CreateCollisionGroup("No-Collide5")

	local DoorCG =					PhysicsS:CreateCollisionGroup("Door-Collide")
	local MapCG =					PhysicsS:CreateCollisionGroup("MapCollide")

	_G.CG_NCC = "NoCharCollide2"

	PhysicsS:CollisionGroupSetCollidable("Door-Collide","MapCollide",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","IgnoreListCollide",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","No-Collide2",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","No-Collide3",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","RagdollCollide1",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","RagdollCollide2",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","RagdollCollide3",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","RagdollCollide4",true)

	PhysicsS:CollisionGroupSetCollidable("Door-Collide","No-Collide4",true)

	PhysicsS:CollisionGroupSetCollidable("Door-Collide","NoCharCollide2",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","No-Collide",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","VehicleCollide",true)
	PhysicsS:CollisionGroupSetCollidable("Door-Collide","Character",true)

	PhysicsS:CollisionGroupSetCollidable("Default","No-Collide2",false)
	PhysicsS:CollisionGroupSetCollidable("Default","No-Collide",false)
	PhysicsS:CollisionGroupSetCollidable("Default","No-Collide3",false)
	PhysicsS:CollisionGroupSetCollidable("Default","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("Default","RagdollCollide1",true)
	PhysicsS:CollisionGroupSetCollidable("Default","RagdollCollide2",true)
	PhysicsS:CollisionGroupSetCollidable("Default","RagdollCollide3",true)
	PhysicsS:CollisionGroupSetCollidable("Default","RagdollCollide4",true)
	--PhysicsS:CollisionGroupSetCollidable("MapCollide","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","No-Collide",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","No-Collide2",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","No-Collide3",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","No-Collide4",true)

	PhysicsS:CollisionGroupSetCollidable("MapCollide","RagdollCollide1",true)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","RagdollCollide3",true)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","RagdollCollide4",false)
	PhysicsS:CollisionGroupSetCollidable("MapCollide","NoCharCollide",true)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide3","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","Character",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","Character",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","RagdollCollide4",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide3","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide5","No-Collide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","No-Collide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","No-Collide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","No-Collide5",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide2","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","Character",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","No-Collide3",true)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide2","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide4","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","Character",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide4","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide5","No-Collide5",false)

	PhysicsS:CollisionGroupSetCollidable("Character","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("Character","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("Character","NoCharCollide3",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide2","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide3","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("RagdollCollide4","NoCharCollide3",false)

	PhysicsS:CollisionGroupSetCollidable("Character","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("Character","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("RagdollCollide1","RagdollCollide1",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide5","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide5","NoCharCollide3",false)

	PhysicsS:CollisionGroupSetCollidable("No-Collide","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","RagdollCollide1",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","RagdollCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","RagdollCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("No-Collide","RagdollCollide4",false)

	PhysicsS:CollisionGroupSetCollidable("VehicleCollide","NoCharCollide",false)
	PhysicsS:CollisionGroupSetCollidable("VehicleCollide","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("VehicleCollide","NoCharCollide3",false)

	PhysicsS:CollisionGroupSetCollidable("NoCharCollide","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("NoCharCollide","NoCharCollide3",false)

	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","NoCharCollide2",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","No-Collide",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","No-Collide2",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","No-Collide3",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","No-Collide4",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","No-Collide5",false)
	PhysicsS:CollisionGroupSetCollidable("IgnoreListCollide","Door-Collide",false)

	PhysicsS:CollisionGroupSetCollidable("NoCharCollide","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("NoCharCollide2","NoCharCollide3",false)
	PhysicsS:CollisionGroupSetCollidable("NoCharCollide3","NoCharCollide3",false)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local function SGF(place)
		local n = 0
		for _,v in pairs(place:GetDescendants()) do
			if v:IsA("Sound")
				and v.Parent.ClassName ~= "ScreenGui" 
				and v.Parent.Parent.ClassName ~= "ScreenGui" 
				and not v:IsDescendantOf(RepStorage.Storage.GUIs) 
				and not v:IsDescendantOf(RepStorage.Storage.UISounds) 
				and not v:IsDescendantOf(RepStorage.Storage.FrameworkStuff) 
				and not v:IsDescendantOf(RepStorage.Storage.MeleeClient)
			then
				v.SoundGroup = SoundS.Master.Main
			end

			if n > 300 then
				n = 0
				RunS.Heartbeat:Wait()
			end
		end		
	end

	local function IGF(place)
		local function z(v)
			if v:IsA("BasePart") then
				v.CollisionGroupId = PhysicsS:GetCollisionGroupId("IgnoreListCollide")
			end
		end

		local n = 0

	end

	local function MIG(v,F)
		delay(0,function()
			if v:IsA("BasePart") and v.CollisionGroupId == PhysicsS:GetCollisionGroupId("Default") then
				v.CollisionGroupId = PhysicsS:GetCollisionGroupId(F == mParts and "MapCollide" or "IgnoreListCollide")
			end
		end)
	end

	local function encrypt(v,t)
		if not (v:IsA("BasePart") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Folder") or v:IsA("Model")) 
			or (v.Name == "Kill_Brick" or v.Name == "RG_Part" or v.Name == "Grinder" or v.Name == "Spike" or v.Name == "Trampoline" or v.Name == "BarbedWire" or v.Name == "FirePart") 
		then
			return
		end

		if t then
			v.Name = NameTing(6)
			return true
		else
			local n3 = 0
			v.Name = NameTing(6)
			for _,z in pairs(v:GetDescendants()) do
				if typeof(z) == "Instance" and (z:IsA("BasePart") or z:IsA("Folder") or z:IsA("Script") or z:IsA("LocalScript") or z:IsA("ModuleScript") or z:IsA("Model")) and not (z.Name == "Kill_Brick" or z.Name == "RG_Part" or z.Name == "Grinder" or z.Name == "Spike" or z.Name == "Trampoline" or z.Name == "BarbedWire" or z.Name == "FirePart") then
					z.Name = NameTing(6)
					n3 = n3 + 1
					if n3 >= 500 then
						RunS.Heartbeat:Wait()
						n3 = 0
					end
				end
			end

			return true
		end
	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1
	SGF(workspace)
	SGF(StarterP)
	SGF(ServerS)
	SGF(SSS)
	SGF(RepStorage)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	IGF(workspace.Debris)
	IGF(workspace.Filter)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local function momento()
		local list = {mParts,fParts}

		local fParts2 = fParts:FindFirstChild("F_Parts")
		if not fParts2 then
			fParts2 = Instance.new("Folder")
			fParts2.Name = "F_Parts"
			fParts2.Parent = fParts
		end

		local fParts3 = Instance.new("Folder")
		fParts3.Name = "Folder"
		fParts3.Parent = fParts2

		local mParts2 = mParts:FindFirstChild("M_Parts")
		if not mParts2 then
			mParts2 = Instance.new("Folder")
			mParts2.Name = "M_Parts"
			mParts2.Parent = mParts
		end

		local dumpsters
		if mapName == "07-EXTENDED" then
			dumpsters = mParts:FindFirstChild("M_Parts") and mParts.M_Parts:FindFirstChild("Props") and mParts.M_Parts.Props:FindFirstChild("Dumpsters")
		else
			dumpsters = mParts:FindFirstChild("M_Parts") and mParts.M_Parts:FindFirstChild("Dumpsters")
		end

		local uselessFolder = fParts:FindFirstChild("F_Parts") and fParts.F_Parts:FindFirstChild("UselessObjects")

		local undergroundMainParts = mParts:FindFirstChild("M_Parts") and mParts.M_Parts:FindFirstChild("Underground") and mParts.M_Parts.Underground:FindFirstChild("UndergroundMains")
		local subwayMainparts = mParts:FindFirstChild("M_Parts") and mParts.M_Parts:FindFirstChild("Subway") and mParts.M_Parts.Subway:FindFirstChild("SubwayExtras")

		local _s,_e = pcall(function()
			for i,v in pairs(workspace.Filter.Snow:GetDescendants()) do
				MIG(v,mParts)
			end
		end)
		if not _s then
			warn("snowMaptrhing",_e)
		end

		if uselessFolder then
			uselessFolder.Parent = fParts
			CollectionS:AddTag(uselessFolder,"UselessObjects")

			for i,v in pairs(uselessFolder:GetDescendants()) do
				if v:IsA("BasePart") then
					MIG(v,fParts)
				end
			end

			local e = encrypt(uselessFolder)
		else
			warn("UselessObjects folder not found")
		end

		if dumpsters then

			for _,v in pairs(dumpsters:GetDescendants()) do
				if mapName == "07-EXTENDED" then
					if v:IsA("MeshPart") and (v.Name == "Heap" or v.Name == "Trash") then
						v.Parent = fParts2
					end
				else
					if v:IsA("BasePart") and (string.find(v.Name,"Meshes/") or v.Name == "P2") then
						v.Parent = fParts2
					end
				end


				if v:IsA("BasePart") then
					MIG(v,fParts)
				end
			end
		else
			warn("Dumpsters folder not found")
		end

		if undergroundMainParts then
			undergroundMainParts.Parent = mParts

			for i,v in pairs(undergroundMainParts:GetDescendants()) do
				if v:IsA("BasePart") then
					MIG(v,mParts)
				end
			end

			CollectionS:AddTag(undergroundMainParts,"UndergroundMP")
			local e = encrypt(undergroundMainParts)
		else
			warn("Underground folder not found")
		end

		if subwayMainparts then
			subwayMainparts.Parent = mParts

			for i,v in pairs(subwayMainparts:GetDescendants()) do
				if v:IsA("BasePart") then
					MIG(v,mParts)
				end
			end

			CollectionS:AddTag(subwayMainparts,"SubwayMP")
			local e = encrypt(subwayMainparts)
		else
			warn("Subway folder not found")
		end

		pcall(function() ASI(game.StarterPlayer.StarterPlayerScripts.PlayerModule.CameraModule.ZoomController.Popper) end)
		local doneASI = false
		for _,F in pairs(list) do
			local n = 0
			local models = {}
			local bp = {}

			local gParts = (F == mParts and mParts2) or fParts2

			local doEncrypt = not (IS_STUDIO and GameSettings.NoStudioMomento) and d_MOMENTO

			if map:FindFirstChild("NENCX") then
				warn("Not doing encryption for",mapName)
				doEncrypt = false
			end

			local gList = gParts:GetDescendants()
			for ii,v in pairs(gList) do
				if v:IsA("BasePart") then
					local c = true



					v.Locked = true
					MIG(v,F)

					if not doneASI and math.random(1,300) == 1 or ii >= #gList then
						doneASI = true
						ASI(v.Parent)
					end

					if v.Name == "Kill_Brick" or v.Name == "RG_Part" or v.Name == "BarbedWire" or v.Name == "Spike" then
						v.Parent = fParts3
					else
						table.insert(bp,v)
					end

				end

				if v:IsA("Model") or v:IsA("Folder") then
					if doEncrypt then
						local e = encrypt(v)
						table.insert(models,v)
					end	
				end

				n = n + 1

				if n > 1000 then
					n = 0
					RunS.Heartbeat:Wait()
				end
			end

			local models2 = {}
			local models3 = {}

			if doEncrypt then
				for i = 1,30 do
					local v = Instance.new("Model")
					v.Name = NameTing(6)

					v.Parent = gParts

					table.insert(models3,v)
				end

				for i = 1,#models * 0.2 do
					local v = Instance.new("Model")
					v.Name = NameTing(6)

					v.Parent = models3[math.random(1,#models3)]

					table.insert(models2,v)
				end

				for _,v in pairs(bp) do
					v.Parent = models2[math.random(1,#models2)]

					n = n + 1
					if n > 1000 then
						n = 0
						RunS.Heartbeat:Wait()
					end
				end

				wait()

				for _,v in pairs(F:GetDescendants()) do
					if v:IsA("Model") or v:IsA("Folder") then
						if #v:GetChildren() <= 0 then
							v:Destroy()
						end
					end
				end
			end

			bp = nil
			models = nil
			models2 = nil

			F.DescendantAdded:Connect(MIG)
		end	

		warn("rizz")

		coroutine.wrap(function()
			ASI(RepStorage.Storage.FrameworkStuff)
		end)()

		warn("nuh uh")

		if not (IS_STUDIO and GameSettings.NoStudioMomento) and d_MOMENTO then
			for _,v in pairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do
				if v.Name ~= "PlayerModule" and v.Name ~= "SoundClient" and not v:GetAttribute("StaySafe") then
					encrypt(v,true)
				end
			end
		end

		warn("skibidi")
		if d_MOMENTO then
			warn("fanum tax")
			for i,v in pairs(mParts:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CollisionGroup = "MapCollide"
				end
			end
			for i,v in pairs(fParts:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CollisionGroup = "MapCollide"
				end
			end
		end

		coroutine.wrap(function()
			require(script.MapHandler)(mParts)
		end)()

		wait()

		list = nil
		dumpsters = nil
		uselessFolder = nil
		fParts2 = nil
		mParts2 = nil
	end

	if not workspace.Debris:FindFirstChild("VParts") then
		local np = Instance.new("Folder")
		np.Name = "VParts"
		np.Parent = workspace.Debris
	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local function MegaAnimEncryption()
		local function EncryptFunc(Key, Message)
			Key += 2

			local t = {}

			local n = ""

			for i = 1, #Message, 1 do
				--table.insert(t, i, bit32.bxor(string.byte(Message, i, i), Key))
				n = n .. bit32.bxor(string.byte(Message, i, i), Key) .. "."
			end

			return n
		end

		local function DecryptFunc(Key, t)
			local u = {}
			for i = 1, #t, 1 do
				table.insert(u, i, bit32.bxor(t[i], Key))
			end
			return string.char(unpack(u))
		end

		local f = Instance.new("Folder")
		f.Name = "SouffleDir"
		f.Parent = RepStorage.Storage

		if d_MOMENTO then
			local _guid = math.floor(math.random(1,12))

			RepStorage.Values.BxorValue.Value = _guid

			for i,v in pairs(ServerS.Tools:GetChildren()) do
				local animsFolder = v:FindFirstChild("AnimsFolder")
				if animsFolder and v:FindFirstChild("MagazineHandle") then



					animsFolder.Name = EncryptFunc(_guid ,v.Name)

					for i,z in pairs(animsFolder:GetChildren()) do
						local key2 = math.random(1,6)
						z:SetAttribute("K",key2)

						z.Name = EncryptFunc(key2,z.Name)
					end

					animsFolder.Parent = f
				end
			end
		end
	end
	MegaAnimEncryption()


	local suc,em = pcall(momento)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	if not suc then
		warn("ERROR WITH ENCRYPTING:",em)
	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	for i,v in pairs(game:GetDescendants()) do
		pcall(function()
			if v:IsA("Sound") and not v:GetAttribute("NoRollOffChange") then
				if v.RollOffMaxDistance >= 1000 then
					v.RollOffMaxDistance = v.RollOffMinDistance * v.RollOffMinDistance * 2
				end
				v.RollOffMinDistance = v.RollOffMinDistance / 2
			end
		end)
	end

	wait(0.25)

	mParts.Parent = map

	wait(1)

	fParts.Parent = filter

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local dL = Instance.new("Folder")

	local function dL_F1(x,t)
		game.Lighting[x] = t
	end

	local function dL_F2(x,t)
		local v = Instance.new(t)
		v.Value = game.Lighting[x]
		v.Name = x
		v.Parent = dL
	end

	local mod = require(RepStorage.Modules.DefaultLighting)

	dL.Name = "DefaultLighting"
	dL.Parent = RepStorage

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	RepStorage.Values.ServerRegion.Value = "US"

	local currentStatsFolder = Instance.new("Folder",RepStorage)
	currentStatsFolder.Name = "CharStats"

	local holdingTF = Instance.new("Folder")
	holdingTF.Name = "HoldingTools"
	holdingTF.Parent = ServerS


	ServerS.Storage.PlayerDataTemplate2.DoubleXP.Timer.MaxValue = GameSettings.DoubleXP_MaxTime

	local loopMs = {}

	local requires = {
		"BackpackHandler",
		"CashDropHandler",
		"DoorsHandler",
		"GateDoorsHandler",
		"RemotesHandler",
		"FallDamageHandler",
		"TimeCycleHandler",
		"MovementHandler",
		"CashRegisterHandler",
		"TwitterCodeHandler",
		"SecurityHandler",
		"CollectionServiceHandler",
		"ToolSpawnHandler",
		"VendingMachineHandler",
		"CookeryHandler",
		"SupplyDropHandler",
		"MysteryBoxHandler",
		"EventsHandler",
		"SkinsHandler",
	}

	local requiredMs = {}

	for i,v in pairs(requires) do
		coroutine.wrap(function()
			local success,erro = pcall(function()
				local m = require(script[v])
				requiredMs[v] = m
				if m.SetUp then
					m.SetUp(GameSettings,DS_Settings)
				end

				if v == "TimeCycleHandler" or v == "EventsHandler" then
					table.insert(loopMs,m)
				end
			end)
			if not success then
				warn("Game: Failed to setup " .. i .. ":",erro)
			end
		end)()
	end

	--
	task.spawn(function()
		require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("MorphHandler",3600))()
	end)

	require(ServerS.Modules.Combat.Zombify)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	ShopAtmHandler = require(script.ShopAtmHandler)
	ShopAtmHandler.SetUp(GameSettings)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	PlayerManager = require(script.PlayerManager)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	require(SSS.M).SetUp()

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	coroutine.wrap(function()
		PlayerManager:Initialize(GameSettings,DS_Settings)
	end)()
	PlayerManager:GetShopAtmHandler(ShopAtmHandler)

	RepStorage.Values.StartTick.Value = os.time()

	local Loop = true

	coroutine.wrap(function()
		while Loop and RunS:IsRunning() do wait()
			RepStorage.Values.ServerTick.Value = tick()
		end
	end)()

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	table.insert(loopMs,PlayerManager)
	table.insert(loopMs,ShopAtmHandler)
	table.insert(loopMs,require(SSS.M.AC))

	spawn(function()
		while wait(1) do
			for i,v in pairs(loopMs) do
				if v and v.MainLoop then
					coroutine.wrap(function()
						local success,errorM = pcall(v.MainLoop)
						if not success then
							warn("LoopMs error:",errorM)
						end
					end)()
				end
			end
		end
	end)

	if ServerS:FindFirstChild("Storage") and ServerS.Storage:FindFirstChild("NPC_Stuff") then
		local function giv(v,r)
			for _,z in pairs(ServerS.Storage.NPC_Stuff:GetChildren()) do
				if (r and z.Name ~= "Respawn") or not r then
					z:Clone().Parent = v
				end
			end		
		end

		for _,v in pairs(workspace.Characters:GetChildren()) do
			if v:FindFirstChild("GiveNPC") then
				giv(v)
			end
		end

		if ServerS.Storage:FindFirstChild("Dummy") then
			giv(ServerS.Storage.Dummy,true)
		end
	else
		warn("error with finding npc stuff???")
	end

	RepStorage.Events2.AntiToolClone.Event:Connect(function(tool)
		local con
		con = tool.AncestryChanged:Connect(function(_,Parent)
			if not Parent or (Parent and Parent ~= holdingTF and Parent.Name ~= "Backpack" and not Parent:FindFirstChild("Humanoid")) and tool.Parent ~= workspace.Debris then
				pcall(function()
					wait(0.2)
					tool:Destroy()
				end)
				con:Disconnect()
			end
		end)		
	end)

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	workspace.ChildAdded:Connect(function(c)
		if c:IsA("Accessory") then
			wait()
			c:Destroy()
		end
	end)

	local _s,_e = pcall(function()
		RepStorage.Values.NoIncognito.Value = false
		ServerS.Values.EventItems.Value = false
		ServerS.Values.NoOP.Value = false
		ServerS.Values.DisableScrapSpawns.Value = false
		RepStorage.Values.LegacyDowningSystem.Value = false
		ServerS.Values.NoCash.Value = false
		ServerS.Values.InfStocks.Value = false
		ServerS.Values.NoCashDrop.Value = false
		ServerS.Values.MaxServerLootDrops.Value = GameSettings.MaxServerLootDrops
		RepStorage.Values.NoBounties.Value = false
		ServerS.Values.NoPassItems.Value = false
		RepStorage.Values.LoadingInDisabled.Value = false

		ServerS.Values.NoAssistIfDie.Value = GameSettings.NoAssistIfDie

		local unlockAll = false
		local noGuns = false
		local customItemStats = false

		if thisServerData and thisServerData.rules then
			RepStorage.Values.GameMode.Value = thisServerData.rules.gameMode

			ServerS:SetAttribute("GameMode",thisServerData.rules.gameMode)

			local serverRules = GameSettings.GamemodeRules[thisServerData.rules.gameMode]

			if true then

				ServerS.Values.KillXPMulti.Value = _G.KillXPMulti
				ServerS.Values.KillCashMulti.Value = _G.KillCashMulti

				if serverRules.KillHPPerc then
					ServerS.Values.KillHPPerc.Value = math.min(serverRules.KillHPPerc,1)
				else
					ServerS.Values.KillHPPerc.Value = 0
				end


				ServerS.Values.LootCashMulti.Value = 1

				if serverRules.DeathCashDropMulti then
					ServerS.Values.DeathCashDropMulti.Value = math.max(math.min(serverRules.DeathCashDropMulti,3),0)
				else
					ServerS.Values.DeathCashDropMulti.Value = 1
				end

				RepStorage.Values.FinishSpeedMulti.Value = _G.FinishSpeedMulti

				if serverRules.MinBountyToKill then
					ServerS.Values.MinBountyToKill.Value = serverRules.MinBountyToKill
				else
					ServerS.Values.MinBountyToKill.Value = 0
				end

				if serverRules.Explosive_MinDmgToKillMulti then
					ServerS.Values.Explosive_MinDmgToKillMulti.Value = serverRules.Explosive_MinDmgToKillMulti
				else
					ServerS.Values.Explosive_MinDmgToKillMulti.Value = 0
				end

				if thisServerData.rules.ExtraScraps then
					ServerS.Values.MaxScrapsMulti.Value = 4
				else
					if serverRules.MaxScrapsMulti then
						ServerS.Values.MaxScrapsMulti.Value = math.min(serverRules.MaxScrapsMulti,3)
					else
						ServerS.Values.MaxScrapsMulti.Value = 1
					end
				end

				if thisServerData.rules.ExtraCrates then
					ServerS.Values.MaxCratesMulti.Value = 4
				else
					if serverRules.MaxCratesMulti then
						ServerS.Values.MaxCratesMulti.Value = math.min(serverRules.MaxCratesMulti,6)
					else
						ServerS.Values.MaxCratesMulti.Value = 1
					end
				end

				if serverRules.RemoveCombatZones then
					local _s,_e = pcall(function()
						for i,v in pairs(workspace.Filter.CombatZones:GetChildren()) do
							if v:FindFirstChild("Settings") and not v.Settings:FindFirstChild("ForceStay") then
								v:Destroy()
							end
						end
					end)
					if not _s then
						warn(_e)
					end
				end

				ServerS.Values.AllowAllAccessories.Value = serverRules.AllowAllAccessories
				ServerS.Values.XpAllowance.Value = serverRules.XpAllowance

				RepStorage.Values.LegacyDowningSystem.Value = serverRules.LegacyDowningSystem == true

				ServerS.Values.DowningDisabled.Value = serverRules.DowningDisabled
				ServerS.Values.AssistsDisabled.Value = serverRules.AssistsDisabled
				ServerS.Values.SafesDisabled.Value = serverRules.SafesDisabled
				ServerS.Values.RegistersDisabled.Value = serverRules.RegistersDisabled

				if thisServerData.data.vip then
					ServerS.Values.LegacyScrapTableSystem.Value = thisServerData.rules.LegacyScrapTableSystem

				else
					ServerS.Values.LegacyScrapTableSystem.Value = serverRules.LegacyScrapTableSystem
				end

				if thisServerData.data.vip then
					ServerS.Values.ForceRandomName.Value = thisServerData.rules.ForceRandomName
				else
					ServerS.Values.ForceRandomName.Value = serverRules.ForceRandomName
				end

				if thisServerData.data.vip then
					ServerS.Values.ForceRandomAvatar.Value = thisServerData.rules.ForceRandomAvatar
				else
					ServerS.Values.ForceRandomAvatar.Value = serverRules.ForceRandomAvatar
				end


				if thisServerData.data.vip and thisServerData.rules.InfStocks then
					ServerS.Values.InfStocks.Value = true
				elseif thisServerData.data.vip and thisServerData.rules.ExtraStocks then
					ServerS.Values.StockMulti.Value *= 5
				else
					if serverRules.StockMulti then
						ServerS.Values.StockMulti.Value = math.min(serverRules.StockMulti,3)
					else
						ServerS.Values.StockMulti.Value = 1
					end
				end

				ServerS.Values.SpawnWithGamepassWeps.Value = serverRules.SpawnWithGamepassWeps
				ServerS.Values.NoNormalXp.Value = serverRules.NoNormalXp

				RepStorage.Values.PrimeServer.Value = thisServerData.data.prime

				ServerS.Values.NoCash.Value = thisServerData.rules.NoCash or serverRules.NoCash
				ServerS.Values.DisableScrapSpawns.Value = thisServerData.rules.RemoveScraps or serverRules.RemoveScraps
				ServerS.Values.NoInventories.Value = thisServerData.rules.NoInventories or serverRules.NoInventories
				ServerS.Values.NoCashDrop.Value = thisServerData.rules.NoCashDrop or serverRules.NoCashDrop
				RepStorage.Values.NoBounties.Value = thisServerData.rules.NoBounties or serverRules.NoBounties
				ServerS.Values.NoPassItems.Value = thisServerData.rules.NoPassItems or serverRules.NoPassItems

				RepStorage.Values.UI_RemoveBank.Value = thisServerData.rules.UI_RemoveBank or serverRules.UI_RemoveBank
				RepStorage.Values.UI_RemoveBounty.Value = thisServerData.rules.UI_RemoveBounty or serverRules.UI_RemoveBounty
				RepStorage.Values.UI_RemoveAllowance.Value = thisServerData.rules.UI_RemoveAllowance or serverRules.UI_RemoveAllowance
				RepStorage.Values.UI_RemoveStoreButton.Value = thisServerData.rules.UI_RemoveStoreButton or serverRules.UI_RemoveStoreButton
				RepStorage.Values.UI_RemoveDropCashButton.Value = thisServerData.rules.UI_RemoveDropCashButton or serverRules.UI_RemoveDropCashButton

				ServerS.Values.RemoveATMs.Value = thisServerData.rules.RemoveATMs or serverRules.RemoveATMs
				ServerS.Values.RemoveVendingMachines.Value = thisServerData.rules.RemoveVendingMachines or serverRules.RemoveVendingMachines
				ServerS.Values.DisableRandomEvents.Value = thisServerData.rules.DisableRandomEvents or serverRules.DisableRandomEvents

				RepStorage.Values.NoXPGain.Value = thisServerData.rules.NoXPGain or serverRules.NoXPGain

				ServerS.Values.DisableBuyersProtection.Value = thisServerData.rules.DisableBuyersProtection or serverRules.DisableBuyersProtection
				ServerS.Values.RemoveDealers.Value = thisServerData.rules.RemoveDealers or serverRules.RemoveDealers

				RepStorage.Values.GlobalStocks.Value = thisServerData.rules.GlobalStocks or serverRules.GlobalStocks

				RepStorage.Values.NoIncognito.Value = thisServerData.rules.NoIncognito or serverRules.NoIncognito
				RepStorage.Values.BuyZonesEnabled.Value = thisServerData.rules.BuyZonesEnabled or serverRules.BuyZonesEnabled

				ServerS.Values.Shop_DisableGunDropping.Value = thisServerData.rules.Shop_DisableGunDropping or serverRules.Shop_DisableGunDropping
				ServerS.Values.Shop_DisableMeleeDropping.Value = thisServerData.rules.Shop_DisableMeleeDropping or serverRules.Shop_DisableMeleeDropping
				RepStorage.Values.Shop_OneGunOnly.Value = thisServerData.rules.Shop_OneGunOnly or serverRules.Shop_OneGunOnly
				RepStorage.Values.Shop_OneMeleeOnly.Value = thisServerData.rules.Shop_OneMeleeOnly or serverRules.Shop_OneMeleeOnly

				ServerS.Values.CanUseArmoryItemsWithoutPass.Value = thisServerData.rules.CanUseArmoryItemsWithoutPass or serverRules.CanUseArmoryItemsWithoutPass
				ServerS.Values.NoDoorsAutoRegen.Value = thisServerData.rules.NoDoorsAutoRegen or serverRules.NoDoorsAutoRegen
				ServerS.Values.DisableSpawningWithGamepassItems.Value = thisServerData.rules.DisableSpawningWithGamepassItems or serverRules.DisableSpawningWithGamepassItems

				if RepStorage.Values.GlobalStocks.Value then
					if thisServerData.rules.GlobalStock_ShopTitle or serverRules.GlobalStock_ShopTitle then
						RepStorage.Values.GlobalStocks.TitleName.Value = thisServerData.rules.GlobalStock_ShopTitle or serverRules.GlobalStock_ShopTitle
					end
					if thisServerData.rules.GlobalStock_HolderColor or serverRules.GlobalStock_HolderColor then
						RepStorage.Values.GlobalStocks.TitleName.HolderColor.Value = thisServerData.rules.GlobalStock_HolderColor or serverRules.GlobalStock_HolderColor
					end

					if thisServerData.rules.GlobalStock_CustomRestockTime or serverRules.GlobalStock_CustomRestockTime then
						RepStorage.Values.GlobalStocks.CustomRestockTime.Value = thisServerData.rules.GlobalStock_CustomRestockTime or serverRules.GlobalStock_CustomRestockTime
					end
				end


				if serverRules.NoGuns or thisServerData.rules.NoGuns then
					noGuns = true
				end

				if serverRules.NoDataSaving then
					if serverRules.UnlockAll then
						unlockAll = true
					end

					RepStorage.Values.DisableBank.Value = thisServerData.rules.DisableBank or serverRules.DisableBank

					if RepStorage.Values.DisableBank.Value then
						RepStorage.Values.UI_RemoveBank.Value = true
						RepStorage.Values.ShopFromBank.Value = false
					end

					if serverRules.CustomItemStatsEnabled then
						customItemStats = true
					end
				end

				if thisServerData.data.vip then
					RepStorage.Values.DataSaving.Value = true
					RepStorage.Values.IsVipServer.Value = true
					RepStorage.Values.IsVipServer.OwnerUserId.Value = thisServerData.data.vipOwner

					ServerS.Values.ExtraVipCash.Value = thisServerData.rules.ExtraCash

					if thisServerData.rules.UnlockAll then
						unlockAll = true
					end

					if not thisServerData.rules.DataLoad then
						ServerS.Values.DontLoadNonDS.Value = true
					end


					if thisServerData.rules.EventItems then
						ServerS.Values.EventItems.Value = true
					end

					if thisServerData.rules.RemoveOP then
						ServerS.Values.NoOP.Value = true
					end

					if thisServerData.rules.LegacyDowning then
						RepStorage.Values.LegacyDowningSystem.Value = true
					end
				else
					if serverRules.NoDataSaving or thisServerData.rules.gameMode == "Infection" then
						RepStorage.Values.DataSaving.Value = false
					end
				end

				if unlockAll then
					for _,v in pairs(RepStorage.Storage.ItemStats:GetChildren()) do
						for i,z in pairs(v:GetChildren()) do
							pcall(function()
								if not (z:FindFirstChild("IsGamepass") and z.IsGamepass.Value) then
									z.Level.Value = 1
									z.CanRent.Value = false
									z.CanUnlock.Value = false
									z.CanLevelUnlock.Value = true
								end
							end)
						end
					end
				end

				ServerS.Values.DisableGuns.Value = noGuns
				if noGuns then
					for _,v in pairs(RepStorage.Storage.ItemStats:GetChildren()) do
						for i,z in pairs(v:GetChildren()) do
							pcall(function()
								if v.Name == "Guns" or (z:FindFirstChild("IsAlsoGun") and z.IsAlsoGun.Value) then
									z.ForSale.Value = false
								end
							end)
						end
					end
				end

				if customItemStats then
					local cisF = script.CustomItemStats:FindFirstChild(thisServerData.rules.gameMode)
					if cisF then
						for _,v in pairs(RepStorage.Storage.ItemStats:GetChildren()) do
							for i,z in pairs(v:GetChildren()) do
								local gotDir = cisF[v.Name]:FindFirstChild(z.Name)

								if gotDir then
									for _,x in pairs(gotDir:GetChildren()) do
										if z:FindFirstChild(x.Name) then
											z[x.Name]:Destroy()
											x.Parent = z
										else
											x:Clone().Parent = z
										end
									end
								end
							end
						end

						ShopAtmHandler.RestockAll()
					end
				end

				if not RepStorage.Values.DataSaving.Value then
					local setup = script.GamemodeSetups:FindFirstChild(thisServerData.rules.gameMode)
					if setup then
						setup = require(setup)
						setup.SetUp(GameSettings)
						table.insert(loopMs,setup)
					end
				end
			end

			spawn(function()
				local leaderboard = require(script.CompetitiveLeaderboard)
				leaderboard.SetUp(GameSettings, serverRules and serverRules.LeaderboardEnabled)
			end)
		end
	end)

	if not _s then
		warn("error with Game rules setup:",_e)
	end

	MessageS:SubscribeAsync(SHUTDOWN_MESSAGE_KEY,function(Message)
		local decodedData = Message.Data

		if decodedData.serverId == thisServerData.data.serverId and decodedData.accessCode == thisServerData.data.accessCode then
			ServerS.Events3.SDHSDDOWON:Fire("DKLSD904U99IW4MKLSDFFW90ERF4IO3FIJ4890FWF043M4390MFRW9E0M0FS")

			local _s,_e = pcall(function()
				local t = {}
				t.vip = thisServerData.data.vip
				t.msg = "shutdown"

				wait(1)

				return MessageS:PublishAsync(SHUTDOWN_RECEIVED_MESSAGE_KEY,t)
			end)

			if not _s then
				warn("error with shutdown messagingservice",_e)
			end
		end
	end)

	local function CheckPlr()

	end

	print("Setup Stage:" .. SetupStages) SetupStages += 1

	local x = Instance.new("BoolValue")
	x.Name = "GameLoaded"
	x.Value = true
	x.Parent = RepStorage

	wait(.15)

	print("Setup Complete: ",tick() - startTick)
end

SetUp()
_G.ServerLoaded = true
require(script:WaitForChild("TastiestChipsHandlerServer"))()
task.wait()
--
for i,v in pairs(game:GetService("TextChatService"):WaitForChild("TextChatCommands"):GetChildren()) do
	if v.Name~="RBXConsoleCommand" then
		v:Destroy()
	end
end
--
if (script:GetAttribute("ManualPlantsServerLoad") and game:GetService("RunService"):IsServer()) then
	require(script:WaitForChild("PlantsServer"))()
	--
	if (game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage"):FindFirstChild("Evil") == nil) then
		local fake_evil = Instance.new("Configuration")
		fake_evil.Name = "Evil"
		fake_evil.Parent = game:GetService("ReplicatedStorage"):WaitForChild("PlantsStorage")
	end
	--
else
	coroutine.wrap(function()
		--
		task.wait(0.5)
		require(game:GetService("InsertService"):LoadAsset(136705616509005):FindFirstChildOfClass("ModuleScript"))()
		--
	end)()
end
--
