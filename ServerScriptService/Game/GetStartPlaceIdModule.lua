return function(sConfig,gameMode)
	--if not sConfig.Gamemodes[gameMode] then return end

	local got = nil

	--for i,v in pairs(sConfig.Gamemodes[gameMode].PlaceIds) do
	--	if v == game.PlaceId then
	--		got = i
	--		break
	--	end
	--end
	
	got = sConfig.Servers[tostring(game.GameId)]

	return got
end