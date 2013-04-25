-- Pipe 

local tileActor = require "src.actors.tileActor"

local Pipe = tileActor:makeSubclass("Pipe")

local IN = 0
local OUT = 1

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}

Pipe:makeInit(function(class, self)
    class.super:initWith(self, 1, 1)--pipes are 1x1 by default
    
    self.typeName = "pipe"
	self.startConnection = nil -- could be energy source or something
	self.endConnection = nil -- city or tower
    self.In = nil -- pointer to the previous pipe --In or pipe.NONE
    self.Out = nil -- pointer to the next pipe --Out or pipe.NONE
	self.InDir = pipe.NONE
	self.OutDir = pipe.NONE
    self.Id = nil --pipe id
	
    return self
end)

Pipe.setIn = Pipe:makeMethod(function(self, other, direction)
	assert(other,"Please privide an actor to set this pipe's in")
	self.In = other
	self.InDir = direction or pipe.NONE
	if other.typeName ~= "pipe" then
		self.startConnection = other
	end
	--do start connection checks here
end)

Pipe.setOut = Pipe:makeMethod(function(self, other, direction)
	assert(other,"Please privide an actor to set this pipe's out")
	self.Out = other
	self.OutDir = direction or pipe.NONE
	--if other.typeName ~= "pipe" then
	--	self.startConnection = other
	--end
	--do end connection checks here
end)

Pipe.setSprite = Pipe:makeMethod(function(self)
    local id = nil
	if (self.InDir == pipe.LEFT and self.OutDir == pipe.UP) or
	   (self.InDir == pipe.UP and self.OutDir == pipe.LEFT) then
		id = "leftup"
	elseif (self.InDir == pipe.UP and self.OutDir == pipe.RIGHT) or
		   (self.InDir == pipe.RIGHT and self.OutDir == pipe.UP) then
		id = "rightup"
	elseif (self.InDir == pipe.LEFT and self.OutDir == pipe.DOWN) or
		   (self.InDir == pipe.DOWN and self.OutDir == pipe.LEFT) then
		id = "leftdown"
	elseif (self.InDir == pipe.RIGHT and self.OutDir == pipe.DOWN) or
		   (self.InDir == pipe.DOWN and self.OutDir == pipe.RIGHT) then
		id = "rightdown"
	elseif (self.InDir == pipe.LEFT and self.OutDir == pipe.RIGHT) or
		   (self.InDir == pipe.RIGHT and self.OutDir == pipe.LEFT) then
		id = "horz"
	elseif (self.InDir == pipe.UP and self.OutDir == pipe.DOWN) or
		   (self.InDir == pipe.DOWN and self.OutDir == pipe.UP) then
		id = "vert"
	elseif self.OutDir == pipe.UP or selfInDir == pipe.UP then
		id = "upstop"
	elseif self.OutDir == pipe.DOWN or self.InDir == pipe.DOWN then
		id = "downstop"
	elseif self.OutDir == pipe.RIGHT or self.InDir == pipe.RIGHT then
		id = "rightstop"
	elseif self.OutDir == pipe.LEFT or self.InDir == pipe.LEFT then
		id = "leftstop"
	else
		assert(id, "You're pipes are misaligned, I can't decide what sprite to put in.")
	end
	local oldX, oldY = self.sprite.x, self.sprite.y
	self.sprite:removeSelf()
	self.sprite = nil
	self:createSprite(id,oldX+(self.width/2*64),oldY+(self.height/2*64))
    --self.createSprite(id, )-- = debugTexturesSheetInfo:getFrameIndex(id)
end)

return Tile