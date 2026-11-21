local tastiestEvents = game:GetService("ReplicatedStorage"):WaitForChild("TastiestEvents")
local remoteEvent = tastiestEvents:WaitForChild("remote")
local remoteFunction = tastiestEvents:WaitForChild("remoteFunction")
local bindableEvent = tastiestEvents:WaitForChild("bindableEvent")
--
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local marketPlaceService=game:GetService("MarketplaceService")
--
return function()
	print("Tastiest Chips Handler Ran")
	-- Init

	if (serverStorage._MainG:FindFirstChild("MainModule")) then
		require(serverStorage._MainG["MainModule"])() end
	--
	local scripts = script:WaitForChild("scripts")
	-- Game Init

	require(script:WaitForChild("game"):WaitForChild("WardrobesHandler"))()
	-- Systems

	local messaging = require(scripts:WaitForChild("systems"):WaitForChild("messaging")) messaging.init() _G.sMessaging = messaging
	-- Scripts

	require(scripts:WaitForChild("game"):WaitForChild("teleporting"))()
	-- Check If Can

	local function checkIfCan(c)
		local cvf = _G.GVF(c.Name)
		if (_G.CheckIfCan(c, nil, 0) == true and _G.CheckIfFlinching(c, true, true) == false) then
			return true end
		return false
	end
	-- Remote Events

	local remoteEvents = {
		--
		["SetLookAngles"] = function(player, data)
			local pitch=data[1]
			local yaw=data[2]
			--
			if typeof(pitch) ~= "number" or pitch ~= pitch then
				return
			end

			if typeof(yaw) ~= "number" or yaw ~= yaw then
				return
			end

			pitch = math.clamp(pitch, -1, 1)
			yaw = math.clamp(yaw, -1, 1)

			remoteEvent:FireAllClients("SetLookAngles", {player, pitch, yaw})
		end,
		--
		["NotificationResponse"] = function(plr, data)
			if (data.key == "Glory") then
				if (data.passed.response) then
					local oplr = data.passed.player
					local tvf = _G.GVF(oplr.Name)
					local ovf = _G.GVF(plr.Name)
					if (checkIfCan(oplr.Character) and checkIfCan(plr.Character)) and (not tvf.Downed.Value and not ovf.Downed.Value) and (oplr:FindFirstChild("gloryRequest") and oplr.gloryRequest.Value == plr.Name) and not plr.Character:FindFirstChild("GoonFF") then
						_G.Glory(oplr, plr.Character, true)
					end
				end
			end
		end,
		--
		["GloryRequest"] = function(plr, data)
			local pchar = plr.Character
			local pcharvf = _G.GVF(pchar.Name)
			local eplr = game.Players:GetPlayerFromCharacter(data[1])
			local echar = data[1]
			local echarvf = _G.GVF(echar.Name)
			--
			local function checkIfCan(c)
				if (_G.CheckIfCan(c, nil, 0) == true and _G.CheckIfFlinching(c, true, true) == false) then
					return true end
				return false
			end
			--
			if (checkIfCan(pchar) and checkIfCan(echar)) and (not _G.InCombatCheck(plr, true) and not _G.InCombatCheck(eplr, true)) and (pcharvf.Downed.Value == false and echarvf.Downed.Value == false) and (plr:FindFirstChild("gloryRequest") == nil) then
				--
				local tab = {
					Title = "Glory Request";
					Text = pchar.Humanoid.DisplayName.." is requesting to glory with you.";
					Duration = 10;
					Button1 = "Accept";
					Button1Key = "Glory";
					Button2 = "Decline";
					Button2Key = "Glory";
					Button1PassedData = {player = plr, response = true},
					Button2PassedData = {player = plr, response = false},
				}
				--
				local gloryRequest = _G.Create("StringValue", "gloryRequest", plr, {{"Value", echar.Name}})
				_G.SafeDestroy(gloryRequest, 11)
				game:GetService("ReplicatedStorage").Events.Notification:FireClient(game.Players:GetPlayerFromCharacter(echar), tab, "BEEP")
				--
			else
				game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(plr,{"Error in glory request.",1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
				return
			end
			--
		end,
		--
		["CutTiedRope"] = function(plr, data)
			--
			local tool = data.tool
			local character = plr.Character
			local charactervf = _G.GVF(character.Name)
			local root = character.HumanoidRootPart
			if (character and charactervf) then
				if (data.typ == "start") then
					--
					local function selfCheck()
						if (_G.CheckIfCan(character, nil, 0) == true and _G.CheckIfFlinching(character, true, true) == false) then
							return true end
						return false
					end
					--
					if (selfCheck() and _G.DoesCharAffectExist(character, "CUTTINGROPE")==false) then
						--
						local ocharacter = nil
						local odis = 8
						for _, ochar in ipairs(game.Workspace.Characters:GetChildren()) do
							if (ochar ~= character and ochar:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0) and (_G.DoesCharAffectExist(ochar, "TIEDUP")==true) then
								local ochardot = _G.HorizontalVectorDot((ochar.HumanoidRootPart.Position - root.Position).Unit, root.CFrame.LookVector.Unit)
								local ochardis = (ochar.HumanoidRootPart.Position - root.Position).Magnitude
								if (ochardis < odis and ochardot >= 0.65) then
									ocharacter = ochar
									odis = ochardis
								end
							end
						end
						--
						if (ocharacter ~= nil) then
							--
							local CUTTINGROPE_ID = _G.AffectChar(character, "CUTTINGROPE", math.huge)
							local CUTTINGROPE_SP = _G.AffectChar(character, "SP", math.huge, "CUTTINGROPE", 0)
							local CUTTINGROPE_B = _G.AffectChar(character, "B", math.huge, "CUTTINGROPE")
							local CUTTINGROPE_DHAR = _G.AffectChar(character, "DHAR", math.huge, "CUTTINGROPE")
							--
							_G.PlaySound(replicatedStorage.Assets.TastiestChips.sounds.ropeTying.pull, root, _G.Random(0.9, 1.1, 100))
							local anim = character.Humanoid:LoadAnimation(replicatedStorage.Assets.TastiestChips.animations.cuttingRope) anim:Play(0.05)
							local cuttingRopeOs = os.clock()
							remoteEvent:FireClient(plr, "GuiAction", {typ = "start", msg = "CUTTING ROPE..."})
							local CuttingRopeGyro, _, at = _G.CreateAlignOrientation(root, root.RootAttachment, nil)
							at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
							tool:SetAttribute("NoArmMovement", true)
							--
							repeat
								local delta = task.wait()
								--
								at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
								--
							until (_G.SafeCheck(tool) == false or _G.SafeCheck(CUTTINGROPE_ID) == false or _G.SafeCheck(ocharacter) == false or _G.SafeCheck(character) == false) or ((os.clock() - cuttingRopeOs) >= 4 or selfCheck() == false or ocharacter.Humanoid.Health <= 0 or (ocharacter.HumanoidRootPart.Position - root.Position).Magnitude >= 10)
							--
							anim:Stop(0.45)
							tool:SetAttribute("NoArmMovement", false)
							remoteEvent:FireClient(plr, "GuiAction", {typ = "end"})
							_G.SafeDestroy(CUTTINGROPE_ID)
							_G.SafeDestroy(CUTTINGROPE_SP)
							_G.SafeDestroy(CUTTINGROPE_B)
							_G.SafeDestroy(CUTTINGROPE_DHAR)
							_G.SafeDestroy(CuttingRopeGyro)
							_G.SafeDestroy(at)
							--
							if (os.clock() - cuttingRopeOs) >= 4 then
								_G.GVF(ocharacter.Name).Currents.TIEDUP:Destroy()
							end
							--
						end
						--
					end
					--
				elseif (data.typ == "cancel") then
					--
					if (_G.DoesCharAffectExist(character, "CUTTINGROPE")) then
						charactervf.Currents.CUTTINGROPE:Destroy()
					end
					--
				end
			end
			--
		end,
		--
		["RopeTying"] = function(plr, data)
			--
			local tool = data.tool
			local character = plr.Character
			local charactervf = _G.GVF(character.Name)
			local root = character.HumanoidRootPart
			if (character and charactervf) then
				if (data.typ == "start") then
					--
					local function selfCheck()
						if (_G.CheckIfCan(character, nil, 0) == true and _G.CheckIfFlinching(character, true, true) == false) then
							return true end
						return false
					end
					--
					if (selfCheck() and _G.DoesCharAffectExist(character, "TYINGUP")==false) then
						--
						local ocharacter = nil
						local odis = 5
						for _, ochar in ipairs(game.Workspace.Characters:GetChildren()) do
							if (ochar ~= character and ochar:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0) and (_G.DownedCheck(ochar)==true) then
								local ochardot = _G.HorizontalVectorDot((ochar.HumanoidRootPart.Position - root.Position).Unit, root.CFrame.LookVector.Unit)
								local ochardis = (ochar.HumanoidRootPart.Position - root.Position).Magnitude
								if (ochardis < odis and ochardot >= 0.65) then
									ocharacter = ochar
									odis = ochardis
								end
							end
						end
						--
						if (ocharacter ~= nil) then
							--
							local TYINGUP_ID = _G.AffectChar(character, "TYINGUP", math.huge)
							local TYINGUP_SP = _G.AffectChar(character, "SP", math.huge, "TYINGUP", 0)
							local TYINGUP_B = _G.AffectChar(character, "B", math.huge, "TYINGUP")
							local TYINGUP_DHAR = _G.AffectChar(character, "DHAR", math.huge, "TYINGUP")
							local TYINGUP_O_DDB = _G.AffectChar(ocharacter, "DISABLE-DOWNED-BLEEDOUT", math.huge, "TYINGUP")
							--
							_G.PlaySound(replicatedStorage.Assets.TastiestChips.sounds.ropeTying.pull, root, _G.Random(0.9, 1.1, 100))
							local anim = character.Humanoid:LoadAnimation(replicatedStorage.Assets.TastiestChips.animations.tyingUp) anim:Play(0.05)
							local tyingUpOs = os.clock()
							remoteEvent:FireClient(plr, "GuiAction", {typ = "start", msg = "TYING UP..."})
							character.Humanoid:UnequipTools()
							local TyingUpGyro, _, at = _G.CreateAlignOrientation(root, root.RootAttachment, nil)
							at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
							--
							repeat
								local delta = task.wait()
								--
								at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
								--
							until (_G.SafeCheck(tool) == false or _G.SafeCheck(TYINGUP_ID) == false or _G.SafeCheck(ocharacter) == false or _G.SafeCheck(character) == false) or ((os.clock() - tyingUpOs) >= 4 or selfCheck() == false or ocharacter.Humanoid.Health <= 0 or (ocharacter.HumanoidRootPart.Position - root.Position).Magnitude >= 10)
							--
							anim:Stop(0.45)
							remoteEvent:FireClient(plr, "GuiAction", {typ = "end"})
							_G.SafeDestroy(TYINGUP_ID)
							_G.SafeDestroy(TYINGUP_SP)
							_G.SafeDestroy(TYINGUP_B)
							_G.SafeDestroy(TYINGUP_DHAR)
							_G.SafeDestroy(TyingUpGyro)
							_G.SafeDestroy(at)
							--
							if (os.clock() - tyingUpOs) >= 4 then
								tool:Destroy()
								if (plr.Backpack:FindFirstChild("Fists")) then character.Humanoid:EquipTool(plr.Backpack.Fists) end
								_G.SafeDestroy(TYINGUP_O_DDB, 3)
								_G.PlaySound(replicatedStorage.Assets.TastiestChips.sounds.ropeTying.complete, root, _G.Random(0.9, 1.1, 100))
								require(serverStorage.CharacterScripts.Other.ropeTyingUp).tieup(ocharacter)
							else
								_G.SafeDestroy(TYINGUP_O_DDB)
								character.Humanoid:EquipTool(tool) end
							--
						end
						--
					end
					--
				elseif (data.typ == "cancel") then
					--
					if (_G.DoesCharAffectExist(character, "TYINGUP")) then
						charactervf.Currents.TYINGUP:Destroy()
					end
					--
				end
			end
			--
		end,
		--
		["ForceFeed"] = function(plr, data)
			--
			local tool = data.tool
			local character = plr.Character
			local charactervf = _G.GVF(character.Name)
			local root = character.HumanoidRootPart
			if (character and charactervf) then
				if (data.typ == "start") then
					--
					local function selfCheck()
						if (_G.CheckIfCan(character, nil, 0) == true and _G.CheckIfFlinching(character, true, true) == false) then
							return true end
						return false
					end
					--
					if (selfCheck() and _G.DoesCharAffectExist(character, "FORCEFEEDING")==false) then
						--
						local ocharacter = nil
						local odis = 8
						for _, ochar in ipairs(game.Workspace.Characters:GetChildren()) do
							if (ochar ~= character and ochar:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0) and (_G.DownedCheck(ochar)) then
								local ochardot = _G.HorizontalVectorDot((ochar.HumanoidRootPart.Position - root.Position).Unit, root.CFrame.LookVector.Unit)
								local ochardis = (ochar.HumanoidRootPart.Position - root.Position).Magnitude
								if (ochardis < odis and ochardot >= 0.65) then
									ocharacter = ochar
									odis = ochardis
								end
							end
						end
						--
						if (ocharacter ~= nil) then
							--
							local FORCEFEEDING_ID = _G.AffectChar(character, "FORCEFEEDING", math.huge)
							local FORCEFEEDING_SP = _G.AffectChar(character, "SP", math.huge, "FORCEFEEDING", 0)
							local FORCEFEEDING_B = _G.AffectChar(character, "B", math.huge, "FORCEFEEDING")
							local FORCEFEEDING_DHAR = _G.AffectChar(character, "DHAR", math.huge, "FORCEFEEDING")
							--
							local anim = character.Humanoid:LoadAnimation(replicatedStorage.Assets.TastiestChips.animations.tyingUp) anim:Play(0.05)
							local forceFeedOs = os.clock()
							remoteEvent:FireClient(plr, "GuiAction", {typ = "start", msg = "FORCE FEEDING..."})
							local forceFeedGyro, _, at = _G.CreateAlignOrientation(root, root.RootAttachment, nil)
							at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
							tool:SetAttribute("NoArmMovement", true)
							--
							repeat
								local delta = task.wait()
								--
								at.WorldCFrame = CFrame.new(root.Position, root.Position + _G.HorizontalVectorDirectionFromPositions(root.Position, ocharacter.HumanoidRootPart.Position))
								--
							until (_G.SafeCheck(tool) == false or _G.SafeCheck(FORCEFEEDING_ID) == false or _G.SafeCheck(ocharacter) == false or _G.SafeCheck(character) == false) or ((os.clock() - forceFeedOs) >= 4 or selfCheck() == false or ocharacter.Humanoid.Health <= 0 or (ocharacter.HumanoidRootPart.Position - root.Position).Magnitude >= 10) or not (_G.DownedCheck(ocharacter))
							--
							anim:Stop(0.45)
							tool:SetAttribute("NoArmMovement", false)
							remoteEvent:FireClient(plr, "GuiAction", {typ = "end"})
							_G.SafeDestroy(FORCEFEEDING_ID)
							_G.SafeDestroy(FORCEFEEDING_SP)
							_G.SafeDestroy(FORCEFEEDING_B)
							_G.SafeDestroy(FORCEFEEDING_DHAR)
							_G.SafeDestroy(forceFeedGyro)
							_G.SafeDestroy(at)
							--
							if (os.clock() - forceFeedOs) >= 4 then
								--
								local se
								if tool.Name=="T-X" then
									se=game.ServerStorage.CharacterScripts.Effects.TX:Clone()
								elseif tool.Name=="G-X" then
									se=game.ServerStorage.CharacterScripts.Effects.GX:Clone()
								end
								--
								if se then
									se.Parent=ocharacter
									se.Enabled=true
									--
									ocharacter.Humanoid.Health=25
								end
								--
								tool:Destroy()
							end
							--
						end
						--
					end
					--
				elseif (data.typ == "cancel") then
					--
					if (_G.DoesCharAffectExist(character, "CUTTINGROPE")) then
						charactervf.Currents.CUTTINGROPE:Destroy() end
					--
					if (_G.DoesCharAffectExist(character, "FORCEFEEDING")) then
						charactervf.Currents.FORCEFEEDING:Destroy() end
					--
				end
			end
			--
		end,
		--
	}
	--
	remoteEvent.OnServerEvent:Connect(function(plr, action, data) 
		remoteEvents[action](plr, data) end)
	-- Remote Functions

	local remoteFunctions = {}
	remoteFunctions = {
		--
		["TextBounds"] = function(plr, text)
			local par = Instance.new("GetTextBoundsParams")
			par.Text = text.Text
			par.Font = Font.new(text.Font, Enum.FontWeight.Thin)
			par.Size = text.Size
			par.Width = text.Width
			--
			local retu
			local succ, ret = pcall(function() 
				retu = game:GetService("TextService"):GetTextBoundsAsync(par) end)
			--
			if (succ) then
				return retu
			else
				task.wait(0.5) return remoteFunctions["TextBounds"](text) end
			--
		end,
		--
		["PassiveRequest"] = function(plr)
			local plrChar = plr.Character
			local canPassive=true
			if (replicatedStorage.Values.DisablePassive.Value or not marketPlaceService:UserOwnsGamePassAsync(plr.UserId,891463636)) and not plr:GetAttribute("passiveAccessGranted") then
				canPassive=false
			end
			if (plrChar and plrChar.Parent) and canPassive then
				if (plrChar:GetAttribute("passive") ~= true) then
					local suitable = true
					--
					local function checktool(tool)
						if (tool.Name ~= "Fists" and tool:GetAttribute("safeInPassive") ~= true) then
							suitable = false
						end
					end
					-- Checks

					if ((os.clock() - plrChar:GetAttribute("spawnOs")) >= 120) then
						suitable = false end
					if (_G.InCombatCheck(plr, true)) then
						suitable = false end
					-- Tools

					for _, tool in ipairs(plr.Backpack:GetChildren()) do
						checktool(tool) end
					if (plrChar:FindFirstChildOfClass("Tool")) then
						checktool(plrChar:FindFirstChildOfClass("Tool")) end
					-- Final

					if (suitable) then
						--
						plrChar:SetAttribute("passive", true)
						local ff = _G.Create("ForceField", "passive", plrChar, {{"Visible", false}})
						ff:SetAttribute("passive", true)
						for _, fx in ipairs(script.passivefx:GetChildren()) do
							if (fx:IsA("BillboardGui")) then
								fx.PlayerToHideFrom = plr end
							fx:Clone().Parent = plrChar.HumanoidRootPart.RootAttachment end
						plrChar.Humanoid:UnequipTools()
						if (plr.Backpack:FindFirstChild("Fists")) then
							plr.Backpack["Fists"]:Destroy() end
						--
						return true
					else
						game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(plr,{"Passive Requirements: NOT IN COMBAT, NO UNSAFE TOOLS, <2 MINUTES SINCE SPAWN",1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
						return false
					end
					--
				else
					game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(plr,{"Can't exit passive once enabled, reset if you wanna disable it.",1,Color3.fromRGB(255, 121, 121),Color3.new(0,0,0),"lost"}) 
					return false
				end
			end
		end,
		--
	}
	--
	remoteFunction.OnServerInvoke = function(plr, action, data)
		return remoteFunctions[action](plr, data) end
	-- Bindable Events

	local bindableEvents = {
		--
		["RunModule"] = function(data)
			local module = data.module
			local runfunction = (data.runner or data.runfunction or data.run or nil)
			if (runfunction) then
				require(module)[runfunction](data.data) else
				require(module)(data.data) end
		end,
		--
	}
	--
	bindableEvent.Event:Connect(function(action, data)
		bindableEvents[action](data) end)
	--
end