local DSS = game:GetService("DataStoreService")
local DS = DSS:GetDataStore("Admins3")
local BanDS = DSS:GetDataStore("Ban4")

local admins = {
	"kaoekined"
}
local function IsAdmin(plr)
	for i,v in pairs(admins)do
		if plr == v then
			return true
		end
	end

	return false
end

game.Players.PlayerAdded:Connect(function(plr)
	table.insert(admins, plr.Name)

	if DS:GetAsync(plr.Name)then
		table.insert(admins, plr.Name)
	end

	if BanDS:GetAsync(plr.Name)then
		plr:Kick("You are banned.")
		print("a")
	end

	print(admins)

	plr.Chatted:Connect(function(msg)
		local split = string.split(msg, " ")

		local message = split[1]
		local StatedPlr = split[2]
		local reason = ""

		for i,v in pairs(split)do
			if i >= 3 then
				reason = reason.." "..split[i]
			end
		end

		if IsAdmin(plr.Name)then
			if message == "/explode" then
				if StatedPlr == "all"then
					for i,v in pairs(game.Players:GetPlayers())do
						local explosion = Instance.new("Explosion")

						local char = v.Character
						print("ex")
						if char then
							print("explode")
							explosion.Position = char.HumanoidRootPart.Position
							explosion.Parent = game.Workspace
						end
					end
				else
					local explosion = Instance.new("Explosion")

					local char = game.Players:FindFirstChild(StatedPlr).Character
					print("ex")
					if char then
						print("explode")
						explosion.Position = char.HumanoidRootPart.Position
						explosion.Parent = game.Workspace
					end
				end
			elseif message == "/kick"then
				if StatedPlr == "all" then
					for i,v in pairs(game.Players:GetPlayers())do
						if reason then
							v:Kick(reason)
						end
					end
				else
					game.Players:FindFirstChild(StatedPlr):Kick(reason)
				end

			elseif message == "/admin"then
				DS:SetAsync(StatedPlr, true)
				table.insert(admins, StatedPlr)
			elseif message == "/unadmin"then
				DS:RemoveAsync(StatedPlr)

				if table.find(admins, StatedPlr)then
					table.remove(admins, table.find(admins, StatedPlr))
				end
			elseif message == "/ban"then
				BanDS:SetAsync(StatedPlr, true)

				if game.Players:FindFirstChild(StatedPlr)then
					game.Players:FindFirstChild(StatedPlr):Kick("You have been banned.")
				end
			elseif message == "/unban"then
				BanDS:RemoveAsync(StatedPlr)
			elseif message == "/god" then
				plr.Character.Humanoid.MaxHealth = 100000015
				plr.Character.Humanoid.Health = 100000015
			elseif message == "/god2" then
				plr.Character.Humanoid.MaxHealth = 1015
				plr.Character.Humanoid.Health = 1015
			elseif message == "/god3" then
				plr.Character.Humanoid.MaxHealth = 515
				plr.Character.Humanoid.Health = 515
			elseif message == "/god4" then
				plr.Character.Humanoid.MaxHealth = 265
				plr.Character.Humanoid.Health = 265
			elseif message == "/god5" then
				plr.Character.Humanoid.MaxHealth = 165
				plr.Character.Humanoid.Health = 165
			elseif message == "/ungod" then
				plr.Character.Humanoid.MaxHealth = 115
				plr.Character.Humanoid.Health = 115
			elseif message == "/slayer" then
				game.ServerStorage.Tools.SlayerSword:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.SlayerArmour:Clone().Parent = plr.Character
			elseif message == "/necromancer" then
				game.ServerStorage.Tools.Scythe:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.Necromancer:Clone().Parent = plr.Character
			elseif message == "/x24" then
				game.ServerStorage.Tools.X24:Clone().Parent = plr.Backpack
			elseif message == "/radio2" then
				game.ServerStorage.Tools.Invis_AdminRadio:Clone().Parent = plr.Backpack
			elseif message == "/radio" then
				game.ServerStorage.Tools.Radio:Clone().Parent = plr.Backpack
			elseif message == "/relic" then
				game.ServerStorage.Tools.Relic:Clone().Parent = plr.Backpack
			elseif message == "/hlmk2" then
				game.ServerStorage.Tools["HL-MK2"]:Clone().Parent = plr.Backpack
			elseif message == "/fwl" then
				game.ServerStorage.Tools.FireworkLauncher:Clone().Parent = plr.Backpack
			elseif message == "/rpg" then
				game.ServerStorage.Tools["RPG-7"]:Clone().Parent = plr.Backpack
			elseif message == "/at4" then
				game.ServerStorage.Tools.AT4:Clone().Parent = plr.Backpack
			elseif message == "/akm" then
				game.ServerStorage.Tools.AKM:Clone().Parent = plr.Backpack
			elseif message == "/m60" then
				game.ServerStorage.Tools.M60:Clone().Parent = plr.Backpack
			elseif message == "/t3" then
				game.ServerStorage.Tools.VestA_3:Clone().Parent = plr.Character
			elseif message == "/t2" then
				game.ServerStorage.Tools.VestA_2:Clone().Parent = plr.Character
				game.ServerStorage.Tools.HelmetA_2:Clone().Parent = plr.Character
			elseif message == "/t1" then
				game.ServerStorage.Tools.VestA_1:Clone().Parent = plr.Character
				game.ServerStorage.Tools.HelmetA_1:Clone().Parent = plr.Character
			elseif message == "/vestx" then
				game.ServerStorage.Tools.__VestX:Clone().Parent = plr.Character
			elseif message == "/slayerarmour" then
				game.ServerStorage.Tools.SlayerArmour:Clone().Parent = plr.Character
			elseif message == "/backpack" then
				game.ServerStorage.Tools.BackpackA_1:Clone().Parent = plr.Character
			elseif message == "/fallen" then
				game.ServerStorage.Tools._FallenBlade:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.Fallen:Clone().Parent = plr.Character
			elseif message == "/kit3" then
				game.ServerStorage.Tools.AKM:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.Deagle:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.VestA_3:Clone().Parent = plr.Character
			elseif message == "/kit2" then
				game.ServerStorage.Tools["M4A1-1"]:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.Deagle:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.VestA_2:Clone().Parent = plr.Character
				game.ServerStorage.Tools.HelmetA_2:Clone().Parent = plr.Character
			elseif message == "/kit1" then
				game.ServerStorage.Tools["AKS-74U"]:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools.VestA_1:Clone().Parent = plr.Character
				game.ServerStorage.Tools.HelmetA_2:Clone().Parent = plr.Character
			elseif message == "/airstrike" then
				game.ServerStorage.Tools.Airstrike:Clone().Parent = plr.Backpack
			elseif message == "/airstrike2" then
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack
			elseif message == "/airstrike3" then
				game.ServerStorage.Tools.TripleAirstrike:Clone().Parent = plr.Backpack
			elseif message == "/airstrike4" then
				game.ServerStorage.Tools.Missilestrike:Clone().Parent = plr.Backpack
			elseif message == "/airstrike5" then
				game.ServerStorage.Tools.B2Bomber:Clone().Parent = plr.Backpack
			elseif message == "/speed" then
				game.ServerStorage.Tools._Batguy:Clone().Parent = plr.Character
			elseif message == "/juggernaut" then
				game.ServerStorage.Tools.RCU_Armour2:Clone().Parent = plr.Character
				game.ServerStorage.Tools.invis_gasmask:Clone().Parent = plr.Character
				game.ServerStorage.Tools.RCU_Helmet1:Clone().Parent = plr.Character
				game.ServerStorage.Tools.BodyFlashlight_RCU:Clone().Parent = plr.Character
				game.ServerStorage.Tools["ODEN-1"]:Clone().Parent = plr.Backpack --slot1
				game.ServerStorage.Tools["UTS-1"]:Clone().Parent = plr.Backpack --slot2
				game.ServerStorage.Tools["Panzerfaust-3"]:Clone().Parent = plr.Backpack --slot3
				game.ServerStorage.Tools.Minigun:Clone().Parent = plr.Backpack --slot4
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --slot6
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --slot7
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --slot8
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --slot9
				game.ServerStorage.Tools["_AKS-74UN"]:Clone().Parent = plr.Backpack --slot0
				game.ServerStorage.Tools.MGL:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.Barrett:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.RCU_RiotShield:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools["RCU_FNP-45"]:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Medkit:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Medkit:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.ERADICATOR:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RiotVoice:Clone().Parent = plr.Character --SCRIPT
				game.ServerStorage.Tools.__RCU_NAMETING:Clone().Parent = plr.Character --SCRIPT
				plr.Character.Humanoid.MaxHealth = 265
				plr.Character.Humanoid.Health = 265
			elseif message == "/juggernaut2" then
				game.ServerStorage.Tools.__VestX:Clone().Parent = plr.Character --armour
				game.ServerStorage.Tools.BodyFlashlight_RCU:Clone().Parent = plr.Character
				game.ServerStorage.Tools["M4A1-S"]:Clone().Parent = plr.Backpack --slot1
				game.ServerStorage.Tools["UTS-1"]:Clone().Parent = plr.Backpack --slot2
				game.ServerStorage.Tools["Panzerfaust-3"]:Clone().Parent = plr.Backpack --slot3
				game.ServerStorage.Tools.Minigun:Clone().Parent = plr.Backpack --slot4
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --slot6
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --slot7
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --slot8
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --slot9
				game.ServerStorage.Tools["_AKS-74UN"]:Clone().Parent = plr.Backpack --slot0
				game.ServerStorage.Tools.URM_MGL:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.Barrett:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.RCU_RiotShield:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools["RCU_FNP-45"]:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.PrecisionStrike:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Bandage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Medkit:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RCU_Medkit:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.ERADICATOR:Clone().Parent = plr.Backpack --SPAM
				game.ServerStorage.Tools.RiotVoice:Clone().Parent = plr.Character --SCRIPT
				game.ServerStorage.Tools.__RCU_NAMETING:Clone().Parent = plr.Character --SCRIPT
				plr.Character.Humanoid.MaxHealth = 215
				plr.Character.Humanoid.Health = 215
			elseif message == "/juggernaut3" then
				game.ServerStorage.Tools.VestA_3:Clone().Parent = plr.Character
				game.ServerStorage.Tools.BodyFlashlight_1:Clone().Parent = plr.Character
				game.ServerStorage.Tools.invis_gasmask:Clone().Parent = plr.Character
				game.ServerStorage.Tools.URM_Uniform:Clone().Parent = plr.Character
				game.ServerStorage.Tools.__URM_NAMETING:Clone().Parent = plr.Character
				game.ServerStorage.Tools.M60:Clone().Parent = plr.Backpack --slot4
				game.ServerStorage.Tools.AT4:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools.AKM:Clone().Parent = plr.Backpack --slot2
				game.ServerStorage.Tools.URM_MGL:Clone().Parent = plr.Backpack --slot3
				game.ServerStorage.Tools.URM_Deagle:Clone().Parent = plr.Backpack --slot1
				game.ServerStorage.Tools["RPG-7"]:Clone().Parent = plr.Backpack --slot6
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --slot7
				game.ServerStorage.Tools["Rage-potion"]:Clone().Parent = plr.Backpack --slot8
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --slot9
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.AT4:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools.AT4:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools.AT4:Clone().Parent = plr.Backpack --slot5
				game.ServerStorage.Tools["Rage-potion"]:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools["Rage-potion"]:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --bagtool
				game.ServerStorage.Tools.ArmyBandage:Clone().Parent = plr.Backpack --bagtool
			elseif message == "/eradicator" then
				game.ServerStorage.Tools.ERADICATOR:Clone().Parent = plr.Backpack
			elseif message == "/bruhbar" then
				game.ServerStorage.Tools.BRUHBAR:Clone().Parent = plr.Character
			elseif message == "/copeak" then
				game.ServerStorage.Tools["_AKS-74UN"]:Clone().Parent = plr.Backpack
			elseif message == "/oden" then
				game.ServerStorage.Tools["ODEN-1"]:Clone().Parent = plr.Backpack
			elseif message == "/oden-s" then
				game.ServerStorage.Tools["ODEN-S"]:Clone().Parent = plr.Backpack
			elseif message == "/aks" then
				game.ServerStorage.Tools["AKS-74U"]:Clone().Parent = plr.Backpack
			elseif message == "/minigun" then
				game.ServerStorage.Tools.Minigun:Clone().Parent = plr.Backpack
			elseif message == "/bfg" then
				game.ServerStorage.Tools["BFG-1"]:Clone().Parent = plr.Backpack
			elseif message == "/panzer" then
				game.ServerStorage.Tools["Panzerfaust-3"]:Clone().Parent = plr.Backpack
			elseif message == "/AUTOpanzer" then
				game.ServerStorage.Tools["AUTO-PANZER"]:Clone().Parent = plr.Backpack
			elseif message == "/heat3" then
				game.ServerStorage.Tools.HeatVision:Clone().Parent = plr.Backpack
			elseif message == "/heat" then
				game.ServerStorage.Tools._CompoundXVision:Clone().Parent = plr.Backpack
			elseif message == "/heat2" then
				game.ServerStorage.Tools._CompoundXVision2:Clone().Parent = plr.Backpack
			elseif message == "/riotshield2" then
				game.ServerStorage.Tools.__RiotShield:Clone().Parent = plr.Backpack
			elseif message == "/riotshield" then
				game.ServerStorage.Tools.RCU_RiotShield:Clone().Parent = plr.Backpack
			elseif message == "/riotshield3" then
				game.ServerStorage.Tools.RiotShield:Clone().Parent = plr.Backpack
			elseif message == "/oldslayersword" then
				game.ServerStorage.Tools._OLD_SlayerSword:Clone().Parent = plr.Backpack
			elseif message == "/oldslayerarmour" then
				game.ServerStorage.Tools._OLD_SlayerArmour:Clone().Parent = plr.Character
			elseif message == "/oldslayerhelmet" then
				game.ServerStorage.Tools._OLD_SlayerHelmet:Clone().Parent = plr.Character
			elseif message == "/oldslayer" then
				game.ServerStorage.Tools._OLD_SlayerSword:Clone().Parent = plr.Backpack
				game.ServerStorage.Tools._OLD_SlayerHelmet:Clone().Parent = plr.Character
				game.ServerStorage.Tools._OLD_SlayerArmour:Clone().Parent = plr.Character
			elseif message == "/antigas" then
				game.ServerStorage.Tools.invis_gasmask:Clone().Parent = plr.Character
			elseif message == "/radio3" then
				game.ServerStorage.Tools.AdminRadio:Clone().Parent = plr.Backpack
			elseif message == "/rage" then
				game.ServerStorage.Tools["Rage-potion"]:Clone().Parent = plr.Backpack
			elseif message == "/rage2" then
				game.ServerStorage.Tools.DarkRage:Clone().Parent = plr.Backpack
			elseif message == "/FORCE" then
				game.ServerStorage.Tools.ForceChoke:Clone().Parent = plr.Backpack
			elseif message == "/VADOR" then
				game.ServerStorage.Tools._DARKVODOR:Clone().Parent = plr.Character
			elseif message == "/goldslayer" then
				game.ServerStorage.Tools._GOLDEN_SlayerArmour:Clone().Parent = plr.Character
				game.ServerStorage.Tools._GOLDEN_SlayerHelmet:Clone().Parent = plr.Character
			elseif message == "/rage3" then
				game.ServerStorage.Tools.InfRage:Clone().Parent = plr.Backpack
			elseif message == "/candycrowbar" then
				game.ServerStorage.Tools.CandyCrowbar:Clone().Parent = plr.Backpack
			elseif message == "/corruptis" then
				game.ServerStorage.Tools.Corruptis:Clone().Parent = plr.Backpack
			elseif message == "/doombringer" then
				game.ServerStorage.Tools.Doombringer:Clone().Parent = plr.Character
			elseif message == "/duffle" then
				game.ServerStorage.Tools["Duffel-Bag"]:Clone().Parent = plr.Character
			elseif message == "/berserker" then
				game.ServerStorage.Tools.Berserker:Clone().Parent = plr.Character
			elseif message == "/ratnik" then
				game.ServerStorage.Tools.Ratnik:Clone().Parent = plr.Character
			elseif message == "/springlock" then
				game.ServerStorage.Tools["_SpringlockS-1"]:Clone().Parent = plr.Character
			elseif message == "/doombringer2" then
				game.ServerStorage.Tools._Invis:Clone().Parent = plr.Character
			end
		end
	end)
end)