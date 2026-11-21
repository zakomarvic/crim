local CharacterManager = {}

local cS = game:GetService("CollectionService")

CharacterManager.NewCharacter = function(character,...)
	
	for _,v in pairs(script.RunningHandlers:GetChildren()) do
		if cS:HasTag(v,character.Name) then
			v:Destroy()
		end
	end
	
	local s = script.init:Clone()
	s.Name = "RunningHandler"
	cS:AddTag(s,character.Name)
	s.Parent = script.RunningHandlers
	s.Disabled = false
	
	s.Do:Fire(character,...)
end

return CharacterManager