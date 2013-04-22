-- Tile Actor
-- An actor who's position is limited to grid spaces

local actor = require "src.actors.actor"

local TileActor = actor:makeSubclass("TileActor")

TileActor:makeInit(function(class, self, width, height)
    class.super:initWith(self)
    self.tile = nil -- The top left tile occupied by this actor.
    self.width = 1
    self.height = 1
    
    
    return self
end)

--returns pixel position of this tile
TileActor.x = TileActor:makeMethod(function(self)
    assert(self.tile, "Can't call 'x()' on this tileactor because no associated tile has been set.")
    return self.tile.x()
end)

--returns pixel y position
TileActor.y = TileActor:makeMethod(function(self)
    assert(self.tile, "Can't call 'y()' on this tileactor because no associated tile has been set.")
    return self.tile.y()
end)

TileActor.pos = TileActor:makeMethod(function(self)
	assert(self.tile, "Can't get pos() on tileactor without a tile on it")
	return {x = self.tile.x(), y = self.tile.y()}
end)

--returns grid x position
TileActor.gridX = TileActor:makeMethod(function(self)
    assert(self.tile, "Can't call 'gridY()' on this tileactor because no associated tile has been set.")
    return self.tile.gridX()
end)

--returns grid y position
TileActor.gridX = TileActor:makeMethod(function(self)
    assert(self.tile, "Can't call 'gridY()' on this tileactor because no associated tile has been set.")
    return self.tile.gridY()
end)

TileActor.gridPos = TileActor:makeMethod(function(self)
	assert(self.tile, "Can't get gridPos() on tileactor without a tile on it")
	return {x = self.tile.gridX(), y = self.tile.gridY()}
end)

return TileActor