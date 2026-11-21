local M = {}

local rs = game:GetService("RunService")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local l = game.Lighting
local sL_Folder = workspace:WaitForChild("Map",1000):WaitForChild("StreetLights")

local config = {
	Day_Length =	15; -- 15
	Night_Length =	7.5; -- 7.5
	
	StreetLight = {6.4;18}; --- active time
	
	StreetLight_Brightness = 	1.5;
	StreetLight_Range = 		60;
	StreetLight_Angle = 		140;
	StreetLight_Color = 		Color3.fromRGB(255, 170, 0);
	StreetLight_Shadows = 		true;

	StreetLightPart_Color1 = Color3.fromRGB(255, 103, 21);
	StreetLightPart_Color2 = Color3.fromRGB(17, 17, 17);
}

wait(6)

local valuesF = ReplicatedStorage.Values
local dayLengthV = valuesF.DayLength
local nightLengthV = valuesF.NightLength
local timeStateV = valuesF.TimeState
local StreetlightsV = valuesF.Streetlights

ReplicatedStorage.Values.StartClockTick.Value = ReplicatedStorage.Values.StartTick.Value + (math.random() * 10000)

local startTime = ReplicatedStorage.Values.StartClockTick.Value
local lightsOn = nil
local busy = false
local lights = {}

function SetUp()
	ReplicatedStorage.Values.DayLength.Value = config.Day_Length
	ReplicatedStorage.Values.NightLength.Value = config.Night_Length
	for _,v in pairs(sL_Folder:GetChildren()) do
		if v:FindFirstChild("IsLegacy") then
			local lpV = v:FindFirstChild("LightPartValue")
			if lpV and lpV.Value then
				local sL = lpV.Value:FindFirstChildOfClass("SpotLight")
				if sL then
					sL.Brightness =		config.StreetLight_Brightness
					sL.Range =			config.StreetLight_Range
					sL.Color =			config.StreetLight_Color
					sL.Angle =			config.StreetLight_Angle
					sL.Shadows =		config.StreetLight_Shadows
					table.insert(lights,{v,lpV.Value,true})
				end
			end
			
		else
			if v:FindFirstChild("LightEmitter") and v.LightEmitter:FindFirstChild("Attachment") then
				local sL = v.LightEmitter.Attachment:FindFirstChildOfClass("SpotLight")
				if sL then
					sL.Brightness =		config.StreetLight_Brightness
					sL.Range =			config.StreetLight_Range
					sL.Color =			config.StreetLight_Color
					sL.Angle =			config.StreetLight_Angle
					sL.Shadows =		config.StreetLight_Shadows
					table.insert(lights,{v,v.LightEmitter.Attachment})
				end
			end
		end
	end	
	
	StreetlightsV.Changed:Connect(function()
		if not StreetlightsV.Value then
			HandleLights(false)
		end
	end)
end

function HandleLights(t)
	if t == lightsOn then return end
	if busy then return end

	busy = true
	
	for _,v in pairs(lights) do
		local model = v[1]
		local light = v[2]
		
		if v[3] then
			light:FindFirstChildOfClass("SpotLight").Enabled = t
			model.LightPart1.Color = t and config.StreetLightPart_Color1 or config.StreetLightPart_Color2
			model.LightPart1.Material = t and Enum.Material.Neon or Enum.Material.Glass
		else
			light:FindFirstChildOfClass("SpotLight").Enabled = t
			model.LightEmitter.Material = t and Enum.Material.Neon or Enum.Material.Glass
			model.LightEmitter.Color = t and config.StreetLightPart_Color1 or config.StreetLightPart_Color2
		end
	
	end
	
	lightsOn = t
	busy = false
end
local function Update()
	local currentTime = (tick() - startTime) / 60 % (dayLengthV.Value + nightLengthV.Value);

	local ct = 0
	if currentTime < dayLengthV.Value then
		ct = 6 + 12 * currentTime / dayLengthV.Value
	else
		ct= (18 + 12 * (currentTime - dayLengthV.Value) / nightLengthV.Value) % 24;
	end

	--game.Lighting.ClockTime = ct

	if timeStateV.Enabled.Value then
		ct = timeStateV.Value
	end
	
	if StreetlightsV.Value then
		if ct >= config.StreetLight[1] and ct < config.StreetLight[2] then
			HandleLights(false)
		else
			HandleLights(true)
		end
	else
		HandleLights(false)
	end
end

--while wait(1) do	

--end

SetUp()

M.MainLoop = function()
	Update()
end

return M