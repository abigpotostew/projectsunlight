--[[
Project Sunlight
Actor
]]--

--local spSprite = require "src.libs.swiftping.sp_sprite"
local stateMachine = require "src.stateMachine"
local class = require "src.class"
local util = require "src.util"
local collision = require "src.collision"

local Actor = class:makeSubclass("Actor")

Actor:makeInit(function(class, self)
	class.super:initWith(self)

	self.typeName = "actor"

	self.hitCount = 0
	self.typeInfo = {}
	self.typeInfo.hitHoldAnims = {}
	self.sprite = nil
	self._timers = {}
	self._listeners = {}

	return self
end)

Actor.createSprite = Actor:makeMethod(function(self, animName, x, y, scaleX, scaleY, events)
	assert(animName, "You must provide an anim name when creating an actor sprite")
	assert(x and y, "You must specify a position when creating an actor sprite")

	scaleX = scaleX or 1
	scaleY = scaleY or 1

	local sprite = spSprite.init(self.typeInfo.animSet, animName, events)
	sprite.owner = self
	sprite.x, sprite.y = x, y
	sprite:scale(scaleX, scaleY)

	self.sprite = sprite
end)

Actor.createDebugSprite = Actor:makeMethod(function(self, image, x, y, scaleX, scaleY, events)
	assert(animName, "You must provide an anim name when creating an actor sprite")
	assert(x and y, "You must specify a position when creating an actor sprite")

	scaleX = scaleX or 1
	scaleY = scaleY or 1

	local sprite = spSprite.init(self.typeInfo.animSet, animName, events)
	sprite.owner = self
	sprite.x, sprite.y = x, y
	sprite:scale(scaleX, scaleY)

	self.sprite = sprite
end)

Actor.removeSprite = Actor:makeMethod(function(self)
	if (self.sprite and self.sprite.disposed == nil or self.sprite.disposed == false) then
		self.sprite:clearEventListeners()
		self.sprite:removeSelf()
		self.sprite.disposed = true
	else
		print("WARNING: Attempting to remove a nonexistant or already-disposed sprite!")
		print(debug.traceback())
	end
end)

Actor.removeSelf = Actor:makeMethod(function(self)
	self:removeSprite()

	for _, _timer in ipairs(self._timers) do
		timer.cancel(_timer)
	end
	self._timers = {}

	for _, _listener in ipairs(self._listeners) do
		_listener.object:removeEventListener(_listener.name, _listener.callback)
	end
	self._timers = {}
end)

Actor.addPhysics = Actor:makeMethod(function(self, data)
	data = data or {}

	local scale = data.scale or self.typeInfo.scale
	local mass = data.mass or self.typeInfo.physics.mass

	local phys = {
		density = mass * 1000 / util.SumShapeAreas(self.sprite:anim():getShapes(scale)),  -- TODO: Precompute this,
		friction = data.friction or self.typeInfo.physics.friction,
		bounce = data.bounce or self.typeInfo.physics.bounce,
		filter = collision.MakeFilter(data.category or self.typeInfo.physics.category,
			data.colliders or self.typeInfo.physics.colliders)
	}

	self.sprite:addPhysics(data.bodyType or self.typeInfo.physics.bodyType, phys, scale)
end)

Actor.addTimer = Actor:makeMethod(function(self, delay, callback, count)
	assert(delay and type(delay) == "number", "addTimer requires that delay be a number")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback.timer and type(callback.timer) == "function")),
		"addTimer requires a callback that is either a function, or a table with a 'timer' function")
	assert(count == nil or type(count) == "number", "addTimer requires that count be nil or a number")

	table.insert(self._timers, timer.performWithDelay(delay, callback, count))
end)

Actor.addListener = Actor:makeMethod(function(self, object, name, callback)
	assert(name and type(name) == "string", "addListener requires that name be a string")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback[name] and type(callback[name]) == "function")),
		"addListener requires that callback be either a function, or a table with a function that has the same name as the event")

	table.insert(self._listeners, {object = object, name = name, callback = callback})
	object:addEventListener(name, callback)
end)

Actor.ClearSpriteEventCommands = Actor:makeMethod(function(self)
	self.state.spriteEventCommands = {}
	self.state.spriteEventCommands["end"] = {}
	self.state.spriteEventCommands["loop"] = {}
	self.state.spriteEventCommands["next"] = {}
	self.state.spriteEventCommands["prepare"] = {}
end)

Actor.AddSpriteEventCommand = Actor:makeMethod(function(self, eventName, command)
	self.state.spriteEventCommands[eventName] = self.state.spriteEventCommands[eventName] or {}
	table.insert(self.state.spriteEventCommands[eventName], command)
end)

-- Commands called may add new commands, so before we call anything, reassign to an empty list
Actor.ProcessSpriteEvent = Actor:makeMethod(function(self, event)
	local commands = self.state.spriteEventCommands[event.phase]
	self.state.spriteEventCommands[event.phase] = {}

	for _, command in ipairs(commands) do
		command()
	end
end)

-- Call after the actor's sprite has been created
Actor.SetupStateMachine = Actor:makeMethod(function(self)
	self.state = stateMachine.Create()
	self:ClearSpriteEventCommands()
	self.sprite:addEventListener("sprite", function(event) self:ProcessSpriteEvent(event) end)
end)

Actor.GetState = Actor:makeMethod(function(self)
	if (self.state ~= nil) then
		local stateName, _ = self.state:GetState()
		return stateName
	else
		return nil
	end
end)

return Actor
