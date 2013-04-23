-- Pollution!!
local actor = require("src.actors.actor")

local Pollution = actor:makeSubclass("Pollution")

Pollution:makeInit(function(class, self, pollutionType, x, y)
		class.super:initWith(self, pollutionType)
		
		self.typeInfo = pollutionType
		
        self.typeName = "pollution"
        
		
		self.hitCount = 10
		
		self:createSprite(self.typeInfo.anims.normal,x,y)
	
		--self:addPhysics()
		
		self.sprite.gravityScale = 0.0
		return self
end)

return Pollution