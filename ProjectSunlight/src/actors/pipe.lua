-- Pipe 

local tileActor = require "src.actors.tileActor"

local Pipe = tileActor:makeSubclass("Pipe")

local IN = 0
local OUT = 1

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}

Pipe:makeInit(function(class, self, x, y, In, Out)
    class.super:initWith(self)
    
    self.typeName = "pipe"
    --self.In = nil -- pointer to the previous pipe --In or pipe.NONE
    --self.Out = nil -- pointer to the next pipe --Out or pipe.NONE
    --self:addPhysics()
    self.Id = nil --pipe id
    
    
    return self
end)

Pipe.setSprite = Tile:makeMethod(function(self))
    local id = nil
	if (self.tile.In == pipe.LEFT and self.Out == pipe.UP) or
	   (self.In == pipe.UP and self.Out == pipe.LEFT) then
		id = "leftup"
	elseif (self.In == pipe.UP and self.Out == pipe.RIGHT) or
		   (self.In == pipe.RIGHT and self.Out == pipe.UP) then
		id = "rightup"
	elseif (self.In == pipe.LEFT and self.Out == pipe.DOWN) or
		   (self.In == pipe.DOWN and self.Out == pipe.LEFT) then
		id = "leftdown"
	elseif (self.In == pipe.RIGHT and self.Out == pipe.DOWN) or
		   (self.In == pipe.DOWN and self.Out == pipe.RIGHT) then
		id = "rightdown"
	elseif (self.In == pipe.LEFT and self.Out == pipe.RIGHT) or
		   (self.In == pipe.RIGHT and self.Out == pipe.LEFT) then
		id = "horz"
	elseif (self.In == pipe.UP and self.Out == pipe.DOWN) or
		   (self.In == pipe.DOWN and self.Out == pipe.UP) then
		id = "vert"
	elseif self.Out == pipe.UP or self.In == pipe.UP then
		id = "upstop"
	elseif self.Out == pipe.DOWN or self.In == pipe.DOWN then
		id = "downstop"
	elseif self.Out == pipe.RIGHT or self.In == pipe.RIGHT then
		id = "rightstop"
	elseif self.Out == pipe.LEFT or self.In == pipe.LEFT then
		id = "leftstop"
	else
		assert(id, "You're pipes are misaligned, I can't decide what sprite to put in.")
	end
    self.createSprite(id, )-- = debugTexturesSheetInfo:getFrameIndex(id)
end)

return Tile