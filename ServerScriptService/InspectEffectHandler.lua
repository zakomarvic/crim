local ohios

local InspectMods = {
	
	["Photon-Alternator"] = function(Character, Tool, Mode)
		if Mode then
			Tool.WeaponHandle.ReloadA.Inspect:Play()
		else
			Tool.WeaponHandle.ReloadA.Inspect:Stop()
		end
	end,

	["ERADICATOR2"] = function(Character, Tool, Mode)

		local InspectSeed = math.random()
		local Remote = Tool.CIR
		local CON = nil

		local InspectSound = Tool.Handle.Inspect

		if not Mode then

			Tool:SetAttribute("IS", math.random())
			InspectSound:Stop()

			if Tool:FindFirstChild("Do") and not Tool.Do.Value then
				Remote:Fire(true)
			end

			return
		end

		local function Cancel()
			pcall(function()
				CON:Disconnect()
			end)
		end

		Tool:SetAttribute("IS", InspectSeed)

		if Tool:FindFirstChild("Do") and not Tool.Do.Value then
			Remote:Fire(true)
		end

		InspectSound:Play()

		task.wait(3.6)

		if Tool:GetAttribute("IS") ~= InspectSeed then
			Cancel()
			return
		end

		Remote:Fire(false)

		task.wait(0.85)

		if Tool:GetAttribute("IS") ~= InspectSeed then
			Cancel()
			return
		end

		Remote:Fire(true)

		task.wait(2)

		if Tool:GetAttribute("IS") ~= InspectSeed then
			Cancel()
			return
		end

		Cancel()

		CON = Tool.AncestryChanged:Connect(function(A, B)
			if A and B then
				if B ~= Character then
					Tool:SetAttribute("IS", math.random())
					InspectSound:Stop()
					CON:Disconnect()
				end
			end
		end)
	end,

	["Ithaca-37"] = function(Character, Tool, Mode)
		if Tool:FindFirstChild("InspectM") then
			if Mode then
				ohios=require(Tool.InspectM).Enable()
			else
				require(Tool.InspectM).Disable(ohios)
			end
		end
	end,
}

game:GetService("ReplicatedStorage"):WaitForChild("Events").InspectEffect.OnServerEvent:Connect(function(Player, Tool, Mode)
	if Player and Player.Character and Tool and Tool.Parent and Tool:IsDescendantOf(Player.Character) and Tool:FindFirstChild("Config") then

		local Character = Player.Character
		local Config = require(Tool.Config)

		if (Config.Customs and Config.Customs.CustomInspect) or Tool:GetAttribute("CIR") then
			if InspectMods[Tool.Name] then
				task.spawn(function()
					InspectMods[Tool.Name](Character, Tool, Mode)
				end)
			end
		end
	end
end)