-- Pipe 

local actor = require "src.actors.actor"

local Pipe = actor:makeSubclass("Pipe")

local IN = 0
local OUT = 1

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}


Pipe:makeInit(function(class, self, x, y, angleDeg)
    --assert(tile,"You must initialize this pipe with a tile in the constructor!")
    class.super:initWith(self)--pipes are 1x1 by default
    
    self.typeName = "pipe"
	self.startConnection = nil -- could be energy source or something
	self.endConnection = nil -- city or tower
    self.In = nil -- pointer to the previous pipe --In or pipe.NONE
    self.Out = nil -- pointer to the next pipe --Out or pipe.NONE
    self.Id = nil --pipe id
    --self.group = group --grid adds the new pipe sprite to group
    --self.tile = tile
	
	self.sprite = self:createSprite('pipe100',x,y)
	self.sprite.rotation = angleDeg+180 -- Add 180 so the ball part of the pipe is at end of the pipe
	self.sprite.actor = self
	
	self.inPos = nil --beginning pos of the pipe, the SOURCE
	self.outPos = nil -- end position of pipe where it may connect to a tower or another pipe
	
	self.pipeLength = 100
	self.pipeLength2 = self.pipeLength*self.pipeLength
	
    return self
end)

Pipe.setIn = Pipe:makeMethod(function(self, other, direction)
	assert(other,"Please privide an actor to set this pipe's in")
	self.In = other
	if other.typeName ~= "pipe" then
		self.startConnection = other
	end
	--do start connection checks here
    self:setSprite()
end)

Pipe.setOut = Pipe:makeMethod(function(self, other, direction)
	assert(other,"Please privide an actor to set this pipe's out")
	self.Out = other
    self:setSprite()
	--if other.typeName ~= "pipe" then
	--	self.startConnection = other
	--end
	--do end connection checks here
end)


Pipe.canContinuePipe = Pipe:makeMethod(function(self)
    return ( self.In ~= nil  and self.Out == nil )
end)

return Pipe