-- Energy.lua

local building = require("src.actors.building")

local Energy = building:makeSubclass("Energy")

Energy:makeInit(function(class, self, buildingType, x, y)
	class.super:initWith(self,  buildingType, x, y)
	assert(x,"Please provide an x position when calling init on energy")
	assert(y,"Please provide a y position when calling init on energy")
	
	self.typeName = "energy"
	self.hitCount = 10

	self:addPhysics()
	self.sprite.gravityScale = 0.0
	return self
end)

return Energy