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

Buildings["basic"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    --bType.width = 10 * 64
    --bType.height = 8 * 64
	bType.radius = 100
	
	return bType
end

Buildings["wind"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end

Buildings["water"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end

Buildings["solar"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end

Buildings["geothermal"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end

Buildings["radiation"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end

Buildings["hybrid"] = function()
	local bType = buildingType:init()
    bType.anims.normal = "energy"
    bType.width = 1
    bType.height = 1
	
	return bType
end


return Buildings