repeat task.wait() until (_G.ServerLoaded == true)
task.wait(0.5)
-- Cmdr

require(script:WaitForChild("permissions"))
local cmdr = require(script:WaitForChild("cmdr"))
cmdr:RegisterDefaultCommands()
cmdr:RegisterHooksIn(script:WaitForChild("hooks"))
cmdr:RegisterCommandsIn(script:WaitForChild("commands"))
cmdr:RegisterTypesIn(script:WaitForChild("types"))
_G.dcmdr = script
_G.scmdr = cmdr
print("Cmdr Server Ran!")
-- End