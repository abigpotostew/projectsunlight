local actorType = require "src.actors.actorType"

local BirdType = actorType:makeSubclass("BirdType")

BirdType:makeInit(function(class, self)
	class.super:initWith(self)

	self.physics.category = "bird"
	self.physics.colliders = {"ammo", "ammoExplosion", "bird", "ground", "hut"}
	self.physics.bodyType = "dynamic"

	return self
end)

return BirdType
