--[[ 
	Copyright (C) 2024 xewadev - All Rights Reserved
	
	You may not use, distribute and modify this code without
	proper permission from the original author.
--]]

local SecurityHandler = {}
SecurityHandler.__index = SecurityHandler

--// Folders:

local Packages = script:WaitForChild("Packages")

--// References:

local HTTPs = require(Packages.HTTPs)

--// Functions:

function SecurityHandler:initHttpsPackage()
	assert(self.__init, "Constructor hasn't been initialized, aborting...")
	
	self.__packages["HTTPs"] = HTTPs.new(self)
end

--// Module:

SecurityHandler.new = function()
	local self = setmetatable({}, SecurityHandler)
	self.__init = true
	self.__packages = {}
	
	self:initHttpsPackage()
	
	return self
end

--// End:

return SecurityHandler