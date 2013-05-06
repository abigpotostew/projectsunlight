-- Building.lua
-- A generic building class, will probably be extended into energy, tower, and cities

local tileActor = require "src.actors.tileActor"
local Building = tileActor:makeSubclass("Building")
local Physics = require( "physics" )

Building:makeInit(function(class, self, buildingType, x, y)
    class.super:initWith(self)
    
    self.typeName = "building"
    self.typeInfo = buildingType
    self.width = buildingType.width
    self.height = buildingType.height
	self.radius = buildingType.radius
	self.radiusX = x+(self.width/2*64)
	self.radiusY = y+(self.height/2*64)
    --Doesn't have much yet, but will have events and health and whatever.
	--self.radiusSprite = nil
    self.sprite = self:createSprite(self.typeInfo.anims.normal,x+(self.width/2*64),y+(self.height/2*64))
    self:addPhysics()
	
	
    return self
end)

Building.displayRadius = Building:makeMethod(function(self)
	--local radiusSprite = self:createSprite("pollution_wind",self.radiusX, self.radiusY,2,2)
	--name, color, visible
    --energyRadius = display.newCircle(self.radiusX, self.radiusY, self.radius)
	--self.radiusSprite.alpha = .5
	--Physics.addBody( self.radiusSprite, { isSensor = true } )
	--radiusSprite.name = "radius"
	--energyRadius:setFillColor(color)
	--energyRadius.isVisible = visible
	--energyRadius.isVisible = false  -- optional
	-- energyRadius.Name = name
	--self.radiusSprite = radiusSprite
end)

return Building