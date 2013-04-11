local audio = require "audio"
local actor = require "src.actors.actor"
local collision = require "src.collision"

local Ammo = actor:makeSubclass("Ammo")

Ammo:makeInit(function(class, self, level, ammoType, startX, startY, dirX, dirY, speed)
	class.super:initWith(self)

	self.typeName = "ammo"
	self.level = level
	self.typeInfo = ammoType

	self:createSprite("normal", startX, startY, ammoType.scale, ammoType.scale,
		{"collision", "sprite", "postCollision"})

	self:addPhysics()

	speed = speed or ammoType.speed
	if (speed > ammoType.speed) then
		speed = ammoType.speed
	end

	local velX = dirX * speed
	local velY = dirY * speed

	self.sprite:setLinearVelocity(velX, velY)
	self:addTimer(ammoType.lifeSpan * 1000, function() self:onArrived() end)

	level:GetWorldGroup():insert(self.sprite)
	self.sprite:play()
	audio.play(ammoType.soundSet.launch)

	return self
end)

Ammo.onArrived = Ammo:makeMethod(function(self)
	local explosion = self.level:CreateExplosion(self.sprite, self.typeInfo.animSet, "explosion")
	local phys = { filter = collision.MakeFilter("ammoExplosion", { "bird" } ) }
	explosion:addPhysics('static', phys)
	explosion.typeName = "ammoExplosion"
	audio.play(self.typeInfo.soundSet.explosion)
	self:removeSprite()
end)

return Ammo
