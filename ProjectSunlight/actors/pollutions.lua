--pollutions.lua
--Spawns pollution types

local pollutionType = require "src.actors.pollutionType"
local pollution = require "src.actors.pollution"
local Pollutions = {}


Pollutions["radiation"] = function()
	local pType = pollutionType:init()
    pType.anims.normal = "pollution"
	return pType
end




return Pollutions