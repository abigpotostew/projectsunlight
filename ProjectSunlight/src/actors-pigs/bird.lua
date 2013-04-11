local audio = require "audio"
local math = require "math"
local physics = require "physics"

local util = require "src.util"
local collision = require "src.collision"
local score = require "src.score"
local actor = require "src.actors.actor"

local scoreValues = { 10, 20, 30, 50, 100, 150, 200, 250, 300, 400, 500, 600, 750, 1000 }

-- Rounds a score value to a discrete set of numbers
local function RoundScore(value)
	for i = 1, #scoreValues - 1 do
		if (value < scoreValues[i+1]) then
			if (value < scoreValues[i] * 0.5 + scoreValues[i + 1] * 0.5) then
				return scoreValues[i]
			else
				return scoreValues[i + 1]
			end
		end
	end
	return scoreValues[#scoreValues]
end

local Bird = actor:makeSubclass("Bird")

Bird:makeInit(function(class, self, level, birdType, trajectory)
	class.super:initWith(self)

	assert(level and birdType and trajectory, "Bird.init: Incorrect parameters")

	self.typeName = "bird"
	self.level = level
	self.typeInfo = birdType
	self.trajectory = trajectory
	self.health = self.typeInfo.health

	self:createSprite("normal", trajectory.start.position.x, trajectory.start.position.y,
		self.typeInfo.scale, self.typeInfo.scale)

	self:addPhysics()

	local xVel = math.cos(util.DegToRad(trajectory.start.angle)) * trajectory.start.speed
	local yVel = math.sin(util.DegToRad(trajectory.start.angle)) * trajectory.start.speed
	self.sprite:setLinearVelocity(xVel, yVel)
	self.sprite.angularVelocity = 0
	self.sprite.collision = function(self, event) self:OnBirdCollision(self, event) end
	self.sprite:addEventListener("collision", self)
	level:GetWorldGroup():insert(self.sprite)

	self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("normal")

	audio.play(self.typeInfo.soundSet.launch)

	return self
end)

Bird.SetupStates = Bird:makeMethod(function(self)

	self.state:SetState("hurt", {
		enter = function()
			self.sprite:play("hurt", false)
			-- TODO: Hack, will stomp other changes - write a delay into the events queue
			self:addTimer(self.typeInfo.hurtDuration * 1000, function() self.state:GoToState("normal") end)
		end
	})

	self.state:SetState("normal", {
		enter = function()
			self.sprite:play("normal")
		end,
		onBirdHit = function(bird)
			self.state:GoToState("hit")
		end
	})

	self.state:SetState("dying", {
		enter = function()
			self.sprite:play("death", false)
			self:ClearSpriteEventCommands()
			self:AddSpriteEventCommand("end", function() self.state:GoToState("dead") end)
		end
	})

	self.state:SetState("dead", {
		enter = function()
			self:CreateExplosion("deathParticle")
			self.level:RemoveBird(self)
		end
	})

end)

Bird.Score = Bird:makeMethod(function(self, amount)
	if (self.sprite ~= nil) then
		local screenX, screenY = self.level:WorldToScreen(self.sprite.x, self.sprite.y)
		score.IncrementAndShowPoints(screenX, screenY, amount, self.level:GetScreenGroup())
	end
end)

Bird.collision = Bird:makeMethod(function(self, event)

	if (event.phase ~= "ended") then
		return
	end

	local other = event.other
	local otherName = other.typeName
	local otherOwner = other.owner

	if (otherOwner ~= nil) then
		otherName = otherOwner.typeName
	end

	if (otherName == "hut") then
		audio.play(self.typeInfo.soundSet.hitHut)
		self:CreateExplosion("hitHut")
		self:TakeDamage(1)
		otherOwner:OnBirdHit(self)
	elseif (otherName == "ammo") then
		if (self:TakeDamage(1)) then
			self:Score(300)
		else
			self:Score(100)
		end
	elseif (otherName == "ammoExplosion") then
		if (self:TakeDamage(3)) then
			self:Score(600)
		else
			self:Score(200)
		end
	elseif (otherName == "ground" or otherName == "bird") then
		if (self:TakeDamage(1)) then
			self:Score(100)
		else
			self:Score(50)
		end
	elseif otherName then
		print("Bird hit unknown named object: " .. otherName)
	end
end)

Bird.TakeDamage = Bird:makeMethod(function(self, damage)

	self.health = self.health - damage

	if (self.health > 0) then
		self:CreateExplosion("hurtParticle")
		audio.play(self.typeInfo.soundSet.hurt)
		self.state:GoToState("hurt")
		return false
	else
		audio.play(self.typeInfo.soundSet.death)
		self.state:GoToState("dying")
		return true
	end
end)

Bird.CreateExplosion = Bird:makeMethod(function(self, animName)
	self.level:CreateExplosion(self.sprite, self.typeInfo.animSet, animName)
end)

return Bird
