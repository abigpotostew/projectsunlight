--Tile.lua
-- Data structure for tiles on the map
local class = require "src.class"

local Tile = class:makeSubclass("Tile")

local tile =
	{
	NO_PIPE = -1, --can't build pipes on grid locations here
	ENERGY = -2,
	TOWER = -3,
    CITY = -4,
    BUILDING = -5, --debug
	EMPTY = -6 --a grid position that has no pipe yet
    --anything greater is a pipe ID
}

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}


Tile:makeInit(function(class, self)
    class.super:initWith(self)
    self.typeName 	= "tile"
    self.type       = tile.EMPTY
    self.actor      = nil  --actor is any tyle object in this tile
    self.sprite     = nil --SPRITE is the background on this tile
    self.In         = pipe.NONE
    self.Out        = pipe.NONE
    self.gridX      = -1
    self.gridY      = -1
    self.group      = nil
    return self
end)

Tile.canStartPipe = Tile:makeMethod(function(self)
    local out = false
	--local grid = currTile.grid
	--You can start dragging a pipe when the initial touch begins on an energy source
	--or on the end of a pipe
	if self.type == tile.ENERGY or 
		( self.type > tile.EMPTY and 
		  self.Out == pipe.NONE 
		  and self.In > pipe.NONE) then
		out = true
	end
	return out
end)

Tile.canBuildHere = Tile:makeMethod(function(self)
    return self:isEmpty()
end)

Tile.x = Tile:makeMethod(function(self)
    return self.sprite.x
end)

Tile.y = Tile:makeMethod(function(self)
    return self.sprite.y
end)

Tile.isEmpty = Tile:makeMethod(function(self)
    local out = (self.type == tile.EMPTY and self.actor == nil)
    return out
end)

--assumes you've already checked whether or not this tile is empty
Tile.insert = Tile:makeMethod(function(self, tileActor)
    assert(tileActor, "You must provide an actor to insert")
    if tileActor.typeName == "building" then
        self.type = tile.BUILDING
    elseif tileActor.typeName == "energy" then
        self.type = tile.ENERGY
    elseif tileActor.typeName == "city" then
        self.type = tile.CITY
    elseif tileActor.typeName == "tower" then
        self.type = tile.TOWER
	else
		--set the pipe ID here
    end
    self.actor = tileActor
end)

return Tile