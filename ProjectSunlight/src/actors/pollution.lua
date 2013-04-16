-- Pollution type

local Pollution = actor:makeSubclass("Pollution")

Ammo:makeInit(function(class, self, pollutionType)
		
		self.typeInfo = pollutionType
		self.hitCount = 10
		
		self:createSprite("normal", trajectory.start.position.x, trajectory.start.position.y,
		self.typeInfo.scale, self.typeInfo.scale)
		
		self:addPhysics()
		
end)

