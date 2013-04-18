--Polution type
local actorType = require "src.actors.actorType"

local PollutionType = actorType:makeSubclass("pollutionType")

PollutionType:makeInit(function(class, self)
	class.super:initWith(self)

	self.physics.category = "pollution"
	self.physics.colliders = {"tower", "city", "energy", "terrain"}
	

	self.transition = {}
	self.start = {}

	return self
end)

return PollutionType
