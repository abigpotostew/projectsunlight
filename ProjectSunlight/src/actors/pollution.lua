-- Pollution!!
local actor = require("src.actors.actor")
local Vector2 = require ("src.vector2")
local Pollution = actor:makeSubclass("Pollution")

Pollution:makeInit(function(class, self, pollutionType, x, y)
		class.super:initWith(self, pollutionType)
		
		self.typeInfo = pollutionType
		
        self.typeName = "pollution"
       		
		self.myVector = Vector2:init(x, y) -- creates a vector holding the x and y positions 
			
		self.target = nil
		
		self.speed = pollutionType.speed
		
		self.hitCount = 10
		
		self.sprite = self:createSprite(self.typeInfo.anims.normal,x,y)
	
		self:addPhysics()
		
		self.sprite.gravityScale = 0.0
		return self
end)

Pollution.setTarget = Pollution:makeMethod(function(self, x, y)
	self.target = Vector2:init(x,y)
end)

Pollution.setDirection = Pollution:makeMethod(function(self)
	if (self.target ~= nil) then
	    self.myVector = self.myVector - self.target
        self.myVector:normalized() 
        self.myVector = self.myVector * (.05) * self.speed
        self.sprite:setLinearVelocity(self.myVector.x, self.myVector.y)
	end
end)

return Pollution