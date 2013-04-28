-- Building.lua
-- A generic building class, will probably be extended into energy, tower, and cities

local tileActor = require "src.actors.tileActor"

local Building = tileActor:makeSubclass("Building")

Building:makeInit(function(class, self, buildingType, x, y)
    class.super:initWith(self)
    
    self.typeName = "building"
    self.typeInfo = buildingType
    self.width = buildingType.width
    self.height = buildingType.height
    --Doesn't have much yet, but will have events and health and whatever.
    self:createSprite(self.typeInfo.anims.normal,x,y)--x+(self.width/2*64),y+(self.height/2*64)
    self:addPhysics()
    
    return self
end)

return Building