local actorType = require "src.actors.actorType"

local HutType = actorType:makeSubclass("HutType")

HutType:makeInit(function(class, self)
	class.super:initWith(self)

	self.hitHoldAnims = { }

	self.physics.category = "hut"
	self.physics.colliders = {"bird"}
	self.physics.bodyType = "static"

	print("hutTypeInit: ", self)

	return self
end)

HutType.load = HutType:makeMethod(function(self)
	for i, hitHold in ipairs(self.hitHoldAnims) do
		self.anims["hit" .. i] = hitHold.hit
		self.anims["hold" .. i] = hitHold.hold
	end
	self.maxHits = #self.hitHoldAnims
	self.hitHoldAnims = nil

	self.class.super.load(self)
end)

return HutType
