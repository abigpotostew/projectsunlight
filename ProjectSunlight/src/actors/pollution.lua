-- Pollution!!
local actor = require("src.actors.actor")

local Pollution = actor:makeSubclass("Pollution")

Pollution:makeInit(function(class, self, pollutionType)
		
		self.typeInfo = pollutionType
		self.hitCount = 10
		
		self:createSprite("pollution", 200, 200,1, 1) -- self.typeInfo.scale where the 1's are
	
		self:addPhysics()
		self.sprite.gravityScale = 0.0
		return self
end)

return Pollution