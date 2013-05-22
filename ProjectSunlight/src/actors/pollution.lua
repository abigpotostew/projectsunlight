-- Pollution!!
local actor = require("src.actors.actor")
local Vector2 = require ("src.vector2")
local Pollution = actor:makeSubclass("Pollution")

Pollution:makeInit(function(class, self, pollutionType, x, y)
	class.super:initWith(self, pollutionType)
	
	self.typeInfo = pollutionType
	
	self.typeName = "pollution"
		
		self.typeName = "pollution"
		self.typeInfo = pollutionType 
       	--self.level = level
		--self.health = self.typeInfo.health	
			
		self.myVector = Vector2:init(x, y) -- creates a vector holding the x and y positions 
		self.target = nil
		self.speed = pollutionType.speed
		--self.hitCount = 10
		
		self.sprite = self:createSprite(self.typeInfo.anims.normal,x,y)
        self.sprite.actor = self
		self:addPhysics()
		self.sprite.gravityScale = 0.0
			
		self.sprite.collision = function(self, event) 
			self:collision(self, event) 
			--self.sprite.collision = onPollutionCollision
		end
		self.sprite:addEventListener("collision", self)
		
		return self
end)

local function onPollutionCollision (event) 
		print ("inOnPollution")
		local radiusSprite = display.newCircle(10, 20, 10)
		physics.addBody( radiusSprite, {isSensor = true } )
--		Physics.addBody ( self.radiusSprite, { isSensor = true } ))
		
end
	

Pollution.collision = Pollution:makeMethod(function(self, event)
	if (event.phase == "began") then
		--print ("in ended :47")
		--print ("event object1:" .. event.other.typeName)
		--print ("event object2:" .. self.typeName)
        print("Pollution collision")
		
		if (event.other.typeName == "radius") then
		--audio.play(self.typeInfo.soundSet.hitHut)
		--self:CreateExplosion("hitHut")
		--self:TakeDamage(1)
		--otherOwner:OnBirdHit(self)
		print ("Boom" .. "line 48 collision")
	--[[elseif (otherName == "ammo") then
		if (self:TakeDamage(1)) then
			self:Score(300)
		else
			self:Score(100)
		end
	--]]
	end
		
		return
	end

	if (otherOwner ~= nil) then
		otherName = otherOwner.typeName
	end
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

Pollution.addSensor = Pollution:makeMethod(function(self)
	physics.addBody ( self.sprite, { isSensor = true } )	
end)

return Pollution