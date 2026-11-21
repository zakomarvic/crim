

local M = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PathfinderM = require(script.Pathfinder)
local config =  require(script.AIHandlerConfig)

math.randomseed(tick())

function M.new(...)
	if not M.brain then
		repeat wait(0.1) until M.brain
	end
	
	local brain = M.brain.new(...)
	table.insert(M.Brains,brain)
end

function M:GetCharList(self,radius,viewAngle)
	return M.Chars
end

function M:GetBrain(char)
	local n = nil
	
	for _,v in pairs(M.Brains) do
		if v.char == char then
			n = v
			break
		end
	end
	
	return n
end

function M:GetFakePlayer(char)
	for _,v in pairs(M.Chars) do
		if v.char == char then
			return v.player
		end
	end
end

function M.CharAdded(char)
	print("addedChar",char)
	local self = {}
	setmetatable(self, M)

	
	self.char = char
	self.hum = char:WaitForChild("Humanoid")
	self.root = char:WaitForChild("HumanoidRootPart")
	

	local fakePlayer = Instance.new("Folder")
	fakePlayer:SetAttribute("IsAI",true)
	char:SetAttribute("IsAI",true)
	
	local data = {
		Name = char.Name;
		ToString = char.Name;
		ClassName = "Player";
		AccountAge = 0;
		CharacterAppearanceId = tostring(1);
		UserId = tonumber(1);
		userId = tonumber(1);
		Parent = game:GetService("Players");
		Character = self.char;
		Backpack = Instance.new("Folder");
		PlayerGui = Instance.new("Folder");
		PlayerScripts = Instance.new("Folder");
		Kick = function() fakePlayer:Destroy() fakePlayer.Parent = nil end;
		IsA = function(ignore, arg) if arg == "Player" then return true end end;
		GetAttribute = function(ignore,arg) return fakePlayer:GetAttribute(arg) end;
	}

	self.player = data
	
	table.insert(M.Chars,self)
	
	self.CONS = {}
	
	table.insert(self.CONS,self.hum.Died:Connect(function()
		print("char_died")
		M:CharRemoved(self)
		self = nil
	end))
	table.insert(self.CONS,char.AncestryChanged:Connect(function(_,parent)
		if not parent then
			print("char_ancestryremoved")
			M:CharRemoved(self)
			self = nil
		end
	end))
end

function M:CharRemoved(self)
	local tPos = table.find(M.Chars,self)
	print("attemptremove1")
	if tPos then
		print("foudnrmeove2",#M.Brains)
	
		local char = M.Chars[tPos]
		if char and char.player then
			char.player:Kick()
			char.player = nil
		end
		
		table.remove(M.Chars,tPos)
		
		local removeTyp = nil
		
		for i,v in pairs(M.Brains) do
			print(i,v.char,self.char)
			if v.char ~= self.char then
				print("removed4")
				v:RemoveTarget(self.char)
			else
				print("removed3")
				removeTyp = v
			end
		end
		
		if removeTyp and table.find(M.Brains,removeTyp) then
			local pos = table.find(M.Brains,removeTyp)
			table.remove(M.Brains,pos)
		end

		for _,v in pairs(self.CONS) do
			if v then
				v:Disconnect()
			end
		end
	end
end

function M:Initialize()	
	PathfinderM:Init()

	M.config = require(script.AIHandlerConfig)
	M.brain = require(script.Brain)
	M.Chars = {}
	M.Brains = {}
	
	for _,v in pairs(M.config.CharFolder:GetChildren()) do
		M.CharAdded(v)
	end
	M.config.CharFolder.ChildAdded:Connect(M.CharAdded)
	
	RunService.Heartbeat:Connect(function(dt)
		for _,v in pairs(M.Brains) do
			spawn(function()
			v:MainLoop(dt)
			end)
		end
	end)
	
	ReplicatedStorage:WaitForChild("GameLoaded",100)
	
	local function newChar()
		local char = game.ServerStorage.Hostile_TestAI:Clone()
		
		char.Name = char.Name .. "_" .. math.random(11,99)

		char.HumanoidRootPart.CFrame = CFrame.new(PathfinderM:GetRandomNode()) + Vector3.new(0,5,0)
		
		local alive = true
		char.Humanoid.Died:Connect(function()
			if not alive then return end
			
			alive = nil
			
			wait(5)
			char:Destroy()
			char = nil
			
			newChar()
		end)
		
		if _G.NPC_Handler then
			_G.NPC_Handler(char)
		end
		
		local charStats = ReplicatedStorage:FindFirstChild("CharStats")
		local vF
		if charStats then
			vF = ReplicatedStorage.CharStats:WaitForChild(char.Name,3) 
			if vF then
				vF.NoDowned.Value = true
				
				pcall(function()
					delay(1,function()
						vF.AccelerationModifier.Value = 3;
						vF.ExplosiveKnockbackProof.Value = 0.3;
						vF.WeightProof.Value = 0.3;
						vF.FireProof.Value = 0;
						vF.ExplosiveJBreakProof.Value = 0.1;
						vF.ConcussionProofEXPLOSION.Value = 0;
						vF.ConcussionProof.Value = 0.35
						vF.ExplosiveProof2.Value = 0.2;
						vF.MovementSoundModifier.Value = 2.2;

						local r = Instance.new("NumberValue")
						r.Name = "RL_SPM"
						r.Value = 2
						r.Parent = vF.Currents

						local gF3 = char:FindFirstChild("hasGasMask")
						if not gF3 then
							gF3 = Instance.new("Folder")
							gF3.Name = "hasGasMask"
							gF3.Parent = char
						end
					end)
				end)
			end
		end
		
		char.Parent = workspace.Characters

		delay(2,function()
			char.Humanoid.MaxHealth = 10000
			char.Humanoid.Health = char.Humanoid.MaxHealth
		end)
		
		M.new(char,"RCU",vF)
	end
	
	for i = 1,config.AI_Count do
		spawn(newChar)
	end
end

return M
