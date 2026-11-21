return function(parts)
	local n = 0
	local n2 = 0
	
	for _,v in pairs(parts:GetDescendants()) do
		if v:IsA("Part")then
			n2 = n2 + 1
		end
	end

	for _,v in pairs(parts:GetDescendants()) do
		--if v:IsA("Part") and
		--	(
		--		(v.Size.Magnitude <= 5

		--			or(
		--				(v.Size.X <= 0.3 and v.Size.Y <= 0.3 and v.Size.Z >= 3.9 and v.Size.Magnitude <= 60)
		--					or (v.Size.X >= 3.9 and v.Size.Y <= 0.3 and v.Size.Z <= 0.3 and v.Size.Magnitude <= 60)
		--					or (v.Size.X <= 0.3 and v.Size.Y >= 3.9 and v.Size.Z <= 0.3 and v.Size.Magnitude <= 60)
		--			)


		--			or( not game
		--				or (v.Size.X <= 0.2 and (v.Size.Y >= 5 and v.Size.Y <= 50) and v.Size.Z <= 2 and v.Size.Magnitude <= 60)
		--				or (v.Size.X <= 0.8 and (v.Size.Z >= 12 and v.Size.Z <= 50) and v.Size.Y <= 0.8 and v.Size.Magnitude <= 60)
		--			)
		--		)

		--		and (v.Material == Enum.Material.Brick or v.Material == Enum.Material.Concrete)
		--	)then
			
		--	v.CanCollide = false
		--	--v:Destroy()
		--	n = n + 1
		--end

		if v:IsA("Model") and( string.find(string.lower(v.Name),"sewer light") or string.find(string.lower(v.Name),"wall light") or string.find(string.lower(v.Name),"light")) then
			for _,z in pairs(v:GetDescendants()) do
				if z:IsA("BasePart") and z.CanCollide then
					z.CanCollide = false
					n = n + 1
				end
			end
		elseif v:IsA("BasePart") then
			if v.Material == Enum.Material.Neon and v.CanCollide then
				v.CanCollide = false
			elseif v.Name == "FirePart" then
				local fs = script.FireScript:Clone()
				fs.Parent = v
				fs.Disabled = false
				
			end
			n = n + 1		
		end
	end

	--print(n .. "/" .. n2, math.floor(n/n2 * 100)/100)
	
	
end