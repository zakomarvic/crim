local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Furniture = ReplicatedStorage:WaitForChild("Furniture")
local Events = ReplicatedStorage:WaitForChild("Events")
local BuildingEvent = Events:WaitForChild("BuildingEvent")
local Directory = require(ReplicatedStorage.Modules:WaitForChild("Directory"))
local VO = require(ReplicatedStorage.Modules:WaitForChild("VO"))
local Buildings = workspace:WaitForChild("Buildings")
local Particles = workspace:FindFirstChild("Particles") or workspace

local MAX_PROPS = 300
local MAX_DISTANCE = 80        -- studs from your character to the prop
local NODE_SIZE = Vector3.new(120, 120, 120)
local INVITE_TIME = 60
local NODE_MAX_DISTANCE = 550

local lastAction = {}
local buddies = {}   -- buddies[player][name] = true
local invites = {}   -- invites[target][inviterName] = expiry

local function notify(plr, text)
	pcall(function()
		Events.ClientWarn:FireClient(plr, {text, 3, Color3.fromRGB(255, 200, 80), Color3.new(0, 0, 0), "lost"})
	end)
end

local function syncBuddies(plr)
	local names = {}
	for n in pairs(buddies[plr] or {}) do table.insert(names, n) end
	plr:SetAttribute("BuildBuddies", table.concat(names, ","))
end

local function canBuild(plr, nodeFolder)
	if nodeFolder.Name == plr.Name then return true end
	local owner = Players:FindFirstChild(nodeFolder.Name)
	return owner ~= nil and buddies[owner] ~= nil and buddies[owner][plr.Name] == true
end

local function validCFrame(cf)
	return typeof(cf) == "CFrame" and cf == cf and cf.Position.Magnitude < 1e5
end

local function nearCharacter(plr, pos)
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	return root ~= nil and (root.Position - pos).Magnitude <= MAX_DISTANCE
end

local function makeHitbox(model, cf)
	local pp = model.PrimaryPart
	local bbCF, size = model:GetBoundingBox()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = true
	part.Transparency = 1
	part.Size = size
	part.CFrame = cf * pp.CFrame:ToObjectSpace(bbCF)
	part.Parent = Particles
	return part
end

local function findNode(hitbox)
	for _, folder in ipairs(Buildings:GetChildren()) do
		local node = folder:FindFirstChild("Node")
		local tn = node and node:FindFirstChild("TrueNode")
		if tn and VO.checkobject(hitbox, tn) then return folder end
	end
end

local function countProp(folder, name)
	local n = 0
	for _, v in ipairs(folder:GetChildren()) do
		if v.Name == name then n += 1 end
	end
	return n
end

local function isProp(inst)
	return typeof(inst) == "Instance" and inst:IsA("Model") and inst.PrimaryPart ~= nil
		and inst.Parent ~= nil and inst.Parent.Parent == Buildings
		and inst.Name ~= "Node" and inst.Name ~= "TrueNode"
end

local function placeNode(plr, cf)
	if Buildings:FindFirstChild(plr.Name) then return end
	local template = Furniture:FindFirstChild("Node")
	if not template then return end
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - cf.Position).Magnitude > NODE_MAX_DISTANCE then
		notify(plr, "That spot is too far away.")
		return
	end

	local box = Instance.new("Part")
	box.Anchored, box.CanCollide, box.CanQuery, box.Transparency = true, false, true, 1
	box.Size, box.CFrame, box.Parent = NODE_SIZE, cf, Particles
	local blocked = VO.checknode(box)
	box:Destroy()
	if blocked then
		notify(plr, "There is another node nearby, try somewhere else.")
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = plr.Name
	folder.Parent = Buildings
	local node = template:Clone()
	node:SetPrimaryPartCFrame(cf)
	node.Node.Transparency = 1
	node.Parent = folder
end

local function placeProp(plr, name, cf, color)
	local template = Furniture:FindFirstChild(name)
	if not template or not template.PrimaryPart or not Directory.furni[name] then return end
	if not nearCharacter(plr, cf.Position) then return end

	local hitbox = makeHitbox(template, cf)
	local folder = findNode(hitbox)
	hitbox:Destroy()
	if not folder or not canBuild(plr, folder) then return end
	if not folder then notify(plr, "Not inside a node.") return end
	if not canBuild(plr, folder) then notify(plr, "You can't build in this node.") return end
	if #folder:GetChildren() >= MAX_PROPS then notify(plr, "Prop limit reached.") return end

	if #folder:GetChildren() >= MAX_PROPS then return end
	local limit = Directory.furni[name][3]
	if limit and countProp(folder, name) >= limit then return end

	local prop = template:Clone()
	prop:SetPrimaryPartCFrame(cf)
	if typeof(color) == "Color3" then
		for _, d in ipairs(prop:GetDescendants()) do
			if d:IsA("BasePart") and d.Name == "cc" then d.Color = color end
		end
	end
	local door = prop:FindFirstChild("DoorObj")
	if door and door:FindFirstChild("Owner") then
		door.Owner.Value = Players:FindFirstChild(folder.Name)
	end
	prop.Parent = folder
end

local function moveProp(plr, prop, cf)
	if not isProp(prop) then return end
	local folder = prop.Parent
	if not canBuild(plr, folder) or not nearCharacter(plr, cf.Position) then return end

	local node = folder:FindFirstChild("Node")
	local tn = node and node:FindFirstChild("TrueNode")
	if not tn then return end

	local hitbox = makeHitbox(prop, cf)
	local inside = VO.checkobject(hitbox, tn)
	hitbox:Destroy()
	if inside then prop:SetPrimaryPartCFrame(cf) end
end

local function removeProp(plr, prop)
	if not isProp(prop) then return end
	if canBuild(plr, prop.Parent) then prop:Destroy() end
end

BuildingEvent.OnServerEvent:Connect(function(plr, mode, a, b, c)
	if os.clock() - (lastAction[plr] or 0) < 0.1 then return end
	lastAction[plr] = os.clock()

	if mode == 1 then
		if typeof(a) ~= "string" or not validCFrame(b) then return end
		if a == "Node" then placeNode(plr, b) else placeProp(plr, a, b, c) end
	elseif mode == 2 then
		if validCFrame(b) then moveProp(plr, a, b) end
	elseif mode == 3 then
		removeProp(plr, a)
	end
end)

-- ===== build buddies =====
local function findPlayer(partial)
	partial = string.lower(partial or "")
	if partial == "" then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(p.Name), 1, #partial) == partial then return p end
	end
end

local function link(p1, p2, on)
	buddies[p1] = buddies[p1] or {}
	buddies[p2] = buddies[p2] or {}
	buddies[p1][p2.Name] = on or nil
	buddies[p2][p1.Name] = on or nil
	syncBuddies(p1)
	syncBuddies(p2)
end

local function onChat(plr, msg)
	local cmd, arg = string.match(msg, "^/(%a+)%s*(.*)$")
	if cmd ~= "buddy" and cmd ~= "accept" and cmd ~= "unbuddy" then return end
	local target = findPlayer(arg)
	if not target or target == plr then notify(plr, "Player not found.") return end

	if cmd == "buddy" then
		invites[target] = invites[target] or {}
		invites[target][plr.Name] = os.time() + INVITE_TIME
		notify(plr, "Build invite sent to " .. target.Name)
		notify(target, plr.Name .. " wants to build with you. Type /accept " .. plr.Name)
	elseif cmd == "accept" then
		local exp = invites[plr] and invites[plr][target.Name]
		if not exp or exp < os.time() then notify(plr, "No active invite from " .. target.Name) return end
		invites[plr][target.Name] = nil
		link(plr, target, true)
		notify(plr, "You can now build with " .. target.Name)
		notify(target, plr.Name .. " accepted. You can build together.")
	else
		link(plr, target, false)
		notify(plr, "Removed " .. target.Name .. " from your build buddies.")
	end
end

local function onPlayer(plr)
	buddies[plr] = buddies[plr] or {}
	plr:SetAttribute("BuildBuddies", "")
	plr.Chatted:Connect(function(m) onChat(plr, m) end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end

Players.PlayerRemoving:Connect(function(plr)
	for other, list in pairs(buddies) do
		if list[plr.Name] then list[plr.Name] = nil syncBuddies(other) end
	end
	buddies[plr], invites[plr], lastAction[plr] = nil, nil, nil
end)