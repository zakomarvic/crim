local M = {}

local Security = workspace.Map:WaitForChild("Security")

M.SetUp = function(settinz)
	local GameSettings = settinz
	
	for _,v in pairs(Security.Alarms:GetChildren()) do
		local a = script.AlarmMain:Clone()
		a.Parent = v
		a.Disabled = false
	end
	
	for _,v in pairs(Security.Cameras:GetChildren()) do
		local a = script.CameraMain:Clone()
		a.Parent = v
		a.Disabled = false
	end
end
return M