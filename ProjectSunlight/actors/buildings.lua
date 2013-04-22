-- Buildings

local buildingType = require "src.actors.buildingType"
local building = require "src.actors.building"
local Buildings = {}


Buildings["city"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "city"
    bType.width = 2
    bType.height = 2
	return bType
end

Buildings["energy"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	return bType
end

return Buildings