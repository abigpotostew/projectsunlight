-- Building Type.lua
--info on building type actors

local actorType = require "src.actors.actorType"

local BuildingType = actorType:makeSubclass("BuildingType")

BuildingType:makeInit(function(class, self)
	class.super:initWith(self)

	self.physics.category = "building"
	self.physics.colliders = {"pollution"}
    
    self.width = 1
    self.height = 1

	self.transition = {}
	self.start = {}

	return self
end)

return BuildingType
