

local M = {}
M.__index = M

math.randomseed(tick())

local config = require(script.Config)

local clothingF = script.Clothing
local hatsF = script.Hats
local hairF = script.Hairs
local faceaF = script.FaceAccessories
local facesF = script.Faces

local bcl = {"HeadColor";"LeftArmColor";"LeftLegColor";"RightArmColor";"RightLegColor";"TorsoColor"}

function M:CreateRandomInstance(seed)
	if seed then
		local nseedT = string.split(tostring(seed),"")
		local nseedN = 0
		for i,v in pairs(nseedT) do
			nseedN += string.byte(v)
			nseedN = nseedN * (string.byte(v) / 10)
		end
		nseedN = math.floor(nseedN)

		nseedN = string.sub(tostring(nseedN),0,14)
		nseedN = nseedN:gsub("%.", "")

		seed = nseedN
	else
		seed = math.floor(math.random() * 1000000)
	end
	
	return Random.new(seed)
end

function M:ChooseGender(code,ghair)
	local genderCode = code or self.Random:NextInteger(1,config.FemaleChance)
	genderCode = (genderCode == 1 and 2) or 1
	
	local nGHair = ghair == nil and genderCode == 1 and self.Random:NextInteger(1,config.NoHairChance) == 1
	
	local gender = (genderCode == 1 and "male") or "female"
	return gender,nGHair,genderCode
end

function M:ChooseBodyColor(pos)
	pos = pos or self.Random:NextInteger(1,#config.BodyColors)
	return config.BodyColors[pos],pos
end

function M:ChooseClothing(pos)
	pos = pos or self.Random:NextInteger(1,#clothingF:GetChildren())
	return clothingF:GetChildren()[pos],pos
end

function M:GetHat(genderCode,pos)
	local c = genderCode == 1 and config.Male_NoHatChance or config.Female_NoHatChance
	if pos then
		c = 2
	end
	pos = pos or self.Random:NextInteger(1,#M.HatsList)
	
	return self.Random:NextInteger(1,c) ~= 1 and M.HatsList[pos],pos
end

function M:GetHair(chosenHatT,genderCode,pos)
	local nPos = pos
	for i = 1,30 do
		pos = (nPos and math.min(nPos,#M.HairList[genderCode])) or self.Random:NextInteger(1,#M.HairList[genderCode])
		local newHair = M.HairList[genderCode][pos]
		
		if not chosenHatT or (chosenHatT and chosenHatT.Priority > newHair.Priority) then
			return newHair,pos
		end
	end
end

function M:GetFaceAccessory(chosenHatT,chosenHairT,genderCode,pos)
	pos = pos or self.Random:NextInteger(1,#M.FaceAList)
	
	if self.Random:NextInteger(1,config.NoFaceAChance) ~= 1 then
		for i = 0,30 do
			local faceA = M.FaceAList[pos]
			
			if not (faceA.IsMask and chosenHatT and chosenHatT.NoMask) 
				and not (chosenHatT and chosenHatT.NoFaceA) 
				and not (chosenHatT and chosenHatT.IsCap and faceA.NoCap) 
				and not (chosenHairT and chosenHairT.IsCap and faceA.NoCap) 
				and not (chosenHatT and chosenHatT.NoBandana and faceA.IsBandana)
				and not (chosenHatT and chosenHatT.Filter and table.find(chosenHatT.Filter,tostring(faceA.id)))
			then
				return faceA,pos
			end
		end
	end
	
	return nil,pos
end

function M:GetFace(pos)
	pos = pos or self.Random:NextInteger(1,#M.FacesList)
	return M.FacesList[pos],pos
end

function M.CreateAvatar(seed,randomInstance)
	local self = {}
	setmetatable(self, M)

	self.Random = randomInstance or self:CreateRandomInstance(seed)
	
	local gender,noGHair,genderCode = self:ChooseGender()
	local chosenBodyColor,chosenBodyColor_code = self:ChooseBodyColor()
	local chosenClothingF,chosenClothingF_code = self:ChooseClothing()

	local chosenHatT,chosenHatT_code = self:GetHat(genderCode)
	local chosenHairT,chosenHairT_code
	local chosenFaceAT,chosenFaceAT_code

	local chosenFace,chosenFace_code
	
	if not (chosenHatT and chosenHatT.NoHair) and not noGHair then
		chosenHairT,chosenHairT_code = self:GetHair(chosenHatT,genderCode)
	end

	chosenFaceAT,chosenFaceAT_code = self:GetFaceAccessory(chosenHatT,chosenHairT,genderCode)
	chosenFace,chosenFace_code = self:GetFace()
	
	local t = {
		bodycolor = chosenBodyColor_code;
		clothing = chosenClothingF_code;
		gender = genderCode;
		noghair = noGHair;
		chosenHat = chosenHatT;
		chosenHair = chosenHairT;
		chosenFaceA = chosenFaceAT;
		chosenFace = chosenFace_code;
	}
	
	return t
end


function M.new(character,seed,saveT)
	local self = {}
	setmetatable(self, M)
	
	--local bodyColors = Instance.new("BodyColors")
	local accessoriesT = {}
	local hD = Instance.new("HumanoidDescription")
	
	self.Random = self:CreateRandomInstance(seed)

	saveT = (typeof(saveT) == "table" and saveT) or M.CreateAvatar(seed,self.Random)
	
	local gender,noGHair,genderCode = self:ChooseGender(saveT.gender,saveT.noghair)
	local chosenBodyColor = self:ChooseBodyColor(saveT.bodycolor)
	--for _,v in pairs(bcl) do
	--	bodyColors[v] = chosenBodyColor
	--end

	local chosenClothingF = self:ChooseClothing(saveT.clothing)
	local chosenHatT = saveT.chosenHat
	--local hatAccessory = chosenHatT and hatsF["Asset_" .. chosenHatT.id]:FindFirstChildOfClass("Accessory")

	local chosenHairT,hairAccessory
	local chosenFaceAT,faceAccessory

	local chosenFaceT,chosenFace

	if not (chosenHatT and chosenHatT.NoHair) and not (noGHair) then
		chosenHairT = saveT.chosenHair
		--hairAccessory = chosenHairT and hairF[gender]["Asset_" .. chosenHairT.id]:FindFirstChildOfClass("Accessory")
	end

	chosenFaceAT = saveT.chosenFaceA
	--faceAccessory = chosenFaceAT and faceaF["Asset_" .. chosenFaceAT.id]:FindFirstChildOfClass("Accessory")

	chosenFaceT = self:GetFace(saveT.chosenFace)
	if chosenFaceT then
	--	chosenFace = facesF:FindFirstChild("Asset_" .. chosenFaceT.id)
	end

	--for _,v in pairs(chosenClothingF:GetChildren()) do
	--	table.insert(accessoriesT,v)
	--end	
	--if hatAccessory then
	--	table.insert(accessoriesT,hatAccessory)
	--end
	--if hairAccessory then
	--	table.insert(accessoriesT,hairAccessory)
	--end
	--if faceAccessory then
	--	table.insert(accessoriesT,faceAccessory)
	--end

	--local originalFace = character:WaitForChild("Head"):FindFirstChild("face")
	--if originalFace then
	--	originalFace:Destroy()
	--end
	--chosenFace.Parent = character.Head

	--bodyColors.Parent = character	
	--for _,v in pairs(accessoriesT) do
	--	local x = v:Clone()
	--	if x:IsA("Accessory") then
	--		x.Name = "Accessory"
	--	end
	--	x.Parent = character
	--end
	
	local shirt_url = string.sub(chosenClothingF:FindFirstChild("Shirt"):FindFirstChildOfClass("Model").Name,7,30)
	local pants_url = string.sub(chosenClothingF:FindFirstChild("Pants"):FindFirstChildOfClass("Model").Name,7,30) 
	
	local shirtID = string.match(shirt_url, "%d+")
	local pantsID = string.match(pants_url, "%d+")
	
	hD.FaceAccessory = chosenFaceAT and chosenFaceAT.id or ""
	hD.HatAccessory = chosenHatT and chosenHatT.id or ""
	hD.HairAccessory = chosenHairT and chosenHairT.id or ""
	hD.Face = chosenFaceT and chosenFaceT.id or ""
	hD.HeadColor = chosenBodyColor.Color
	hD.TorsoColor = chosenBodyColor.Color
	hD.LeftArmColor = chosenBodyColor.Color
	hD.RightArmColor = chosenBodyColor.Color
	hD.LeftLegColor = chosenBodyColor.Color
	hD.RightLegColor = chosenBodyColor.Color
	hD.Shirt = shirtID
	hD.Pants = pantsID
	
	hD:SetAttribute("IsMask",chosenFaceAT and chosenFaceAT.IsMask)
	hD:SetAttribute("FaceA_ID",chosenFaceAT and chosenFaceAT.id)
	
	--chosenClothingF:FindFirstChild("Shirt"):FindFirstChildOfClass("Model"):FindFirstChildOfClass("Shirt"):Clone().Parent = character
	--chosenClothingF:FindFirstChild("Pants"):FindFirstChildOfClass("Model"):FindFirstChildOfClass("Pants"):Clone().Parent = character
	
	local succ,err = pcall(function()
		character.Humanoid:RemoveAccessories()


		character.Humanoid:ApplyDescription(hD)

		if character.Humanoid:FindFirstChildOfClass("HumanoidDescription") then
			character.Humanoid:FindFirstChildOfClass("HumanoidDescription"):Destroy()
		end
		
		hD.Parent = character.Humanoid
		
		character.Humanoid:SetAttribute("HasRandomAvatar",true)
	end)
	
	if not succ then
		warn("error with RandomAvatar for",character,err)
	end

	--if seed then
	--	math.randomseed(math.random() + tick())
	--end
	return self
end

function M.SetUp()
	M.HatsList = {}
	M.HairList = {{},{}}
	M.FaceAList = {}
	M.FacesList = {}
	
	for i,v in pairs(config.Accessories.Hats) do
		table.insert(M.HatsList,{id = i;NoHair = v.NoHair;Priority = v.Priority;NoFaceA = v.NoFaceA;IsCap = v.IsCap;NoMask = v.NoMask;IsBala = v.IsBala;NoBandana = v.NoBandana;Filter = v.Filter})
	end
	for i,v in pairs(config.Accessories.FaceAccessories) do
		table.insert(M.FaceAList,{id = i;NoHair = v.NoHair;Priority = v.Priority;IsMask = v.IsMask;NoCap = v.NoCap;IsBandana = v.IsBandana})
	end
	for i,v in pairs(config.Accessories.Hairs[1]) do
		table.insert(M.HairList[1],{id = i;Priority = v.Priority;IsCap = v.IsCap})
	end
	for i,v in pairs(config.Accessories.Hairs[2]) do
		table.insert(M.HairList[2],{id = i;Priority = v.Priority;IsCap = v.IsCap})
	end
	
	for i,v in pairs(facesF:GetChildren()) do
		table.insert(M.FacesList,{id = string.sub(v.Name,7,30)})
	end
	
	for _,v in pairs(script:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CanTouch = false
			v.CanQuery = false
		end
	end
end

return M