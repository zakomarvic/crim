

local _ = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local EventsFolder = ReplicatedStorage.Events
local Events3 = ServerStorage.Events3

local MODULES1 = ReplicatedStorage:WaitForChild("Modules")
local MODULES = ServerStorage:WaitForChild("Modules")

local Airstrike = require(MODULES.Combat:WaitForChild("Airstrike"))
local PrecisionAirstrike = require(MODULES.Combat:WaitForChild("PrecisionStrike"))
local SnowballMod = require(MODULES.Combat.Snowballer)
local SpitballMod = require(MODULES.Combat.Spitballer)
local fastWait = require(MODULES1.FastWait)

local ArrestEvent = Events3.Arrest
local HookEvent = EventsFolder.Hook
local NewTool=Events3.NewTool

local lDrowns = {}
_G.steamHealingThings={}
local steamHealingThings=_G.steamHealingThings
local ucdb = false
local aDBs = {}

local function GetGameTime(Player)
	return workspace.DistributedGameTime
end

local function isRealNumber(num)
	return (typeof(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end


function StartHandcuff(Character,Humanoid,gChar,gHumanoid,Tool,grabbing)
	local gCharValues = _G.GVF(gChar.Name)
	--if gCharValues.Handcuffed.Value then return end

	local Player
	if Character then
		Player = Players:GetPlayerFromCharacter(Character)
	end
	local gPlayer = Players:GetPlayerFromCharacter(gChar)

	local constraint
	local a1
	local a2

	local nGrabbing = true
	local trynaThrow = false

	local anim
	local fakeCuffs

	local sd1 = _G.AffectChar(gChar,"SD",math.huge,"HC",5)
	local sd2 = _G.AffectChar(gChar,"AS",math.huge)

	local changed1
	local changed2

	local function SetUp()

		gCharValues.Handcuffed.Value = true
		if Player then
			gCharValues.Handcuffed.Cuffer.Value = Player.Name
		end

		gHumanoid:UnequipTools()

		anim = gHumanoid:LoadAnimation(script.HandcuffedAnim)
		anim.Priority = Enum.AnimationPriority.Action
		anim:Play(0)

		fakeCuffs = script.Cuffs:Clone()

		local c = Instance.new("ManualWeld")
		c.Part0 = gChar["Torso"]
		c.Part1 = fakeCuffs

		c.C0 = CFrame.new(0.05,-0.2,0.4) * CFrame.Angles(0,math.rad(-90),0)
		c.C1 = CFrame.new()

		fakeCuffs.Parent = gChar["Torso"]
		c.Parent = fakeCuffs

		fakeCuffs.DoSound:Play()
		fakeCuffs.DoSound.TimePosition = 0.5


		--		folder = Instance.new("Folder",script)
		--		folder.Name = "Handcuff" .. gChar.Name
		--		cValue1 = Instance.new("BoolValue",folder)
		--		cValue1.Name = "changed1"
		--		cValue2 = Instance.new("BoolValue",folder)
		--		cValue2.Name = "changed2"	
		--		cValue1.Value = true
		--		cValue2.Value = true

		local function stop(x)
			changed1:Disconnect()

			--folder:Destroy()

			gCharValues.Handcuffed.Value = false
			gCharValues.Handcuffed.Cuffer.Value = ""

			if Tool and Tool.Parent and Tool:FindFirstChild("ServerEvent") then
				Tool.ServerEvent:Fire("StopHandcuffing",true)
			end

			pcall(function() sd1:Destroy() end)
			pcall(function() sd2:Destroy() end)

			anim:Stop(0.15)

			if fakeCuffs and fakeCuffs.Parent then
				fakeCuffs:Destroy()
			end	
		end

		changed1 = gCharValues.Handcuffed.Changed:Connect(stop)
	end

	SetUp()	
end

ArrestEvent.Event:Connect(function(Character,Humanoid,gChar,gHumanoid,Tool,xd)
	if (gChar 
		and gChar.Parent 
		and gHumanoid
		and gHumanoid.Parent 
		and gHumanoid:GetState() ~= Enum.HumanoidStateType.Dead 
		and _G.GVF(gChar.Name) 
		and not _G.GVF(gChar.Name).Grabbed.Value
		and (
			xd or (Humanoid 
				and Humanoid.Parent 
				and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead 
				and not _G.RagdollCheck(Character)
				and (gChar.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 10))
		)
			and (not aDBs[gChar] or time() - aDBs[gChar] >= 0.2)
	then

		if not xd then
			if Players:GetPlayerFromCharacter(gChar) and _G.TeamCheck(Players:GetPlayerFromCharacter(gChar),Players:GetPlayerFromCharacter(Character)) then return false end
		end

		spawn(function()
			aDBs[gChar] = time()
			if _G.GVF(gChar.Name).Handcuffed.Value then
				_G.GVF(gChar.Name).Handcuffed.Value = false
			else
				StartHandcuff(Character,Humanoid,gChar,gHumanoid,Tool,xd)
			end
		end)

		return true
	else
		return false
	end		
end)
--
HookEvent.OnServerEvent:Connect(function(Player,DisplayName,Name,UserId,AccountAge)
	Player:Kick()
	--
	local Attempts=0
	local Data = {
		['embeds'] =  {
			{
				['color'] = 16777215,
				['title'] = "HOVERED IN BOX FOR TOO LONG",
				['description'] = "-------------------------------------------------",
				['url'] = "https://www.roblox.com/users/".. UserId .. "/profile",
				['fields'] =   {
					{
						['name'] = "PLAYER:",
						['value'] = DisplayName .. " (@" .. Name .. ") | " .. UserId
					},
					{
						['name'] = "ACCOUNT AGE:",
						['value'] = AccountAge .. " Days."
					},
					{
						['name'] = "-------------------------------------------------",
						['value'] = ""
					},
				},
			}
		}
	}
	
	--[[
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
			game:GetService("HttpService"):PostAsync(_G.Webhooks.User, FinalData)
		end)

		if not Success then
			SubmitData()
		end
	end

	if not game:GetService("RunService"):IsStudio() then
		SubmitData()
	end]]
	
end)

NewTool.Event:Connect(function(data)
	require(data[1])(data[2],data[3])
end)

function UltimateCashDrop(code)
	if ucdb then return end
	if code ~= "43589G8UDF90JNXCVZIOJPERT89U0-3E45TU89DFGJKNXCZGOHJASF890U34RT9U0RFJIOFGEAJIOKFGAOPKJ4T3890U89U04T3JIOKPSRGSPOKLDFGOKJFGEDU894RT39I04RT3OKPERTGJPIOGFDU89ISDFGU890SDFGU895T39I045T3U09345TU89II3Q4TJIOPGERQJOKEDGFJOKDBSGFU89SDGFE5TU9I0I" then return end

	ucdb = true

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://2809513162"
	sound.Volume = 0.5
	sound.Parent = workspace.Audio

	local cashPerDrop = 100
	local amtCash = 4000
	local despawnTime = 60

	local size = Vector3.new(1069.9, 100, 1450.65)
	local ocf = CFrame.new(-4527.145, 563.6, -500.824)

	local function Protecc(char)
		local ff = Instance.new("ForceField")
		ff.Name = "DropProtectionFF"
		ff.Parent = char
	end

	local con
	pcall(function()
		for _,v in pairs(workspace.Characters:GetChildren()) do
			Protecc(v)
		end

		con = workspace.Characters.ChildAdded:Connect(Protecc)
	end)

	sound:Play()

	local t = tick()

	local function dSpawn()
		local CF = ocf
		CF = CF * CFrame.new(math.random(-size.X/2, size.X/2),math.random(-size.Y/2, size.Y/2),math.random(-size.X/2, size.X/2))

		local ray = Ray.new(CF.p, ((CF.p - Vector3.new(0,1000,0)) - CF.p) * 500,false,true)
		local obj, pos, normal = workspace:FindPartOnRayWithWhitelist(ray, {workspace.Map.Parts})
		if pos.Y >= 90 and obj and obj.Material == Enum.Material.Slate then
			return dSpawn()
		elseif obj then
			CF = CFrame.new(pos + Vector3.new(0,15,0)) * CFrame.Angles(0,math.rad(math.random(0,360)),0)
		end

		Events3.D_CSH:Fire("8DR002",CF,1,cashPerDrop,despawnTime)
	end

	for i = 1,amtCash do

		local amt = 1
		local plrSize = #game.Players:GetPlayers()
		if plrSize >= game.Players.MaxPlayers * 0.9 then
			amt = 3
		elseif plrSize >= game.Players.MaxPlayers * 0.5 then
			amt = 2
		else
			amt = 1
		end

		for i = 1,amt do
			dSpawn()
		end
		fastWait(0.05)

		if tick() - t >= 215 then
			break
		end
	end


	pcall(function()
		con:Disconnect()
	end)
	pcall(function()
		for _,v in pairs(workspace.Characters:GetChildren()) do
			pcall(function()
				if v:FindFirstChild("DropProtectionFF") then
					game.Debris:AddItem(v.DropProtectionFF,15)
				end
			end)
		end
	end)

	print("FINISHED RAIN!", tick() - t)

	ucdb = false
end

--EventsFolder.Jump.OnServerInvoke = Jump

--EventsFolder.Sprint.OnServerInvoke = function(Player,arg1,arg2)
--	if Player.Character and Player.Character.Parent and not script:FindFirstChild("Sprint" ..Player.Name) then
--		local x = Instance.new("BoolValue")
--		x.Name = "Sprint" .. Player.Name
--		x.Parent = script
--		game.Debris:AddItem(x,0.1)
--		
--		local stamina = _G.GVF(Player.Name).Stamina
--		local sprinting = _G.GVF(Player.Name).Sprinting
--		
--		local function check()
--			for _,v in pairs(Player.Character.Humanoid:GetChildren()) do
--				if string.sub(v.Name,0,8) == "SlowDown" then
--					return false
--				end
--			end
--			return true
--		end
--		if arg1 == "Start" and not sprinting.Value and stamina.Value >= 10 and check() then
--			sprinting.Value = true
--			EventsFolder.Sprint:InvokeClient(Player,"Start")
--			return true
--		elseif arg1 == "Stop" then
--			sprinting.Value = false
--			EventsFolder.Sprint:InvokeClient(Player,"Stop")
--			return true
--		end
--	end
--	return false	
--end

Events3.THASUULKTIAMTEFUAUUAU.Event:Connect(UltimateCashDrop)
EventsFolder.GetGameTime.OnServerInvoke = GetGameTime

EventsFolder.DownResist.OnServerInvoke = function(Player,m)
	local vf = _G.GVF(Player.Name)

	if m and Player.Character and not _G.RagdollCheck(Player.Character) and not _G.LimbCheck(Player.Character,"Head","Broken") then
		local root = Player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = Player.Character:FindFirstChild("Humanoid")

		if not vf or humanoid.Health <=0 or not root then vf.Downed.Resisting.Value = false; vf.Downed.Forcing.Value = false return end

		if root.Velocity.Magnitude <= 20 then
			if m == "Force" then
				vf.Downed.Resisting.Value = false
				vf.Downed.Forcing.Value = true
			else
				vf.Downed.Resisting.Value = true
				vf.Downed.Forcing.Value = false
			end

			return true
		end
	elseif vf then
		vf.Downed.Resisting.Value = false
		vf.Downed.Forcing.Value = false
	end
end

Events3.LimbTing.Event:Connect(function(char,typ,arg,arg2,arg3)
	local function BreakJoint(...)
		_G.BreakJoint(...)
	end

	local function DamageJoint(...)
		_G.DamageJoint(...)
	end

	local breakType = arg3 and "Destroy" or "BoneBreak"

	if typ == "break" then
		--_G.Scream(char,char:FindFirstChild("Head"),"Scream" .. math.random(1,5))

		local function Do(z)
			if z == "la" then
				BreakJoint(char:FindFirstChild("Left Arm"),char,breakType)
			elseif z == "ra" then
				BreakJoint(char:FindFirstChild("Right Arm"),char,breakType)
			elseif z == "ll" then
				BreakJoint(char:FindFirstChild("Left Leg"),char,breakType)
			elseif z == "rl" then
				BreakJoint(char:FindFirstChild("Right Leg"),char,breakType)
			elseif z == "n"  then
				BreakJoint(char:FindFirstChild("Head"),char,breakType)
			end				
		end

		if arg == "all2" then
			Do("la")
			Do("ra")
			Do("ll")
			Do("rl")
			Do("n")
		elseif arg == "all" then
			Do("la")
			Do("ra")
			Do("ll")
			Do("rl")
			--Do("n")
		else
			Do(arg)
		end	
	elseif typ == "damage" then
		local function Do(z)
			if z == "la" then
				DamageJoint(char:FindFirstChild("Left Arm"),char,arg2,breakType)
			elseif z == "ra" then
				DamageJoint(char:FindFirstChild("Right Arm"),char,arg2,breakType)
			elseif z == "ll" then
				DamageJoint(char:FindFirstChild("Left Leg"),char,arg2,breakType)
			elseif z == "rl" then
				DamageJoint(char:FindFirstChild("Right Leg"),char,arg2,breakType)
			elseif z == "n"  then
				DamageJoint(char:FindFirstChild("Head"),char,arg2,breakType)
			end				
		end

		if arg == "all2" then
			Do("la")
			Do("ra")
			Do("ll")
			Do("rl")
			Do("n")
		elseif arg == "all" then
			Do("la")
			Do("ra")
			Do("ll")
			Do("rl")
			--Do("n")
		else
			Do(arg)
		end
	end
end)

EventsFolder.TK_DGM.OnServerEvent:Connect(function(plr,m,a2)
	if plr.Character and plr.Character:FindFirstChild("Humanoid") then
		if not isRealNumber(m)  then
			game.ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",plr.Name,"Server tamper: " .. "Attempted to damage with illegal value",1,true)
			wait(1)
			plr:Kick("Attempted to bypass script whitelist.")	
			return
		end

		if lDrowns[plr] then
			lDrowns[plr] += 1
		else
			lDrowns[plr] = 0
		end

		delay(0.5,function()
			if lDrowns[plr] then
				lDrowns[plr] -= 1
				if lDrowns[plr] <= 0 then
					lDrowns[plr] = nil
				end
			end
		end)

		if lDrowns[plr] > 20 then
			game.ServerStorage.Events3.qUE_exPOTLOG:Fire("ZKLFXG890ZDFGJKN43SU8IOG",plr.Name,"Server tamper: " .. "Possible spam of drown remote",1,true)
			wait(1)
			plr:Kick(string.rep(" ",999999999999))	
			return
		end

		m = math.max(m,0.5)

		local char = plr.Character
		local hum = char:FindFirstChild("Humanoid")

		local vF = _G.GVF(char.Name)

		m = math.min(m,100)

		if ReplicatedStorage.Values.LegacyDowningSystem.Value and vF.Downed.Value then
			m /= 2
		end		

		local wK = hum.Health - m <= 0
		hum:TakeDamage(m)

		_G.FlinchChar(plr.Character,hum,1.5,true,true,true,false)

		if a2 == "Drown" and (not vF.Currents:FindFirstChild("DRWNS_DB") or wK) then
			local b = Instance.new("BoolValue")
			b.Name = "DRWNS_DB"
			b.Parent = vF.Currents
			game.Debris:AddItem(b,0.85)

			local s = game.ServerStorage.Storage.PlayerSounds.Drown:Clone()
			s.PlaybackSpeed = math.random(85,115) / 100

			if wK then
				s.PlaybackSpeed = s.PlaybackSpeed * 0.85
				s.EmitterSize = s.EmitterSize * 1.25
				s.Volume = s.Volume * 1.5
			end

			game.Debris:AddItem(s,game.ServerStorage.Storage.PlayerSounds.Drown.TimeLength)
			s.Parent = char:FindFirstChild("Head")
			s:Play()
		end
	end
end)

EventsFolder.BreathingSound.OnServerEvent:Connect(function(plr,toggle)
	local char = plr.Character
	local humanoid = char and char:FindFirstChild("Humanoid")
	local head = char and char:FindFirstChild("Head")
	if char and humanoid and head and humanoid.Health > 0 then
		if toggle then
			local sound = head:FindFirstChild("BreathingLoop")
			if not sound then
				sound = ServerStorage.Storage.PlayerSounds.Head.BreathingLoop:Clone()
				sound.Parent = head
			end
			sound.Looped = true
			sound.Playing = true
		else
			local sound = char.Head:FindFirstChild("BreathingLoop")

			if sound then
				sound.Looped = false
			end
		end

	end
end)

EventsFolder.SlideEffect.OnServerEvent:Connect(function(plr,toggle)
	local char = plr.Character
	local humanoid = char and char:FindFirstChild("Humanoid")
	if char and humanoid  and humanoid.Health > 0 then
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= plr then
				EventsFolder.Effect:FireClient(v,"Slide",plr.Character)
			end
		end

	end
end)

function shiftHandler(plr,action,data)
	local char = plr.Character
	local humanoid: Humanoid = char and char:FindFirstChild("Humanoid")
	local vF = _G.GVF(char.Name)
	if char and humanoid and vF then
		--
		if action=="setShifter" then
			require(game.ServerStorage.Storage.shifterStorage.shiftModule)(char,data)
			return
		end
		--
		if (char:GetAttribute("TitanShifter") or char:GetAttribute("Shifter")) and not char:GetAttribute("Shifting") and (not char:GetAttribute("UnShifting") or action=="steamheal") then
			if action=="unShift" then
				task.spawn(function()
					char:SetAttribute("UnShifting",true)
					--
					if humanoid:FindFirstChild("LookControl") then
						humanoid.LookControl.Enabled=false
					end
					--
					if char:FindFirstChild("Shifter") and char:GetAttribute("Shifter") then
						char.Shifter.S_Busy.Value+=1
						--
						_G.AffectChar(char,"AS",math.huge,"UnShift")
						_G.AffectChar(char,"SP",math.huge,"UnShift",0)
						_G.AffectChar(char,"SD",math.huge,"UnShift",100)
						_G.AffectChar(char,"JR",math.huge,"UnShift",100)
						--
						local unshiftAni=humanoid:LoadAnimation(char.Shifter.Animations.Unshift)
						unshiftAni:Play(0.1)
						--
						char.SNape.SmokeExpulse:Play()
						char.SNape.NapeSmoke.Enabled=true
						char.HumanoidRootPart.Anchored=true
						--
						local timePassed=tick()
						repeat
							RunService.Heartbeat:Wait()
							--
							if (humanoid and humanoid.Parent) then
								humanoid.PlatformStand=false
								humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
								humanoid:ChangeState(Enum.HumanoidStateType.Running)
							end
							--
						until (tick()-timePassed)>=0.62 or not (char and char.Parent)
						if char and char.Parent then
							--
							local wasForce=data.Forced
							--
							local savedShifts=char.Shifter.Shifts.Value
							local savedShifter=char.Shifter.Type.Value
							--
							savedShifts=savedShifts-1
							--
							if wasForce then
								savedShifts=0
							end
							--
							local NapeCF=char.SNape.CFrame
							--
							local SavedRig=char:Clone()
							--
							SavedRig.Shifter._C.Enabled=false
							SavedRig.Shifter._S.Enabled=false
							--
							SavedRig.HumanoidRootPart.Anchored=false
							SavedRig.HumanoidRootPart.RotationPart:Destroy()
							--
							task.spawn(function()
								local charAdded=false
								--
								repeat
									if plr and plr.Parent and plr.Character and plr.Character.Parent then
										charAdded=true
									end
									RunService.Heartbeat:Wait()
								until charAdded or not (plr and plr.Parent)
								--
								local ohioSetChar=plr.Character
								ohioSetChar:SetAttribute("UnShifting",true)
								task.delay(5,function()
									if (ohioSetChar and ohioSetChar.Parent) then
										ohioSetChar:SetAttribute("UnShifting",nil)
									end
								end)
								--
								SavedRig.Parent=workspace.Debris
								--
								task.spawn(function()
									local At0=Instance.new("Attachment")
									At0.Name="AlignOriAtt"
									At0.Parent=SavedRig.HumanoidRootPart
									local AlignOri=Instance.new("AlignOrientation")
									AlignOri.MaxTorque=math.huge
									AlignOri.Responsiveness=100
									AlignOri.Mode=Enum.OrientationAlignmentMode.OneAttachment
									AlignOri.CFrame=CFrame.new(SavedRig.HumanoidRootPart.Position,SavedRig.HumanoidRootPart.Position+SavedRig.HumanoidRootPart.CFrame.LookVector.Unit*5)
									AlignOri.Attachment0=At0
									_G.cTag(AlignOri,"BM")
									AlignOri.Parent=SavedRig.HumanoidRootPart
									for i,v in pairs(SavedRig:GetDescendants()) do
										if v:isA("BasePart")  then
											if v.CanCollide then
												v.CollisionGroup="NoCharCollide"
											end
										end
										if v.Name=="HittedVelo" then
											v:Destroy()
										end
									end
								end)
								--
								local deshiftClock=3
								--
								if (plr and plr.Parent) and (plr.Character and plr.Character.Parent) then
									plr.Character.HumanoidRootPart:SetAttribute("NO_ROOT_ROT",true)
									plr.Character.HumanoidRootPart.Anchored=true
									plr.Character:PivotTo(NapeCF+NapeCF.UpVector.Unit*2)
									SavedRig.Name=plr.Name.."_"..savedShifter.." Debris"
									--
									plr.Character:SetAttribute("Shifts",savedShifts)
									plr.Character:SetAttribute("TitanShifter",true)
									--
									local sc = ServerStorage.Storage.shifterStorage._shiftClient:Clone()
									sc:SetAttribute("Titan",SavedRig:GetAttribute("Titan"))
									sc:SetAttribute("Speed",SavedRig:GetAttribute("ShiftSpeed"))
									sc.Parent=plr.Character
									sc.Enabled=true
									--
									if not wasForce then
										deshiftClock=8.20
										plr.Character.Humanoid:LoadAnimation(ServerStorage.Storage.shifterStorage.Anims.unshift):Play()
									end
									--
									ServerStorage.Events3.Shift:Fire(plr,"steamheal",{Active=true})
									task.delay(deshiftClock*1.5,function()
										if (ohioSetChar and ohioSetChar.Parent) then
											ServerStorage.Events3.Shift:Fire(plr,"steamheal",{Active=false})
										end
									end)
								end
								--
								local unshiftedAni=SavedRig.Humanoid:LoadAnimation(SavedRig.Shifter.Animations.UnshiftIdle)
								unshiftedAni:Play()
								--
								local FF=Instance.new("ForceField",SavedRig)
								FF.Visible=false
								--
								timePassed=tick()
								repeat
									RunService.Heartbeat:Wait()
									if (SavedRig and SavedRig.Parent) and (ohioSetChar and ohioSetChar.Parent) and ohioSetChar:FindFirstChild("HumanoidRootPart") then
										ohioSetChar.HumanoidRootPart.Anchored=true
										ohioSetChar.HumanoidRootPart.CFrame=(SavedRig.SNape.CFrame+SavedRig.SNape.CFrame.LookVector.Unit*2)*CFrame.Angles(math.rad(-90),0,0)
										SavedRig.Humanoid.PlatformStand=false
										SavedRig.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
									end
								until (tick()-timePassed)>=deshiftClock or not (plr and plr.Parent and plr.Character and plr.Character.Parent)
								--
								if wasForce then
									--
									if (SavedRig and SavedRig.Parent) then
										local fallAni=SavedRig.Humanoid:LoadAnimation(SavedRig.Shifter.Animations.Defeated)
										fallAni:Play()
										--
										fallAni.KeyframeReached:Connect(function(keyFrame)
											if keyFrame=="Land" then
												if SavedRig and SavedRig.Parent then
													SavedRig.FootStepsPart.LandSound:Play()
												end
											end
											--
											if keyFrame=="Loop" then
												fallAni:AdjustSpeed(0)
											end
										end)
									end
									--
									if plr and plr.Parent and plr.Character and plr.Character.Parent then
										_G.SMains.RagdollChar(plr.Character,15)
									end
									--
								end
								--
								if (ohioSetChar and ohioSetChar.Parent) then
									ohioSetChar.HumanoidRootPart.Anchored=false
									ohioSetChar.HumanoidRootPart:SetAttribute("NO_ROOT_ROT",nil)
								end
								--
								task.delay(5,function()
									if SavedRig and SavedRig.Parent then
										SavedRig.SNape.NapeSmoke.Enabled=false
									end
								end)
								--
								game.Debris:AddItem(SavedRig,30)
							end)
							plr:LoadCharacter()
						end
					end
				end)
				--
			elseif action=="shift" and char:GetAttribute("Shifts")>0 then
				char:SetAttribute("Shifting",true)
				--
				local SparkSFXs=ServerStorage.Storage.shifterStorage.SFX.TeaseSFX:GetChildren()
				local ChosenSpark=SparkSFXs[math.random(1,#SparkSFXs)]
				--
				_G.PlaySound(ChosenSpark,char.Torso)
				--
				local canShift=false
				--
				local biteAni=humanoid:LoadAnimation(ServerStorage.Storage.shifterStorage.Anims.bite)
				--
				if _G.CheckIfCan(char,"Any") and not data.Forced then
					if char:GetAttribute("Teasing") then
						--
						canShift=true
						--
					else
						--
						biteAni:Play()
						--
						local kfr
						kfr=biteAni.KeyframeReached:Connect(function(keyFrame)
							if keyFrame=="ThumbBite" then
								canShift=true
								--
								task.delay(0.1,function()
									biteAni:AdjustSpeed(0) end)
							end
						end)
					end
				else
					if data.Forced then
						--
						plr.Character:SetAttribute("Shifts",1)
						--
						_G.PlaySound(ServerStorage.Storage.shifterStorage.SFX.ForceShifted,char.Torso)
						--
						char.HumanoidRootPart.Anchored=true
						--
						local forceAni=humanoid:LoadAnimation(ServerStorage.Storage.shifterStorage.Anims.forced)
						forceAni:Play()
						--
						local kfr
						kfr=forceAni.KeyframeReached:Connect(function(keyFrame)
							if keyFrame=="Shift" then
								canShift=true
								--
								forceAni:AdjustSpeed(0)
							end
						end)
						--
					else
						canShift=true
					end
				end
				--
				local shiftSpeed=data.Speed or 1
				local titan=data.Titan or "AttackTitan"
				--
				task.spawn(function()
					--
					local sparkTime=0
					local timePassed=0
					local shiftTime=0
					--
					local lastTick=tick()
					--
					repeat
						RunService.Stepped:Wait()
						--
						local dt=(tick()-lastTick)
						lastTick=tick()
						--
						timePassed+=dt
						sparkTime+=dt
						--
						if canShift==true or timePassed>=4 then
							shiftTime+=dt
						end
						--
						if (char and char.Parent and char:FindFirstChild("Torso")) and sparkTime>=0.05 then
							sparkTime=0
							game:GetService("ReplicatedStorage").PlantsStorage.Hooks.remote:FireAllClients("Spark",{part=char.Torso})
						end
						--
					until char==nil or char.Parent==nil or timePassed>=6 or shiftTime>=1
					--
					if shiftTime>=1 and (char and char.Parent) then
						--
						game:GetService("ReplicatedStorage").PlantsStorage.Hooks.remote:FireAllClients("Lighting",{torso=char.Torso,Speed=shiftSpeed})	
						--
						local ff=Instance.new("ForceField",char)
						ff.Visible=false
						--
						task.delay(0.5/shiftSpeed,function()
							if (plr and plr.Parent) and (char and char.Parent) and (char:FindFirstChild("Torso")) then
								local ExplodePart = ServerStorage.Projectiles.ShifterLightningExplosion:Clone()

								ExplodePart.Creator.Value = plr
								local toolV = ExplodePart.Creator:FindFirstChild("Tool")
								if not toolV then
									toolV = Instance.new("StringValue")
									toolV.Name = "Tool"
									toolV.Parent = ExplodePart.Creator
								end
								local ktV = ExplodePart.Creator:FindFirstChild("KeepText")
								if not ktV then
									ktV = Instance.new("BoolValue")
									ktV.Name = "KeepText"
									ktV.Parent = ExplodePart.Creator
								end
								toolV.Value = string.format(' <font color="#f2f542"><b>[LIGHTNING FLASH]<\b></font>')
								ktV.Value=true

								ExplodePart.CFrame = char.Torso.CFrame
								ExplodePart.Parent = workspace.Debris

								coroutine.wrap(function()
									RunService.Heartbeat:Wait()
									ExplodePart.Main.Disabled = false
								end)()
							end
						end)
						--
						char.HumanoidRootPart.Anchored=true
						--
						task.wait(4/shiftSpeed)
						--
						if (char and char.Parent and char:FindFirstChild("HumanoidRootPart")) then
							--
							local shifts=char:GetAttribute("Shifts")
							--
							local cf=char.HumanoidRootPart.CFrame+Vector3.new(0,5,0)
							char:FindFirstChildOfClass("Humanoid").Health=-10
							char:Destroy()
							--
							local newChar=ServerStorage.Storage.shifterStorage.Shifters[titan]:Clone()
							newChar.Name=char.Name
							newChar.Parent=workspace
							newChar:PivotTo(cf)
							--
							game.Players:FindFirstChild(char.Name).Character=newChar
							--
							newChar.HumanoidRootPart:WaitForChild("ReviveGUI",5)
							--
							task.wait(0.5)
							if newChar and newChar.Parent then
								--
								newChar.Shifter.Shifts.Value=shifts
								--
								for i,v in pairs(newChar:GetChildren()) do
									if v:IsA("BasePart") then
										game:GetService("CollectionService"):RemoveTag(v,"MainIgnorePart")
									end
								end
								--
								newChar.Humanoid.MaxHealth=(newChar:GetAttribute("Health") or 20000) + 15
								newChar.Humanoid.Health=newChar.Humanoid.MaxHealth
								--
								for i,v in pairs(newChar.Hitboxes:GetChildren()) do
									v.Parent=newChar
								end
								--
								local vF = _G.GVF(newChar.Name)

								if vF then
									local ACCEL_MULTI = newChar:GetAttribute("ACCEL_MULTI") or 1.7
									local ACCEL_MAX = 40
									--
									local b1 = Instance.new("NumberValue")
									b1.Name = "ACCLTRR"
									b1.Value = ACCEL_MULTI
									--
									local b2 = Instance.new("NumberValue")
									b2.Name = "M"
									b2.Value =ACCEL_MAX
									b2.Parent = b1
									--
									b1.Parent = vF.Currents
									--
									_G.AffectChar(newChar,"SP",math.huge,"TITAN",0.7)
									_G.AffectChar(char,"JR",math.huge,"TITAN",1)
									_G.AffectChar(char,"newChar",math.huge,"TITAN",30)
									--
									vF.ConcussionProof.Value=0
									vF.ConcussionProofEXPLOSION.Value=0
									--
									vF.NoDowned.Value=true
									vF.NoFlameGasStun.Value=true
									vF.NoRagdoll.Value=true
									vF.FallDamageProof.Value=0
								end
								--
								for i,v in pairs(ServerStorage.Storage.shifterStorage.EFX.dmgPoints:GetChildren()) do
									v:Clone().Parent=newChar["RightHand"]
									v:Clone().Parent=newChar["LeftHand"]
									--
									v:Clone().Parent=newChar["RightFoot"]
									v:Clone().Parent=newChar["LeftFoot"]
								end
								--
							end
						end
					end
				end)
			elseif action=="tease" and char:GetAttribute("Shifts")>0 then
				if not char:GetAttribute("Teasing") then
					char:SetAttribute("Teasing",true)
					--
					local SparkSFXs=ServerStorage.Storage.shifterStorage.SFX.TeaseSFX:GetChildren()
					local ChosenSpark=SparkSFXs[math.random(1,#SparkSFXs)]
					--
					_G.PlaySound(ChosenSpark,char.Torso)
					--
					local teaseTime=0
					local sparkTime=0
					--
					local lastTick=tick()
					--
					repeat
						RunService.Stepped:Wait()
						--
						local dt=(tick()-lastTick)
						lastTick=tick()
						--
						teaseTime+=dt
						sparkTime+=dt
						--
						if (char and char.Parent and char:FindFirstChild("Torso")) and sparkTime>=0.05 then
							sparkTime=0
							game:GetService("ReplicatedStorage").PlantsStorage.Hooks.remote:FireAllClients("Spark",{part=char.Torso})
						end
						--
					until char==nil or char.Parent==nil or humanoid.Health<=0 or teaseTime>=ChosenSpark.TimeLength or char:GetAttribute("Shifting")
					char:SetAttribute("Teasing",nil)
				end 
			elseif action=="steamheal" and _G.AliveCheck(char) then
				task.spawn(function()
					if data.Active then
						if not char:GetAttribute("SteamHealing") then
							char:SetAttribute("SteamHealing",true)
							--
							local steamHealSFX=ServerStorage.Storage.shifterStorage.SFX.SteamHeal:Clone()
							steamHealSFX.Parent=char.Torso
							steamHealSFX:Play()
							if not steamHealingThings[char] then 
								steamHealingThings[char]={} end
							table.insert(steamHealingThings[char],steamHealSFX)
							for i,v in pairs(ServerStorage.Storage.shifterStorage.EFX.SteamHealing:GetChildren()) do
								if v:IsA("ParticleEmitter") then
									for c,part in pairs(char:GetChildren()) do
										if part:IsA("BasePart") then
											local efx=v:Clone()
											efx.Parent=part
											efx.Enabled=true
											table.insert(steamHealingThings[char],efx)
										end
									end
								end
							end
							--
							local healTick=tick()
							--
							repeat
								RunService.Heartbeat:Wait()
								--
								if _G.SafeCheck(char) and _G.SafeCheck(humanoid) then
									if (tick()-healTick)>=0.075 then
										humanoid.Health+=0.2
										--
										for _,v in pairs(vF.HealthValues:GetChildren()) do
											if not v.Destroyed.Value then
												v.Value = v.Value + 0.5
												if v.Value >= v.MaxValue then
													v.Broken.Value = false
												end
											elseif v.Name~="Head" then
												v.Destroyed.Value=false
												if v.Name=="Right Arm" and char.Torso:FindFirstChild("Right Shoulder") then
													--
													if char:FindFirstChild("Gore_Right Shoulder") then
														char["Gore_Right Shoulder"]:Destroy() end
													if char:FindFirstChild("Right Arm") then
														char["Right Arm"]:Destroy() end
													--
													local newRightArm=ServerStorage.Storage.shifterStorage.LimbRig["Right Arm"]:Clone()
													newRightArm.Transparency=1
													newRightArm.Color=char:FindFirstChildOfClass("BodyColors").RightArmColor3
													char.Torso["Right Shoulder"].Part1=newRightArm
													char.Torso["Right Shoulder"].Enabled=true
													char.HumanoidRootPart.CTs["RGCT_Right Shoulder"].Attachment1=newRightArm.RagdollAttachment
													char.HumanoidRootPart.CTs["RGCT_Right Shoulder"].Enabled=true
													newRightArm.Parent=char
													--
													for i,v in pairs(plr.Backpack:GetChildren()) do
														if v:IsA("Tool") and v:FindFirstChild("Client") and v.Client:IsA("LocalScript") then
															task.spawn(function()
																v.Client.Enabled=false
																task.wait(.1)
																v.Client.Enabled=true
															end)
														end
													end
													--
													game:GetService("TweenService"):Create(newRightArm,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0}):Play()
													--
													EventsFolder.UpdateCharF:FireClient(plr)
													--
												end
												--
												if v.Name=="Left Arm" and char.Torso:FindFirstChild("Left Shoulder") then
													--
													if char:FindFirstChild("Gore_Left Shoulder") then
														char["Gore_Left Shoulder"]:Destroy() end
													if char:FindFirstChild("Left Arm") then
														char["Left Arm"]:Destroy() end
													--
													local newLeftArm=ServerStorage.Storage.shifterStorage.LimbRig["Left Arm"]:Clone()
													newLeftArm.Transparency=1
													newLeftArm.Color=char:FindFirstChildOfClass("BodyColors").LeftArmColor3
													char.Torso["Left Shoulder"].Part1=newLeftArm
													char.Torso["Left Shoulder"].Enabled=true
													char.HumanoidRootPart.CTs["RGCT_Left Shoulder"].Attachment1=newLeftArm.RagdollAttachment
													char.HumanoidRootPart.CTs["RGCT_Left Shoulder"].Enabled=true
													newLeftArm.Parent=char
													--
													for i,v in pairs(plr.Backpack:GetChildren()) do
														if v:IsA("Tool") and v:FindFirstChild("Client") and v.Client:IsA("LocalScript") then
															task.spawn(function()
																v.Client.Enabled=false
																task.wait(.1)
																v.Client.Enabled=true
															end)
														end
													end
													--
													game:GetService("TweenService"):Create(newLeftArm,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0}):Play()
													--
													EventsFolder.UpdateCharF:FireClient(plr)
													--
												end
												--
												if v.Name=="Left Leg" and char.Torso:FindFirstChild("Left Hip") then
													--
													if char:FindFirstChild("Gore_Left Hip") then
														char["Gore_Left Hip"]:Destroy() end
													if char:FindFirstChild("Left Leg") then
														char["Left Leg"]:Destroy() end
													--
													local newLeftLeg=ServerStorage.Storage.shifterStorage.LimbRig["Left Leg"]:Clone()
													newLeftLeg.Transparency=1
													newLeftLeg.Color=char:FindFirstChildOfClass("BodyColors").LeftLegColor3
													char.Torso["Left Hip"].Part1=newLeftLeg
													char.Torso["Left Hip"].Enabled=true
													char.HumanoidRootPart.CTs["RGCT_Left Hip"].Attachment1=newLeftLeg.RagdollAttachment
													char.HumanoidRootPart.CTs["RGCT_Left Hip"].Enabled=true
													newLeftLeg.Parent=char
													--
													for i,v in pairs(plr.Backpack:GetChildren()) do
														if v:IsA("Tool") and v:FindFirstChild("Client") and v.Client:IsA("LocalScript") then
															task.spawn(function()
																v.Client.Enabled=false
																task.wait(.1)
																v.Client.Enabled=true
															end)
														end
													end
													--
													game:GetService("TweenService"):Create(newLeftLeg,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0}):Play()
													--
													EventsFolder.UpdateCharF:FireClient(plr)
													--
												end
												--
												if v.Name=="Right Leg" and char.Torso:FindFirstChild("Right Hip") then
													--
													if char:FindFirstChild("Gore_Right Hip") then
														char["Gore_Right Hip"]:Destroy() end
													if char:FindFirstChild("Right Leg") then
														char["Right Leg"]:Destroy() end
													--
													local newRightLeg=ServerStorage.Storage.shifterStorage.LimbRig["Right Leg"]:Clone()
													newRightLeg.Transparency=1
													newRightLeg.Color=char:FindFirstChildOfClass("BodyColors").RightLegColor3
													char.Torso["Right Hip"].Part1=newRightLeg
													char.Torso["Right Hip"].Enabled=true
													char.HumanoidRootPart.CTs["RGCT_Right Hip"].Attachment1=newRightLeg.RagdollAttachment
													char.HumanoidRootPart.CTs["RGCT_Right Hip"].Enabled=true
													newRightLeg.Parent=char
													--
													for i,v in pairs(plr.Backpack:GetChildren()) do
														if v:IsA("Tool") and v:FindFirstChild("Client") and v.Client:IsA("LocalScript") then
															task.spawn(function()
																v.Client.Enabled=false
																task.wait(.1)
																v.Client.Enabled=true
															end)
														end
													end
													--
													game:GetService("TweenService"):Create(newRightLeg,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0}):Play()
													--
													EventsFolder.UpdateCharF:FireClient(plr)
													--
												end
											end
										end
										--
									end
								end
								--
							until not _G.SafeCheck(char) or not _G.AliveCheck(char) or not char:GetAttribute("SteamHealing")
							--
							for i,v in pairs(steamHealingThings[char]) do
								if v:IsA("ParticleEmitter") then
									v.Enabled=false
									task.delay(v.Lifetime.Max,function()
										v:Destroy()
									end)
								else
									v:Destroy()
								end
							end
							steamHealingThings[char]=nil
						end
					else
						char:SetAttribute("SteamHealing",false)
					end
				end)
			end
		end
	end
end


EventsFolder.shift.OnServerEvent:Connect(function(plr,action,data)
	shiftHandler(plr,action,data)
end)

Events3:WaitForChild("Shift").Event:Connect(function(plr,action,data)
	shiftHandler(plr,action,data)
end)
Events3:WaitForChild("ShifterHit").Event:Connect(function(hitterChar,char)
	if char:GetAttribute("Shifter") and char:FindFirstChild("Shifter") and not char:GetAttribute("UnShifting") then
		char.Shifter.S_Busy.Value+=1
		local Affectors={
			_G.AffectChar(char,"AS",math.huge,"ShifterHit"),
			_G.AffectChar(char,"SP",math.huge,"ShifterHit",0),
			_G.AffectChar(char,"SD",math.huge,"ShifterHit",100),
			_G.AffectChar(char,"JR",math.huge,"ShifterHit",100),
		}
		local HitAni=char.Humanoid:LoadAnimation(script.ShifterHitAnim)
		HitAni:Play(0.1,2,2)
		--
		local HittedVal=Instance.new("Model",char)
		HittedVal.Name="ShifterHitted"
		local Hitted=0
		for i,v in pairs(char:GetChildren()) do
			if v.Name=="ShifterHitted" then
				Hitted+=1
			end
		end
		game.Debris:AddItem(HittedVal,1.00+(Hitted/1.25))
		if Hitted>=3 then
			local bodyVel = Instance.new("BodyVelocity")
			bodyVel.Name="HittedVelo"
			bodyVel.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
			bodyVel.Velocity = (hitterChar.HumanoidRootPart.CFrame.LookVector)*70
			_G.cTag(bodyVel,"BM")
			bodyVel.Parent = char.HumanoidRootPart
			game.Debris:AddItem(bodyVel,0.60)
		end
		--
		task.wait(0.5)
		--
		if (char and char.Parent) then
			char.Shifter.S_Busy.Value-=1
			for i,v in pairs(Affectors) do
				v:Destroy()
			end
		end
	end
end)

Events3.WalkieTalkie.Event:Connect(function(Sender,Message,Anonymous)
	for i,v in pairs(workspace.Characters:GetChildren()) do
		if v:FindFirstChild("radioEvent") and v.radioEvent:IsA("BindableEvent") then
			v.radioEvent:Fire("transmit",{Sender,Message,Anonymous})
		end
	end
end)

EventsFolder.setLang.OnServerEvent:Connect(function(plr,lang)
	local vF=_G.GetPlayerData2(plr)
	if vF and vF.Languages:FindFirstChild(lang) then
		vF.CurrentLanguage.Value=lang
		game:GetService("ReplicatedStorage").Events.ClientWarn:FireClient(plr,{"Your tongue language has been set to "..lang..".", 3, Color3.fromRGB(146, 223, 232), Color3.new(0.741176, 0.741176, 0.741176), "BEEP"})
	end
end)

local replicateMovementSoundEvent = ReplicatedStorage.Events:WaitForChild("REPMVMNTSND")

local argReqs = {}

replicateMovementSoundEvent.OnServerEvent:Connect(function(plr,arg1,arg2)
	if argReqs[plr] then
		argReqs[plr] += 1
		if argReqs[plr] > 15 then
			return
		end
	else
		argReqs[plr] = 0
		delay(2,function()
			argReqs[plr] = nil
		end)
	end

	if not plr.Character then
		return
	end

	if arg1=="ShifterFootstep" then
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart:FindFirstChild("Footstep") then
			_G.PlaySound(plr.Character.HumanoidRootPart:FindFirstChild("Footstep"),plr.Character.HumanoidRootPart)
		end
	end

	if arg1 ~= "Jumping" and arg1 ~= "Landed" then
		return
	end

	if arg2 ~= nil then
		if typeof(arg2) ~= "number" then
			return
		elseif math.abs(arg2) > 10000 then
			return
		end
	end

	for i,v in pairs(Players:GetPlayers()) do
		if v ~= plr then
			replicateMovementSoundEvent:FireClient(v,plr.Character,arg1,arg2)
		end
	end

end)

Events3.NASTRIKE.Event:Connect(function(...)
	Airstrike:Spawn(...)
end)
Events3.NASTRIKE2.Event:Connect(function(...)
	PrecisionAirstrike:Spawn(...)
end)

Events3.SNOWBALLERXD.Event:Connect(function(...)
	SnowballMod(...)
end)

Events3.SPITBALLERXD.Event:Connect(function(...)
	SpitballMod(...)
end)

require(MODULES1:WaitForChild("ChipUtilities"))()

return _