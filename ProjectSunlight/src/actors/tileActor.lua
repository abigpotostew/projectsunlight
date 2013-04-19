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

return TileActor