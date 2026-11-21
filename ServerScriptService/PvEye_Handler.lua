local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local remote = Instance.new("RemoteEvent")
remote.Name = "PV87128"

local managing = {}

function Clear_PVEye(plr,code)
	if managing[plr] then
		if code ~= nil and managing[plr][3] ~= code then
			return
		end
		
		local targ = managing[plr][2]
		
		--print("doing clean")
		
		if plr and plr.Parent then
			for i,v in pairs(plr.PlayerGui:GetChildren()) do
				if v.Name == "PVEyeUI" then
					v:SetAttribute("Disconnect",true)
					game.Debris:AddItem(v,5)
				end
			end
			
			print("disconnected  Viewer",tostring(plr))
		end
		if targ and targ.Parent then
			print("disconnected Target",tostring(targ))
			for i,v in pairs(targ.PlayerGui:GetChildren()) do
				if v.Name == "PVEyeUI" then
					v:SetAttribute("Disconnect",true)
					game.Debris:AddItem(v,5)
				end
			end
		end
		
		if plr then
			managing[plr] = nil
		end
		
		if targ then
			managing[targ] = nil
		end
	end
end

function New_PVEye(plr1,plr2)
	if not (plr1 and plr2) then
		return
	end
	
	if managing[plr1] then
		Clear_PVEye(plr1)
	end
	if managing[plr2] then
		Clear_PVEye(plr2)
	end
	
	wait()
	
	local code = math.random()
	
	managing[plr1] = {2,plr2,code}
	managing[plr2] = {1,plr1,code}

	local s1 = script.PVEye_Target:Clone()
	local s2 = script.PVEye_Viewer:Clone()
	
	s2:SetAttribute("TargetName",plr2.Name)
	
	s1.Name = "MouseGUI"
	s2.Name = "PVEyeUI"

	s1.Parent = plr2.PlayerGui
	s2.Parent = plr1.PlayerGui
	
	local c1,c2
	local function disconnect2()
		if c1 then
			c1:Disconnect()
		end
		if c2 then
			c2:Disconnect()
		end

		Clear_PVEye(plr1,code)
	end	
	
	c1 = plr1.AncestryChanged:Connect(function(_,parent)
		if not parent then
			disconnect2()
		end
	end)
	c2 = plr2.AncestryChanged:Connect(function(_,parent)
		if not parent then
			disconnect2()
		end
	end)
end

remote.Parent = ReplicatedStorage
remote.OnServerEvent:Connect(function(plr,arg1,arg2,arg3)
	if not managing[plr] then return end
	
	if managing[plr][1] == 1 then -- is target
		local data = arg1
		
		data.char = plr.Character
		
		remote:FireClient(managing[plr][2],data)
	elseif managing[plr][1] == 2 then -- is responder
		
	end
end)

ServerStorage.Events3.PVEye_Toggle.Event:Connect(function(code,m,plr1,plr2)
	if code ~= "3490GER-RPSOKSDAF099-D0SFKMSFD0" then return end
	
--	print(code,m,plr1,plr2)
	
	if m == "on" then
		New_PVEye(plr1,plr2)
	elseif m =="off" then
		Clear_PVEye(plr1)
	end
end)

--Players.PlayerAdded:Wait()
--Players.PlayerAdded:Wait()

--wait(1)

--New_PVEye(Players.Player1,Players.Player2)