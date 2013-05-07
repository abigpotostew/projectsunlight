-- Pipe 

local actor = require "src.actors.actor"

local Pipe = actor:makeSubclass("Pipe")

local IN = 0
local OUT = 1

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}

Pipe:makeInit(function(class, self)
    --assert(tile,"You must initialize this pipe with a tile in the constructor!")
    class.super:initWith(self, 1, 1)--pipes are 1x1 by default
    
    self.typeName = "pipe"
	self.startConnection = nil -- could be energy source or something
	self.endConnection = nil -- city or tower
    self.In = nil -- pointer to the previous pipe --In or pipe.NONE
    self.Out = nil -- pointer to the next pipe --Out or pipe.NONE
	self.InDir = pipe.NONE
	self.OutDir = pipe.NONE
    self.Id = nil --pipe id
    --self.group = group --grid adds the new pipe sprite to group
    --self.tile = tile
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
    self:setSprite()
end)

Pipe.setOut = Pipe:makeMethod(function(self, other, direction)
	assert(other,"Please privide an actor to set this pipe's out")
	self.Out = other
	self.OutDir = direction or pipe.NONE
    self:setSprite()
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
	elseif self.InDir == pipe.UP then
		id = "upstop"
	elseif self.InDir == pipe.DOWN then -- self.OutDir == pipe.DOWN or
		id = "downstop"
	elseif self.InDir == pipe.RIGHT then -- self.OutDir == pipe.RIGHT or 
		id = "rightstop"
	elseif self.InDir == pipe.LEFT then --self.OutDir == pipe.LEFT or 
		id = "leftstop"
	else
		assert(id, "You're pipes are misaligned, I can't decide what sprite to put in.")
	end
	
    
	--local group = self.group --group is initialized in this pipe's constructor
	if self.sprite then
        self.sprite:removeSelf()
        self.sprite = nil
    end
	self:createSprite(id,self.tile:x(),self.tile:y())
    self.tile:insert(self)
	--group:insert(self.sprite)
    --self.createSprite(id, )-- = debugTexturesSheetInfo:getFrameIndex(id)
end)

Pipe.canContinuePipe = Pipe:makeMethod(function(self)
    return ( self.In ~= nil  and self.Out == nil )
end)

return Pipe