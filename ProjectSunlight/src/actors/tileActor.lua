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


Tile.x = Tile:makeMethod(function(self)
    assert(self.tile, "Can't call 'x()' on this tileactor because no associated tile has been set.")
    return self.tile.x()
end)

Tile.y = Tile:makeMethod(function(self)
    assert(self.tile, "Can't call 'y()' on this tileactor because no associated tile has been set.")
    return self.tile.y()
end)

Tile.gridX = Tile:makeMethod(function(self)
    assert(self.tile, "Can't call 'gridY()' on this tileactor because no associated tile has been set.")
    return self.tile.gridX()
end)

Tile.gridX = Tile:makeMethod(function(self)
    assert(self.tile, "Can't call 'gridY()' on this tileactor because no associated tile has been set.")
    return self.tile.gridY()
end)


return TileActor