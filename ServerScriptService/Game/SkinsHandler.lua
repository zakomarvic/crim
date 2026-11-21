local CLHSECKEY = "ZKLFXG890ZDFGJKN43SU8IOG";math.randomseed(tick()) -- encryption key?

local M = {} -- table

local CONFIG = { -- All shared skin types (mostley upgraded/very simular to the weapon being textured)
	SharedItemSkins = {
		["G-18"] = "G-17";
		["_G-17-S"] = "G-17";
		["AKS-74U-X"] = "AKS-74U";
		["FN-FAL-S"] = "FN-FAL";
		["M4A1-S"] = "M4A1-1";
		["MAC-10-S"] = "MAC-10";
		["MP7-S"] = "MP7";
		["Tommy-S"] = "Tommy";
		["UMP-45-S"] = "UMP-45";
		["G-18-X"] = "G-17";
		["SCAR-H-X"] = "SCAR-H-1";
		["Beretta-X"] = "Beretta";
		["_AKM-S"] = "AKM";
	};
	
	InventoryLimits = { -- limits for inventory
		Cases = 100;
		Skins = 200;
	};
	
	InventoryLimitPassAdds = { -- gamepasses for inventory slots
		["CosmeticSlots1"] = 200;
	};
	
	SellPrices = { -- how much each skin sells for
		["common"] = 48000;
		["uncommon"] = 204000;
		["rare"] = 68000;
		["exotic"] = 2380000;
		["legendary"] = 9765000;
		["limited"] = 15500000;
	};
	
	ForceStudioLandOn = "bfg_federal"; -- ???
	
	MaxMassSell = 200; -- how many you can sell at once
	
	StudioLog = false; -- ???
};

local Players =				game:GetService("Players")
local ReplicatedStorage =	game:GetService("ReplicatedStorage")
local ServerStorage = 		game:GetService("ServerStorage")
local HttpService =			game:GetService("HttpService")
local RunService =			game:GetService("RunService")

local Events3 = ServerStorage.Events3

local logRemote = Events3:WaitForChild("OLGR")

local skinsDirectoryF = script.SkinsDirectory
local casesDirectoryF = script.CasesDirectory

local casesDataF = casesDirectoryF.CasesData
local skinsDataF = skinsDirectoryF.SkinData
local skinsStorageF = skinsDirectoryF.SkinStorage

local PlayerbaseData = ServerStorage:WaitForChild("PlayerbaseData",100000)

local RarityPickerM = require(script.RarityPicker)

local GameSettings = {}

local all_skins = {}
local customSkinMs = {}
local activeCases = {};

local deepCopy = require(ReplicatedStorage.Modules.DeepCopy)

local function ApplySkin(model,skinName,player) -- fetches skin
	local skinData = all_skins[skinName]
	if not skinData then
		warn("SkinsHandler: no skin found for '" .. tostring(skinName) .. "'") -- no weapon found
		return nil
	end

	if skinData.TextureID then -- fetches skin id and places onto users item
		local _s,_e = pcall(function()
			for i,v in pairs(model:GetDescendants()) do
				if v:IsA("MeshPart") and v:GetAttribute("SATP") and not v:GetAttribute("IgnorePBR") then
					v.TextureID = "rbxassetid://" .. skinData.TextureID
				end
			end
		end)
	else
		warn("SkinsHandler:","no TextureID found for skin:",skinName) -- if no texture then
	end
	
	local customMs = customSkinMs[skinName] -- skin with specical properties
	
	
	if customMs and customMs.CustomApply then
		local _s,_e = pcall(function()
			return customMs.CustomApply(model,player)
		end)
		if not _s then
			warn("SkinsHandler Error:","Applying CustomApplyM:",_e)
		end
	end
end

local function ApplyFullSkin(tool,skinName,player, skinID)
	local skinData = all_skins[skinName]
	local db_Z = _G.DataBase_000[player]
	if not skinData then
		warn("SkinsHandler: no skin found for '" .. tostring(skinName) .. "'")
		return nil
	end

	if tool:GetAttribute("AppliedSkin") then
		return
	end
	
	if skinID then
		if db_Z.playerData.Cosmetics.Skins[skinID] then
			local skinData = db_Z.playerData.Cosmetics.Skins[skinID]
			if skinData.Killtrack == true then
				require(game:GetService("ReplicatedStorage").Modules.AddKillTrackModel)(tool, player, skinID)
			end
		end
	end
	
	ApplySkin(tool,skinName,player)

	local skinsDataFolder = skinsStorageF[skinData.SkinClass]:FindFirstChild(skinName)
	if skinsDataFolder then
		local sA = skinsDataFolder:FindFirstChildOfClass("SurfaceAppearance")
		if sA then
			sA = sA:Clone()

			local id = math.random(100000,9999999)
			sA.Name = tostring(id)

			sA.Parent = tool

			tool:SetAttribute("AppliedSkinPBR_ID",id)
		end
	end
	
	if skinData.Rarity == "limited" and not ReplicatedStorage.Values.IsVipServer.Value then
		tool:SetAttribute("LimitedHolder",player and player.Name)
	end

	warn("applied skin",skinName)

	tool:SetAttribute("AppliedSkin",skinName)
end


local function GetSkinDataFromName(skinName)
	return all_skins[skinName]
end

local function GetAllSkinsFromClass(class)
	local t = {}
	for i,v in pairs(all_skins) do
		if i ~= "firemagnum" and v.SkinClass == class then
			table.insert(t,i)
		end
	end
	return t
end

local function SharedItemNameCheck(itemName)
	return CONFIG.SharedItemSkins[itemName] or itemName
end

local function GetSkinCustomModule(skinName,customModuleType,...)
	local t = customSkinMs[skinName]
	if not t then
		return
	end
	
	if t[customModuleType] then
		local a,b
		
		if customModuleType == "ShellModify" or customModuleType == "ReloadModifier" or customModuleType == "RocketApply" or customModuleType == "ExplosionApply" then
			a = t[customModuleType]:Clone()
		else
			a = deepCopy(t[customModuleType](...))

			if customModuleType == "ClientConfig" then
				b = t.ClientConfigInstance:Clone()
			end
		end

		return a,b
	end
end

local function GetClientCosmeticList(player,CosmeticsData,EquippedCosmeticsData,CasesData)
	local newCosmetics = {}
	local newEquippedCosmetics = {}

	newCosmetics.Skins = {}
	newCosmetics.Cases = {}

	for id,skinData in pairs(CosmeticsData.Skins) do
		local gotSkinData = skinData.skinName and all_skins[skinData.skinName]
		if not gotSkinData then
			newCosmetics.Skins[id] = {
				Error = true;
			}
		else
			newCosmetics.Skins[id] = {
				DisplayName = gotSkinData.DisplayName;
				Name2 = gotSkinData.Name2;
				Rarity = gotSkinData.Rarity;
				TextureID = gotSkinData.TextureID;
				ItemName = gotSkinData.ItemName;
				SkinClass = gotSkinData.SkinClass;
				
				Killtrack = skinData.Killtrack;
				KilltrackCT = skinData.KilltrackCT;
				
				GotTick = skinData.lastObtainTick;
				JustObtained = skinData.justObtained;
				
				_FixedMagThing = gotSkinData._FixedMagThing;
			}
		end
	end
	for id,caseData in pairs(CosmeticsData.Cases) do
		local gotCaseData = caseData.caseName and activeCases[caseData.caseName]
		if not gotCaseData or not caseData.lastObtainTick or not gotCaseData.CaseType then
			--newCosmetics.Cases[id] = {
			--	Error = true;
			--}
		else
			newCosmetics.Cases[id] = {
				DisplayName = gotCaseData.DisplayName;
				CaseType = gotCaseData.CaseType;
				CostInCash = gotCaseData.CostInCash;
				CostInRobux = gotCaseData.CostInRobux;
				
				ItemName = gotCaseData.ModelName;
				TextureName = gotCaseData.ModelTextureName;
				TextureID = gotCaseData.ModelTextureID;
				
				--ProductId = gotCaseData.ProductId;
				
				GotTick = caseData.lastObtainTick;
				JustObtained = caseData.justObtained;
			}
		end
	end

	return newCosmetics,EquippedCosmeticsData
end

local function GetClientCosmeticStoreData()
	local newTab = {}
	
	newTab.Cases = {}
	
	newTab.InventoryLimits = deepCopy(CONFIG.InventoryLimits)
	
	for i,v in pairs(activeCases) do
		local t = {}
		
		for i,skinName in pairs(v.Contents) do
			local skinData = GetSkinDataFromName(skinName)
			if skinData then
				if not t["EXOTIC"] then
					t["EXOTIC"] = {Rarity = "exotic"};
				else
					if skinData.Rarity ~= "limited" and skinData.Rarity ~= "exotic" then
						if not t[skinName] then
							t[skinName] = {
								DisplayName = skinData.DisplayName;
								Rarity = skinData.Rarity;
								TextureID = skinData.TextureID;

								ItemName = skinData.ItemName;
								SkinClass = skinData.SkinClass;

								_FixedMagThing = skinData._FixedMagThing;
							};
						end
					end
				end
			end
		end
		
		newTab.Cases[i] = {
			Name = i;
			
			Enabled = v.Enabled;
			ForSale = v.Enabled and v.ForSale;
			
			ProductId = v.ProductId;
			GiftProductId = v.GiftProductId;
			BulkProductId = v.BulkProductId;
			
			DisplayName = v.DisplayName;
			Casetype = v.CaseType;
			CostInCash = v.CostInCash;
			CostInRobux = v.CostInRobux;
			
			Rarities = v.DisplayRarities;
			
			IsNew = v.IsNew;
			IsLimited = v.IsLimited;
			CountdownEnd = v.CountdownEnd;
			
			LayoutOrder = v.LayoutOrder;
			
			CaseContents = t;
		}
	end
	
	return newTab
end

local function GetGiftTabFromName(caseName)
	local case = activeCases[caseName]
	if case.Enabled and case.ForSale and case.GiftProductId then
		return {case.GiftProductId,false}
	end
end

local function CheckIfValidCaseFromProductId(givenId)
	if typeof(givenId) ~= "number" then
		return
	end
	
	for caseName,caseData in pairs(activeCases) do
		if caseData.Enabled and caseData.ForSale and (caseData.ProductId == givenId or caseData.GiftProductId == givenId or caseData.BulkProductId == givenId) then
			return caseName,deepCopy(caseData),(caseData.GiftProductId == givenId and caseData.GiftProductId),(caseData.BulkProductId == givenId and caseData.BulkProductId)
		end
	end
end

local function GetSkinSellData(skinName)
	local skinData = all_skins[skinName]
	if not skinData then return end
	
	if skinData.SellLocked then return end
	if skinData.Rarity == "limited" then return end
	if skinData.Rarity == "exotic" then return end
	
	local decidedPrice = CONFIG.SellPrices[skinData.Rarity]
	
	if decidedPrice then
		return {
			Price = decidedPrice;
		}
	end
end

local function GetNewPlayerSkinCaseData(plr,givenCaseName,wasPurchased,wasSpawned)
	local caseData = activeCases[givenCaseName]
	if not caseData then
		return
	end
	if wasPurchased and not caseData.ForSale then
		return
	end

	local t = {
		caseName = givenCaseName;
	};
	
	t.lastObtainTick = os.time();
	t.creationTick = os.time();
	t.wasPurchased = wasPurchased
	t.wasSpawned = wasSpawned

	return deepCopy(t)
end

local function PickRandomFromRarity(caseData,gotRarity)
	local possibleSkins = {}

	for i,v in pairs(caseData.Contents) do
		if all_skins[v] then
			if all_skins[v].Rarity == gotRarity then
				table.insert(possibleSkins,v)
			end
		else
			warn("no allskin data for skinname:",v)
		end
	end
	
	local chosen = possibleSkins[math.random(1,#possibleSkins)]
	
	return chosen,possibleSkins
end

local function PickRandomSkinFromCase(caseData,chosenRarity,plrCaseData,isVisual)
	assert(caseData and caseData.Enabled and caseData.Rarities and caseData.Contents and caseData.CaseType,"SkinsHandler Error: Missing core case table stuff #2")
	
	local obtainType = plrCaseData and plrCaseData.obtainType 
	local isDailyLogin = obtainType and obtainType == "daily_login"

	local newRarities = {}
	for i,v in pairs(caseData.Rarities) do
		if isDailyLogin then
			if i == "legendary" and not isVisual then
				v /= 10
				--print("ahh1")
			elseif i == "rare" and not isVisual then
				v /= 10
				--print("ahh2")
			elseif i == "uncommon" and not isVisual then
				v /= 1.5
				--print("ahh3")
			elseif i == "exotic" then
				--print("ahh4")
				v /= 10000
			elseif i == "limited" then
				--print("ahh4")
				v /= 1000000
				continue
			end
		end
		
		table.insert(newRarities,{i,v})
	end

	local gotRarity = chosenRarity or RarityPickerM(newRarities)

	local chosen = PickRandomFromRarity(caseData,gotRarity)

	return chosen,gotRarity
end

local function DoSkinUnboxVisuals(plr,skinName,plrSkinData,plrCaseData,IsKilltrack)
	print(plr,skinName,plrSkinData,plrCaseData.caseName)
	local gotCaseData = activeCases[plrCaseData.caseName]
	local gotSkinData = all_skins[skinName]
	assert(gotSkinData,"no gotSkinData",skinName)
	
	local isDailyLoginCase = plrCaseData and plrCaseData.obtainType and plrCaseData.obtainType == "daily_login"
	
	if not IsKilltrack then
		IsKilltrack = false
	end
	
	local unboxData = {
		ChosenItem = {
			DisplayName = gotSkinData.DisplayName;
			Rarity = gotSkinData.Rarity;
			TextureID = gotSkinData.TextureID;
			ItemName = gotSkinData.ItemName;
			SkinClass = gotSkinData.SkinClass;
			GotTick = plrSkinData.lastObtainTick;
			Killtrack = IsKilltrack;
			
			_FixedMagThing = gotSkinData._FixedMagThing;
		};
		
		CaseData = {
			CrateType = ""; -- undecided!
			Contents = {};
			
			CostInCash = gotCaseData.CostInCash;
			CostInRobux = gotCaseData.CostInRobux;
			ItemName = gotCaseData.ModelName;
			TextureName = gotCaseData.ModelTextureName;
			TextureID = gotCaseData.ModelTextureID;
		};

		UnboxTime = 7;
	}
	
	local function AddContents()
		local function GetRandomItemData(customChoice,n)
			local randomItem,randomItemRarity
			
			randomItem = PickRandomSkinFromCase(gotCaseData,customChoice,plrCaseData,true)
			
			local gotSkinData = randomItem and all_skins[randomItem]
			if not gotSkinData then
				if not n then
					n = 0
				end
				n += 1
				
				if n >= 20 then
					return
				else
					return GetRandomItemData(customChoice,n)
				end
			else
				local t = {
					DisplayName = "";
					Rarity = gotSkinData.Rarity;
					TextureID = gotSkinData.TextureID;
					ItemName = gotSkinData.ItemName;
					SkinClass = gotSkinData.SkinClass;
					_FixedMagThing = gotSkinData._FixedMagThing;
				}

				return t
			end
		end
		
		local MAX = 50
		
		local gotRarities = {}
		
		for i = 1,MAX do
			local t = GetRandomItemData()
			if t then
				if not gotRarities[t.Rarity] then
					gotRarities[t.Rarity] = 0
				end
				gotRarities[t.Rarity] += 1
				
				table.insert(unboxData.CaseData.Contents,t)
			else
				warn("DoSkinUnboxVisuals Error:","couldnt get random crate thing lol!")
			end
		end
		
		local function AddRandomToSpin()
			local t = gotCaseData.RandomSpinAdds
			if t then
				for i,v in pairs(t) do
					if not (gotRarities[i] and v.NoDupes) then
						local chance = v.Chance
						
						if isDailyLoginCase then
							if i == "limited" or i == "exotic" then
								continue
							elseif i == "legendary" or i == "rare" then
								chance = math.round(chance * 2)
							end
						end
						
						local calc = math.random(1,chance)
						if calc == 1 then		
							local posMin = math.max(math.floor(MAX * v.Position),1)
							
							local decidedPos = math.random(posMin,MAX - 3)

							print("DID RANDOM ADD TO SPIN:",i,decidedPos)

							unboxData.CaseData.Contents[decidedPos] = GetRandomItemData(i)
						end
					end	
				end
			end
		end
		
		AddRandomToSpin()
	end
	
	AddContents()

	local sA
	
	local skinsDataFolder = skinsStorageF[gotSkinData.SkinClass]:FindFirstChild(skinName)
	if skinsDataFolder then
		sA = skinsDataFolder:FindFirstChildOfClass("SurfaceAppearance")
		if sA then
			sA = sA:Clone()
		end
	end
	
	local customMs = customSkinMs[skinName]
	
	local clientUnboxF = plr.PlayerGui:FindFirstChild("UnboxStuff")
	if not clientUnboxF then
		clientUnboxF = Instance.new("Folder")
		clientUnboxF.Name = "UnboxStuff"
		clientUnboxF.Parent = plr.PlayerGui
	end
	
	local repF = Instance.new("Folder")
	repF.Name = gotSkinData.DisplayName
	if sA then
		sA.Parent = repF
	end

	if customMs and customMs.CustomApplyInstance then
		local CustomApplyInstance = customMs.CustomApplyInstance:Clone()
		CustomApplyInstance.Name = "ApplyM"
		CustomApplyInstance.Parent = repF
	end


	
	local old = clientUnboxF:FindFirstChild(gotSkinData.DisplayName)
	if old then
		old:Destroy()
	end
	repF.Parent = clientUnboxF
	task.delay(100,function()
		if repF and repF.Parent then
			repF:Destroy()
		end
	end)
	
	ReplicatedStorage.Events.CaseUnboxEffect:FireClient(plr,"Skin",unboxData)
end

local function GetSkinUnboxData(plr,caseName,plrCaseData,isFinalItem)
	local caseData = activeCases[caseName]
	assert(caseData and caseData.Enabled and caseData.Rarities and caseData.Contents and caseData.CaseType,"SkinsHandler Error: Missing core case table stuff #1")
	
	local function SkinCase()
		local chosen,gotRarity = PickRandomSkinFromCase(caseData,nil,plrCaseData)
		return chosen
	end
	
	if _G.AllowForceSkin then
		return _G.ForceSkin
	end
	
	if caseData.CaseType == "Skin" then
		return SkinCase()
	end	
end

local function GetCaseDataFromCaseName(caseName)
	if activeCases[caseName] and activeCases[caseName].Enabled then
		return activeCases[caseName]
	end
end

local function GetGeneratedId(idType)
	local id = HttpService:GenerateGUID()
	id = string.gsub(id,"{","")
	id = string.gsub(id,"}","")
	id = string.gsub(id,"-","")
	id = string.sub(id,0,18)
	--
	--id = tostring(os.time()) .. "-" .. id
	
	if idType == "case" then
		id = "CS-" .. id
	elseif idType == "skin" then
		id = "SK-" .. id
	end
	
	return id
end

local function GetInventoryLimit(typ,player,playerData)
	local invLimit = 0
	
	if typ == "Skin" then
		invLimit = CONFIG.InventoryLimits.Skins
	elseif typ == "Case" then
		invLimit = CONFIG.InventoryLimits.Cases
	end
	
	if typ ~= "Case" then
		local pd = PlayerbaseData:FindFirstChild(player.Name)

		for passName,passValue in pairs(CONFIG.InventoryLimitPassAdds) do
			if pd and pd.Gamepasses:FindFirstChild(passName) then
				invLimit += passValue
			end
		end
	end
	
	return invLimit
end

local function CheckInventoryLimit(typ,player,playerData,doWarn,isBulkBuy)
	local directory,invLimit
	
	invLimit = 0
	
	if typ == "Skin" then
		directory = playerData.Cosmetics.Skins
	elseif typ == "Case" then
		directory = playerData.Cosmetics.Cases
	end
	
	invLimit = GetInventoryLimit(typ,player,playerData)
	
	if directory then
		local n = 0
		for i,v in pairs(directory) do
			n += 1
		end
		
		if isBulkBuy then
			n += 9
		end
		
		if n >= invLimit then
			if doWarn and player then
				local tab = {
					Title = "Inventory Limit Error";
					Text = "";
					Duration = 5;
					Button1 = "Close";
				}
				local _tx =  (typ == "Skin" and "Skin") or (typ == "Case" and "Case") or "N/A"
				tab.Text = "Max " .. _tx .. " inventory reached (" .. tostring(invLimit) .. ")"
				
				ReplicatedStorage.Events.Notification:FireClient(player,tab,"error")
			end
			
			return true,invLimit
		end
	end
end

function DoLog(logType,player,title,desc,array,color,content)
	if RunService:IsStudio() and not CONFIG.StudioLog then
		return true
	end
	
	if true then
		return true
	else
		warn("SkinsHandler DoLogError:",false)
		return false
	end
end

M.DoLog = DoLog

M.GetSkinSellData = GetSkinSellData

M.CheckInventoryLimit = CheckInventoryLimit

M.GetInventoryLimit = GetInventoryLimit

M.GetGeneratedId = GetGeneratedId

M.GetAllSkinsFromClass = GetAllSkinsFromClass

M.GetSkinCustomModule = GetSkinCustomModule

M.SharedItemNameCheck = SharedItemNameCheck

M.CheckIfValidCaseFromProductId = CheckIfValidCaseFromProductId

M.GetNewPlayerSkinCaseData = GetNewPlayerSkinCaseData

M.GetClientCosmeticList = GetClientCosmeticList

M.GetClientCosmeticStoreData = GetClientCosmeticStoreData

M.GetGiftTabFromName = GetGiftTabFromName

M.GetSkinDataFromName = GetSkinDataFromName

M.ApplyFullSkin = ApplyFullSkin

M.GetSkinUnboxData = GetSkinUnboxData

M.GetCaseDataFromCaseName = GetCaseDataFromCaseName

M.DoSkinUnboxVisuals = DoSkinUnboxVisuals

M.SetUp = function(settinz)
	if M.isSetUp then
		return
	end
	M.isSetUp = true
	
	print("\n---")
	print("loading skinsHandler")

	GameSettings = settinz
	
	CONFIG.SellPrices = deepCopy(require(ReplicatedStorage.Modules.CosmeticRaritySellPrices))
	--config = GameSettings.CashDropSettings

	for i,v in pairs(skinsDataF:GetDescendants()) do
		if v.ClassName == "ModuleScript" then
			local req = require(v)

			for skinName,skinData in pairs(req) do
				if all_skins[skinName] then
					warn("SkinsHandler: Duplicate skins for",skinName,"(" .. tostring(v.Name) .. ")")
				else
					local _s,_e = pcall(function()
						all_skins[skinName] = skinData
						
						local skinsDataFolder = skinsStorageF[skinData.SkinClass]:FindFirstChild(skinName)
						if skinsDataFolder then
							local customModulesF = skinsDataFolder:findFirstChild("CustomModules")
							if customModulesF then
								local t = {}
								local serverConfigM = customModulesF:FindFirstChild("ServerConfig") and require(customModulesF.ServerConfig)
								if serverConfigM then
									t.ServerConfig = serverConfigM
								end
								local clientConfigM = customModulesF:FindFirstChild("ClientConfig") and require(customModulesF.ClientConfig)
								if clientConfigM then
									t.ClientConfig = clientConfigM
									t.ClientConfigInstance = customModulesF.ClientConfig
								end
								
								local customApplyM = customModulesF:FindFirstChild("CustomApply")
								if customApplyM then
									t.CustomApply = require(customModulesF.CustomApply)
									t.CustomApplyInstance = customApplyM
								end
								
								local shellModifyM = customModulesF:FindFirstChild("ShellModify")
								if shellModifyM then
									t.ShellModify = shellModifyM
								end
								
								local reloadModiferM = customModulesF:FindFirstChild("ReloadModifier")
								if reloadModiferM then
									t.ReloadModifier = reloadModiferM
								end
								
								local rocketApplyM = customModulesF:FindFirstChild("RocketApply")
								if rocketApplyM then
									t.RocketApply = require(customModulesF.RocketApply)
									t.RocketApply = rocketApplyM
								end
								
								local explosionApplyM = customModulesF:FindFirstChild("ExplosionApply")
								if explosionApplyM then
									t.ExplosionApply = require(customModulesF.ExplosionApply)
									t.ExplosionApply = explosionApplyM
								end
												
								customSkinMs[skinName] = t
							end
						end
					end)
					
					if not _s then
						warn("SkinsHandler Error:","CustomApplyMAndStuff",_e)
					end
				end
			end
		end
	end
	for i,v in pairs(casesDataF:GetDescendants()) do
		if v.ClassName == "ModuleScript" then
			local req = require(v)
			
			if req.Enabled then
				activeCases[v.Name] = req
			end
		end
	end
	
	ServerStorage.Events3.ApplySkin.OnInvoke = function(tool,skinName,player,id)
		local _s,_e = pcall(function()
			return ApplyFullSkin(tool,skinName,player,id)
		end)
		
		if not _s then
			warn("SkinsHandler Error:","Error applying skin",skinName,player)
		end
		
		return _s
	end
	
	ServerStorage.Events3.ApplySkin_DM.OnInvoke = function(nf,skinName)
		local _s,_e = pcall(function()
			return ApplySkin(nf,skinName)
		end)

		if not _s then
			warn("SkinsHandler Error:","Error applying skin (DM)",skinName)
		end

		return _s
	end

	print("loaded skins handler")

	--print(all_skins)
	print("\n---")
end

--local function StrictTable(Virtual_Table)
--	local Protected = newproxy(true)
--	local Mt = getmetatable(Protected)

--	Mt.__index = Virtual_Table
--	Mt.__namecall = Virtual_Table
--	Mt.__newindex = function()
--		error("Attempted to modify a protected table.")
--	end

--	Mt.__metatable = "This table is protected."

--	return Protected
--end

M.CONFIG = deepCopy(CONFIG)

return M