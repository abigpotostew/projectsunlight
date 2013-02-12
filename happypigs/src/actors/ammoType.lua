local actorType = require "src.actors.actorType"

local AmmoType = actorType:makeSubclass("AmmoType")

AmmoType:makeInit(function(class, self)
	class.super:initWith(self)

	self.physics.category = "ammo"
	self.physics.colliders = {"bird", "ground", "ammo"}
	self.physics.bodyType = "dynamic"

	self.transition = {}
	self.start = {}

	return self
end)

return AmmoType
