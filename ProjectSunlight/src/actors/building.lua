-- Building.lua
-- A generic building class, will probably be extended into energy, tower, and cities

local tileActor = require "src.actors.tileActor"
local Building = tileActor:makeSubclass("Building")
local Physics = require( "physics" )

Building:makeInit(function(class, self, buildingType, x, y)
    class.super:initWith(self)
    
	self.collision = nil
    self.typeName = "building"
    self.typeInfo = buildingType
    self.width = buildingType.width
    self.height = buildingType.height
	self.radius = buildingType.radius
	self.radiusX = x+(self.width/2*64)+32
	self.radiusY = y+(self.height/2*64)+32
    --Doesn't have much yet, but will have events and health and whatever.
	--self.radiusSprite = nil
    self.sprite = self:createSprite(self.typeInfo.anims.normal,x+(self.width/2*64),y+(self.height/2*64))
    self:addPhysics()
	
	
    return self
end)

Building.displayRadius = Building:makeMethod(function(self)
		
	self.radiusSprite = display.newCircle(self.radiusX, self.radiusY, self.radius)
	self.radiusSprite.typeName = "radius"
	self.radiusSprite.alpha = .5
	Physics.addBody ( self.radiusSprite, { isSensor = true } )
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

Building.addCollision = Building:makeMethod(function(self, _group)
	function onCollision( event )
        for i = 1,_group.numChildren do
			event.object1 = self.radiusSprite
			event.object2 = _group[i].actor
			print (event.object1.typeName)
			print (event.object2.typeName)
		
			if ( event.phase == "began") then
				print ("Collision - " .. event.object1.typeName .. " - with - " .. event.object2.typeName)
				self.radiusSprite:setFillColor(222,128,128)
			elseif otherName then
			print("unknown named object: " .. event.object2.typeName)
			end
		
			if (event.phase == "ended" ) then
				self.radiusSprite:setFillColor(255,0,128)
			end
		end
	end
	Runtime:addEventListener( "collision", onCollision )
	--self.collision = onCollision
	--self.collision:addEventListener( "collision", e1 )
end)

Building.collision = Building:makeMethod(function(self, event)

	if (event.phase ~= "ended") then
		return
	end

	local other = event.other
	local otherName = other.typeName
	local otherOwner = other.owner

	if (otherOwner ~= nil) then
		otherName = otherOwner.typeName
	end

	if (otherName == "pollution") then
		self.radiusSprite:setFillColor(222,128,128)
		otherOwner:OnBirdHit(self)
	elseif otherName then
		print("unknown named object: " .. otherName)
	end
end)

return Building