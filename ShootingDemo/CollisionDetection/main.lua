-- 
-- Abstract: CollisionDetection sample project
-- Demonstrates global and local collision listeners, along with collision forces
-- 
-- Version: 1.2 (revised for Alpha 3, demonstrates "collision" event and new "preCollision" and "postCollision" events)
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.

require ( "Vector2D" )
require ( "class" )

-- LOAD IN physics system -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local physics = require( "physics" )
physics.start()
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- draw sky and ground background images --
local sky = display.newImage( "bkg_clouds.png" )
sky.x = display.contentWidth / 2
sky.y = 195

local crate1 = display.newImage( "crate.png" )
crate1.x = 180; crate1.y = -50
crate1.myName = "first crate"

local function animate (event)
    if ( crate1.y > display.contentHeight ) then
        crate1.y = -150
        crate1:setLinearVelocity(0,0)
    end

--    if ( crate2.y > display.contentHeight ) then
--        crate2.y = -150
--        crate2:setLinearVelocity(0,0)
--    end
end

-- every frame, the event listener is triggered
Runtime:addEventListener ("enterFrame", animate );

physics.addBody( crate1, { density=3.0, friction=0.5, bounce=0.3 } )
--physics.addBody( crate2, { density=3.0, friction=0.5, bounce=0.3 } )

local function animate (event)
    if ( crate1.y > display.contentHeight ) then
        crate1.y = -150
        crate1:setLinearVelocity(0,0)
    end

--    if ( crate2.y > display.contentHeight ) then
--        crate2.y = -150
--        crate2:setLinearVelocity(0,0)
--    end
end

-- every frame, the event listener is triggered
Runtime:addEventListener ("enterFrame", animate );
--

local circleBounding = display.newCircle( 40, display.contentHeight / 2, 120)
circleBounding:setFillColor(255,255,255,50)
-- circleBounding.isVisible = false  -- optional
physics.addBody( circleBounding, { isSensor = true } )
circleBounding.gravityScale = 0.0
circleBounding.myName = "circle"

local tower = display.newImage ("towerRight.png" )
tower.x = 40
tower.y = display.contentHeight / 2
tower.myName = "tower"

local function towerListener(event) 
    print("!pew!")
    local energyBall = display.newImage ("energyBall.png" )
  --  energyBall
    physics.addBody (energyBall, {isSensor = true} )
    energyBall.gravityScale = 0.0
    energyBall.x = tower.x energyBall.y = tower.y 
    energyBallVec = Vector2D:new (energyBall.x, energyBall.y) crateVec = Vector2D:new (crate1.x, crate1.y)
    energyBallVec:sub(crateVec) energyBallVec:normalize() energyBallVec:mult(-1000) 
    energyBall:setLinearVelocity(energyBallVec.x, energyBallVec.y)
end 
 
tower:addEventListener("touch", towerListener )

--[[
local ground = display.newImage( "ground.png" )
ground.x = display.contentWidth / 2
ground.y = 445
ground.myName = "ground"
--]]
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- The parameter "myName" is arbitrary; you can add any parameters, functions or data to Corona display objects

--physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )
physics.setGravity( 0, 1);

--local crate2 = display.newImage( "crate.png" )
--crate2.x = 180; crate2.y = -150
--crate2.myName = "second crate"

----------------------------------------------------------
-- Two collision types (run Corona Terminal to see output)
----------------------------------------------------------

-- METHOD 1: Use table listeners to make a single object report collisions between "self" and "other"

local function onLocalCollision( self, event )
	if ( event.phase == "began" ) then
		--print( self.myName .. ": collision began with " .. event.other.myName )
        local energyBall = display.newImage ("energyBall.png" )
      --  energyBall
        physics.addBody (energyBall, {isSensor = true} )
        energyBall.gravityScale = 0.0
        energyBall.x = tower.x energyBall.y = tower.y 
        energyBallVec = Vector2D:new (energyBall.x, energyBall.y) crateVec = Vector2D:new (crate1.x, crate1.y)
        energyBallVec:sub(crateVec) energyBallVec:normalize() energyBallVec:mult(-1000) 
        print ( energyBallVec.x )
        --energyBall:setLinearVelocity(energyBallVec.x, energyBallVec.y)
	elseif ( event.phase == "ended" ) then

		--print( self.myName .. ": collision ended with " .. event.other.myName )

	end
end

crate1.collision = onLocalCollision
crate1:addEventListener( "collision", crate1 )
	
--crate2.collision = onLocalCollision
--crate2:addEventListener( "collision", crate2 )


-- METHOD 2: Use a runtime listener to globally report collisions between "object1" and "object2"
-- Note that the order of object1 and object2 may be reported arbitrarily in any collision

local function onGlobalCollision( event )
	if ( event.phase == "began" ) then

		--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision began" )

	elseif ( event.phase == "ended" ) then

		--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision ended" )

	end
	
	--print( "**** " .. event.element1 .. " -- " .. event.element2 )
	
end

Runtime:addEventListener( "collision", onGlobalCollision )


-------------------------------------------------------------------------------------------
-- New pre- and post-collision events (run Corona Terminal to see output)
--
-- preCollision can be quite "noisy", so you probably want to make its listeners
-- local to the specific objects you care about, rather than a global Runtime listener
-------------------------------------------------------------------------------------------

local function onLocalPreCollision( self, event )
	-- This new event type fires shortly before a collision occurs, so you can use this if you want
	-- to override some collisions in your game logic. For example, you might have a platform game
	-- where the character should jump "through" a platform on the way up, but land on the platform
	-- as they fall down again.
	
	-- Note that this event is very "noisy", since it fires whenever any objects are somewhat close!

	print( "preCollision: " .. self.myName .. " is about to collide with " .. event.other.myName )

end

local function onLocalPostCollision( self, event )
	-- This new event type fires only after a collision has been completely resolved. You can use 
	-- this to obtain the calculated forces from the collision. For example, you might want to 
	-- destroy objects on collision, but only if the collision force is greater than some amount.
	
	if ( event.force > 5.0 ) then
		print( "postCollision force: " .. event.force .. ", friction: " .. event.friction )
	end

end

-- Here we assign the above two functions to local listeners within crate1 only, using table listeners:

crate1.preCollision = onLocalPreCollision
crate1:addEventListener( "preCollision", crate1 )

crate1.postCollision = onLocalPostCollision
crate1:addEventListener( "postCollision", crate1 )