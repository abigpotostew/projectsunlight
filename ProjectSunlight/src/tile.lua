--Tile.lua

local class = require "src.class"

local Tile = class:makeSubclass("Tile")

local tile =
	{
	NO_PIPE = -1, --can't build pipes on grid locations here
	ENERGY = -2,
	TOWER = -3,
	EMPTY = 0 --a grid position that has no pipe yet
}

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}

local IN = 0
local OUT = 1

Tile:makeInit(function(class, self)
    self.type       = tile.EMPTY
    self.actor      = nil  --actor is any tyle object in this tile
    self.terrain    = nil --terrain is the background on this tile
    self.In         = pipe.NONE
    self.Out        = pipe.NONE
    self.gridX      = -1
    self.gridY      = -1
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

Tile.canPipeHere = Tile:makeMethod(function(self)
    local out = true
	if self.type == tile.NO_PIPE or
        self.type == tile.ENERGY or
        self.type == tile.TOWER or
        self.type > tile.EMPTY or
        self.actor == nil then
		out = false
	end
	return out
end)

Tile.isEmpty = Tile:makeMethod(function(self)
    local out = (self.type == tile.EMPTY and self.actor == nil)
    return out
end)

return Tile