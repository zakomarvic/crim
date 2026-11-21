local WorldEventHandler = {}
WorldEventHandler.__index = WorldEventHandler

--// Folders \\--

local Modules = script:WaitForChild("Modules")

--// References \\--

local DownedDropshipModule = require(Modules.DownedDropship)

--// Module \\--

function WorldEventHandler:init(str: string, ...: any)
	if (str == "DownedDropship") then
		return self:initDownedDropship(...)
	end	
end

--// Functions \\--

function WorldEventHandler:initDownedDropship(...: any)
	return DownedDropshipModule:init(...)
end

--// End \\--

return WorldEventHandler