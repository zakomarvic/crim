local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fastWait = require(ReplicatedStorage.Modules.FastWait)

local EventsHandler = require(game.ServerScriptService.Game.EventsHandler)

local M = {}

M.OriginalStates = {}

function M.Toggle(mode,audio,wasManual,customShakeMulti,customBrightnessMulti,customContrastMulti)
	if M.Busy then return end
	M.Busy = true
	
	if mode == nil then
		mode = not M.Enabled
	end
	
	if mode then
		M.Enabled = true
		
		if M.Audio then
			pcall(function()
				M.Audio:Destroy()
			end)
		end
		if audio then
			local s = "Blackout_On"
			if audio == "NoAlarm" then
				s = "Blackout_OnNoAlarm"
			end
			M.Audio = script[s]:Clone()
			M.Audio.Parent = workspace.Audio
			if not M.Audio.IsLoaded then 
				-- if not, wait until it has been
				M.Audio.Loaded:Wait()
			end
			M.Audio:Play()
			fastWait(11.5)
			
			local p1 = Instance.new("Part")
			game.Debris:AddItem(p1,30)
			p1.Anchored = true
			p1.Transparency = 1
			p1.CanCollide = false
			
			p1.Parent = workspace.Debris
			p1.CFrame = workspace.Filter.MapArea.CFrame
			
			local s2 = M.Audio:Clone()
			s2.Playing = false
			s2.Volume = 0.001
			s2.Parent = p1
			
			s2.TimePosition = M.Audio.TimePosition
			s2:Play()

			ReplicatedStorage.Events.ExplosionEffect:FireAllClients(p1,s2,
				{
					s2 --s
					,M.Audio.TimeLength -- time
					,10000 -- distance
					,1
					,customShakeMulti or 1
					,customBrightnessMulti or 1
					,customContrastMulti or nil
				}
			)
		end
		local function CheckT(x)
			for i,v in pairs(x:GetDescendants()) do
				if v:IsA("BasePart") then
					if v.Material == Enum.Material.Neon then
						local t = {}
						t.Color = v.Color
						
						if v:IsA("UnionOperation") then
							t.UsePartColor = v.UsePartColor
							v.UsePartColor = true
						end
						
						if not M.OriginalStates[v] then
							M.OriginalStates[v] = t
						end
						v.Color = Color3.new(v.Color.R * 0.15,v.Color.G * 0.15,v.Color.R * 0.15)
					end
				elseif v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then
					if not M.OriginalStates[v] then
						M.OriginalStates[v] = {Enabled = v.Enabled}
					end
					v.Enabled = false
				end			
			end
		end
		
		CheckT(workspace.Filter)
		CheckT(workspace.Map)
		
		ReplicatedStorage.Values.AmbientMulti.Value = 0.85
		ReplicatedStorage.Values.BrightnessMulti.Value = 0
		ReplicatedStorage.Values.CloudColorMulti.Value = 0
		ReplicatedStorage.Values.SetFogValue.Value = 0.7
		ReplicatedStorage.Values.SetHazeValue.Value = 10
		ReplicatedStorage.Values.TimeState.Value = 0
		ReplicatedStorage.Values.TimeState.Enabled.Value = true
		ReplicatedStorage.Values.Streetlights.Value = false
		
		ReplicatedStorage.Values.LOutage.Value = true

		if EventsHandler.Config and EventsHandler.Config.MysteryBoxes and EventsHandler.Config.MysteryBoxes.Enabled and EventsHandler.Config.MysteryBoxes.BlackoutSpawnAll then
			for i = 1,20 do
				game.ServerStorage.Events3.MysteryBox_Spawn:Fire("JO43T0943-09IKOR")
			end
		end
		
		warn("Outage enabled")
	else
		M.Enabled = false
		
		M.Busy = true
		
		if M.Audio then
			pcall(function()
				M.Audio:Destroy()
			end)
		end
		
		if audio then
			M.Audio = script.Blackout_Off:Clone()
			M.Audio.Parent = workspace.Audio
			if not M.Audio.IsLoaded then 
				-- if not, wait until it has been
				M.Audio.Loaded:Wait()
			end
			M.Audio:Play()
			fastWait(7.5)
			
			local p1 = Instance.new("Part")
			game.Debris:AddItem(p1,30)
			p1.Anchored = true
			p1.Transparency = 1
			p1.CanCollide = false

			p1.Parent = workspace.Debris
			p1.CFrame = workspace.Filter.MapArea.CFrame

			local s2 = M.Audio:Clone()
			s2.Playing = false
			s2.Volume = 0
			s2.Parent = p1

			s2.TimePosition = M.Audio.TimePosition
			s2:Play()

			ReplicatedStorage.Events.ExplosionEffect:FireAllClients(p1,s2,
				{
					s2
					,s2.TimeLength
					,10000
					,1
					,1
					,2
				}
			)
		end
		
		for a,b in pairs(M.OriginalStates) do
			for c,d in pairs(b) do
				pcall(function()
					a[c] = d
				end)
			end
		end
		M.OriginalStates = {}
				
		ReplicatedStorage.Values.AmbientMulti.Value = 1
		ReplicatedStorage.Values.CloudColorMulti.Value = 1
		ReplicatedStorage.Values.BrightnessMulti.Value = 1
		ReplicatedStorage.Values.SetFogValue.Value = 0
		ReplicatedStorage.Values.SetHazeValue.Value = 0
		ReplicatedStorage.Values.TimeState.Value = 0
		ReplicatedStorage.Values.TimeState.Enabled.Value = false
		ReplicatedStorage.Values.Streetlights.Value = true
		
		ReplicatedStorage.Values.LOutage.Value = false
		
		if EventsHandler.Config and EventsHandler.Config.MysteryBoxes and EventsHandler.Config.MysteryBoxes.Enabled and EventsHandler.Config.MysteryBoxes.BlackoutSpawnAll then
			game.ServerStorage.Events3.MysteryBox_ClearAll:Fire(true)
		end
		
		warn("Outage disabled")
	end
	
	M.Busy = false
end

return M
