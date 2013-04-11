local physics = require "physics"
local collision = require "src.collision"
local actor = require "src.actors.actor"

local Hut = actor:makeSubclass("Hut")

Hut:makeInit(function(class, self, level, hutType, x, y)
	class.super:initWith(self)

	assert(level and hutType and x and y, "Invalid parameter(s) to Hut.init")

	self.typeName = "hut"
	self.level = level
	self.typeInfo = hutType

	self:createSprite("start", x, y)
	self:addPhysics()

	self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("start")

	level:GetWorldGroup():insert(self.sprite)

	return self
end)

Hut.SetupStates = Hut:makeMethod(function(self)

	self.state:SetState("start", {
		enter = function()
			self.sprite:play("start")
		end,
		onBirdHit = function(bird)
			self.state:GoToState("hit")
		end
	})

	self.state:SetState("hit", {
		enter = function()
			self.hitCount = self.hitCount + 1
			if (self.hitCount <= self.typeInfo.maxHits) then
				local animName = "hit" .. self.hitCount
				print("Hut: Playing hit anim: " .. animName)
				self.sprite:play(animName)

				self:ClearSpriteEventCommands()
				self:AddSpriteEventCommand("end", function() self.state:GoToState("hold") end)
			else
				print("Hut: Dying")
				self.state:GoToState("dying")
			end
		end
	})

	self.state:SetState("hold", {
		enter = function()
			local animName = "hold" .. self.hitCount
			print("Hut: Playing hold anim: " .. animName)
			self.sprite:play(animName)
		end,
		onBirdHit = function(bird)
			self.state:GoToState("hit")
		end
	})

	self.state:SetState("dying", {
		enter = function()
			self.sprite:play("death")

			self:ClearSpriteEventCommands()
			self:AddSpriteEventCommand("end", function() self.state:GoToState("dead") end)
		end
	})

	self.state:SetState("dead", {
		enter = function()
			print("Hut: Dead")
			self:removeSprite()
		end
	})
end)


Hut.OnBirdHit = Hut:makeMethod(function(self, bird)
	assert(bird, "Invalid parameter(s) to Hut.create")
	local state, stateFuncs = self.state:GetState()
	if stateFuncs and stateFuncs.onBirdHit then
		stateFuncs.onBirdHit(bird)
	end
end)

return Hut
