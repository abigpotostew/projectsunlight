-- Pollution type

local Pollution = actor:makeSubclass("Pollution")

Ammo:makeInit(function(class, self, pollutionType)
		
		self.typeInfo = pollutionType
		self.hitCount = 10
		
		
		
		self:addPhysics()
		
end)

