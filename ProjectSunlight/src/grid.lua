-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.

local class = require "src.class"
local Actor = require("src.actors.actor")
local Pollution = require "src.actors.pollution"
local pollutionType = require "src.actors.pollutionType"
local Building = require "src.actors.building"
local Buildings = require "actors.buildings"
local Energy = require "src.actors.energy"
local Pollutions = require "actors.pollutions"
local Pipe = require "src.actors.pipe"
local Touch = require "src.touch"
local Vector2 = require "src.vector2"
local Util = require "src.util"

local Grid = class:makeSubclass("Grid")


local tileSize = 64
local tileWidth = tileSize --we have square tiles
local tileHeight = tileSize --we have square tiles
local gridColumns = 32 -- number of grid tiles across
local gridRows = 24 -- number of grid tiles down
local tileSheetWidth = 256 --width of sheet image
local tileSheetHeight = 256 --height of sheet image

--Special zoom var that should be in grid.class but it's not because it doesn't work for callbacks in transition
local zoom_id = nil

local IN = 0
local OUT = 1

local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}

Grid:makeInit(function(class, self)
	class.super:initWith(self)

	self.typeName = "grid"

	-- debug stuff
	self.informationText = nil
	
	--finger drag tile
	self.selectedTileOverlay = nil
    
    self.pipeOverlay = nil
	
    --must initially be set to 0, just cus!
    self.pipeCount = 0
    self.currentPipe = -1
    
    --Navigation stuff
    self.doubleTapMark = 0
    self.zoomState = IN
    self.zoomAmt = 0.5

	--states for touch stuff
    self.isDragging = false
    self.isPiping = false
    self.isZooming = false
    self.isBadPiping = false

    self.grid = {} --a 2D array of pipe informations

    self.w = tileSize
    self.h = tileSize
    self.halfW = self.w*0.5
    self.halfH = self.h*0.5

    --For dragging pipes
    self.startTile = nil
    self.prevTile = nil
    
    local nx = 2
    local ny = 2
    self:createTileGroup( nx, ny )
    --until multitouch zoom is implemented, just zoom out all the way.
    self.group:scale(1,1)
	self.pollutionGroup = display.newGroup( )

	

    --self.informationText = display.newText( "Tile At Selected Grid Position Is: ", 40, 10,  native.systemFontBold, 16 )
	
	self.cityX = -1 --The city position X
	self.cityY = -1 -- The city position Y
    self:buildCity()
	self._timers = {}
	self._listeners = {}

	return self
end)










--local tileProperties = nil

--end debug stuff

--Begin grid stuff



--[[local sequences = {}
	sequences[0] = "wood"
	sequences[1] = "grass"
	sequences[2] = "horz"
	sequences[3] = "leftdown"
	sequences[4] = "rightdown"
	sequences[5] = "stone"
	sequences[6] = "leftup"
	sequences[7] = "rightup"
	sequences[8] = "vert"
	sequences[9] = "water"
	sequences[10] = "overlay"
	sequences[11] = "leftstop"
	sequences[12] = "rightstop"
	sequences[13] = "upstop"
	sequences[14] = "downstop"
	sequences[15] = "badpipe"]]--

--build a tile table, which keeps track of the sprite and it's current animation (id)
local function buildTile(_sprite, _id)
	return { sprite=_sprite, id=_id}
end

-- Return the type from the mirror 2d array grid that has pipe info
Grid.getTileType = Grid:makeMethod(function(self, _sprite)
    return self.grid[_sprite.gridX][_sprite.gridY].type
end)

Grid.canPipeHere = Grid:makeMethod(function(self, tile)
	return tile:canBuildHere()
end)

local function getOppositeDirection(direction)
	if direction == pipe.LEFT then
		return pipe.RIGHT
	elseif direction == pipe.RIGHT then
		return pipe.LEFT
	elseif direction == pipe.UP then
		return pipe.DOWN
	elseif direction == pipe.DOWN then
		return pipe.UP
	end
end

local function setSpritePipe(_sprite)
	local tile = _sprite.tile
    local id = nil
	if (tile.In == pipe.LEFT and tile.Out == pipe.UP) or
	   (tile.In == pipe.UP and tile.Out == pipe.LEFT) then
		id = "leftup"
	elseif (tile.In == pipe.UP and tile.Out == pipe.RIGHT) or
		   (tile.In == pipe.RIGHT and tile.Out == pipe.UP) then
		id = "rightup"
	elseif (tile.In == pipe.LEFT and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.LEFT) then
		id = "leftdown"
	elseif (tile.In == pipe.RIGHT and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.RIGHT) then
		id = "rightdown"
	elseif (tile.In == pipe.LEFT and tile.Out == pipe.RIGHT) or
		   (tile.In == pipe.RIGHT and tile.Out == pipe.LEFT) then
		id = "horz"
	elseif (tile.In == pipe.UP and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.UP) then
		id = "vert"
	elseif tile.Out == pipe.UP or tile.In == pipe.UP then
		id = "upstop"
	elseif tile.Out == pipe.DOWN or tile.In == pipe.DOWN then
		id = "downstop"
	elseif tile.Out == pipe.RIGHT or tile.In == pipe.RIGHT then
		id = "rightstop"
	elseif tile.Out == pipe.LEFT or tile.In == pipe.LEFT then
		id = "leftstop"
	else
		id = "grass"
	end
    self.currentFrame = debugTexturesSheetInfo:getFrameIndex(id)
    --_sprite:setSequence(id, _sprite)
end

local function directionTo(tileStart, tileDestination)
	return tileStart:directionTo(tileDestination)
end

--set the correct pipe in the grid data structure and on the sprite
Grid.setPipe = Grid:makeMethod(function(self, currTile, prevTile)
	local direction = directionTo(prevTile,currTile)
	
	currTile:insert(Pipe:init())
	currTile.actor:setIn(prevTile.actor, getOppositeDirection(direction))
	self.group:insert(currTile.actor.sprite) --insert the new sprite
	if(prevTile:canContinuePipe()) then
		prevTile.actor:setOut(currTile, direction)
		self.group:insert(prevTile.actor.sprite)
	end
end)

local function setSequence(seqName, sprite)
	--sprite:setSequence(seqName)
    sprite.currentFrame = debugTexturesSheetInfo:getFrameIndex(seqName)
	--sprite:play()
end

--Bresenhams line algorithm
local function bresenhams(start,dest)
	local x0 = start.gridX
	local y0 = start.gridY
	local x1 = dest.gridX
	local y1 = dest.gridY
	local dx = math.abs(x1-x0)
	local dy = math.abs(y1-y0) 
	local sx, sy
	if x0 < x1 then sx = 1 else sx = -1 end
	if y0 < y1 then sy = 1 else sy = -1 end
	local err = dx-dy
	local path = {}
 
	while true do
		--setPixel(x0,y0)
		table.insert(path,{x=x0,y=y0})
	    if x0 == x1 and y0 == y1 then
			break
		end
	    local e2 = 2*err
	    if e2 > -dy then 
	    	err = err - dy
	       	x0 = x0 + sx
	    end
	    if e2 <  dx then 
	       err = err + dx
	       y0 = y0 + sy 
	    end
	end
	return path
end

local function distance(tileA,tileB)
	return math.sqrt((tileB.gridX-tileA.gridX)*(tileB.gridX-tileA.gridX)
        + (tileB.gridY-tileA.gridY)*(tileB.gridY-tileA.gridY)) * tileSize --mult by pixels per tile
end

local function zoomingListener(obj)
	zoom_id = nil
end

Grid.createTiles = Grid:makeMethod(function(self,  x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	
	--Event listener for each tile!
	local function tileTouchEvent( event )
		local currTile = event.target
		
		if event.phase == "began" then
            if(self.zoomState == IN )then
                self.isDragging = true
                self.group.xStart = self.group.x
                self.group.yStart = self.group.y
                self.group.xBegan = event.x
                self.group.yBegan = event.y
            end
		elseif event.phase == "moved" then
			if self.isDragging == true then
				local dx = event.x - self.group.xBegan
				local dy = event.y - self.group.yBegan
				local x = dx + self.group.xStart
				local y = dy + self.group.yStart
				if ( x < self.group.xMin ) then 
					x = self.group.xMin 
				end
				if ( x > self.group.xMax ) then 
					x = self.group.xMax 
				end
				if ( y < self.group.yMin ) then 
					y = self.group.yMin 
				end
				if ( y > self.group.yMax ) then 
					y = self.group.yMax 
				end
				self.group.x = x
				self.group.y = y
			end	
		elseif event.phase == "ended" or event.phase == "cancelled" then
			--print("touch end")
			self.selectedTileOverlay.isVisible = false
			self.isPiping = false
			self.isDragging = false
			self.isZooming = false
			self.isBadPiping = false
			self.currentPipe = -1
			--double tap speed == 500
			if ( system.getTimer() - self.doubleTapMark < sun.doubleTapTime ) then
				--print("double tap!!")
				if ( zoom_id ) then
					transition.cancel(zoom_id.zoom)
					transition.cancel(zoom_id.position)
				end
				if ( self.zoomState == IN ) then
					--print("zooming OUT!")
					self.zoomState = OUT
					zoom_id = { zoom=transition.to(self.group,{xScale = self.zoomAmt, 
															   yScale=self.zoomAmt, 
															   transition=easing.outQuad, 
															   onComplete=zoomingListener}),
								position=transition.to(self.group,{x = self.group.xMax,
																   y=self.group.yMax,
																   transition=easing.outQuad}) }
				else
					self.zoomState = IN
					local targetx = -(event.x*(1/self.zoomAmt)+self.halfW - display.contentWidth/2)
					local targety = -(event.y*(1/self.zoomAmt)+self.halfH - display.contentHeight/2)
					if ( targetx > self.group.xMax ) then
						targetx = self.group.xMax
					elseif ( targetx < self.group.xMin ) then
						targetx = self.group.xMin
					end
					if ( targety > self.group.yMax ) then
						targety = self.group.yMax
					elseif ( targety < self.group.yMin ) then
						targety = self.group.yMin
					end
					zoom_id = { zoom=transition.to(self.group,{xScale = 1, yScale=1, transition=easing.outQuad, onComplete=zoomingListener}), 
								position=transition.to(self.group,{x=targetx, y=targety, transition=easing.outQuad}) }
				end
				self.doubleTapMark = 0
			else
				self.doubleTapMark = system.getTimer()
			end
		
		end
		
		self.prevTile = currTile
		
		-- Update the information text to show the tile at the selected position
		--self.informationText.text = "Selected Grid Type: " .. currTile.tile.type .. " Current Pipe: " .. self.currentPipe
		--print(tile)
	
		-- Transition the player to the selected grid position
		--transition.to( player, { x = tile.x, y = tile.y, transition = easing.outQuad } )	
		
		return true --important
	end
	
	
    ----------------------------------
    -- Create grid sprites!!
    ----------------------------------
	
	local startX = -tileWidth/2
	local startY = -tileHeight/2
	for X = 1,gridColumns do
        self.grid[X] = {}
		for Y = 1, gridRows do
			self.grid[X][Y] = Actor:init()
            self.grid[X][Y].group = self.group
            self.grid[X][Y].sprite = self.grid[X][Y]:createSprite('grass',X*tileSize+startX, Y*tileSize+startY)
			--self.grid[X][Y].sprite:addEventListener( "touch", tileTouchEvent )
            self.group:insert(self.grid[X][Y].sprite)
		end
	end
    
    ----------------------------------
    -- Set grid touch listener here!
    ----------------------------------

    self.group:addEventListener('touch', tileTouchEvent)
end)

--TODO:
Grid.canBuildHere = Grid:makeMethod(function(self, tile, width, height)

    --TODO: return a collision check whether this areas is clear
    return true
end)


Grid.buildCity = Grid:makeMethod(function(self, gridX, gridY)
    gridX = gridX or math.floor(gridColumns/2-1)
    gridY = gridY or math.floor(gridRows/2-1)
    
    if self:canBuildHere(self.grid[gridX][gridY],2,2) == true then
        --BUILD IT
        local city = Building:init(Buildings.city(), gridX*tileSize, gridY*tileSize)
		city:displayRadius()
        self:insert(city)
		self.group:insert(city.radiusSprite)
		self.cityX = gridX*tileSize
		self.cityY = gridY*tileSize
		self.city = city
    end
end)

--TODO: this should insert the sprite or actor into a level manager thing instead of here
--assumes you've checked is these tiles are available with canBuildHere()
Grid.insert = Grid:makeMethod(function(self, actor, insertIndex)
    assert(actor, "You must provide an actor when inserting an actor, ya doofus!")

    if insertIndex then
        self.group:insert(insertIndex, actor.sprite)
    else
        self.group:insert(actor.sprite)
    end
    actor.group = self.group
    actor.grid = self
end)



Grid.createTileGroup = Grid:makeMethod(function(self)
	self.group = display.newGroup( ) --debugTexturesImageSheet )--self.sheet )

	self.group.xMin = -display.contentWidth
	self.group.yMin = -display.contentHeight
	self.group.xMax = 0
	self.group.yMax =  0
	-- Groups are top left reference point by default
    
    print('min:'..self.group.xMin..', '..self.group.yMin)
    print('max:'..self.group.xMax..', '..self.group.yMax)
	
	----------------------------------
    -- Camera starting point
    ----------------------------------
	self.group.x = 0
	self.group.y = 0
	
	self:createTiles( self.group.xMin, self.group.yMin, self.group.xMax, self.group.yMax, self.group )
	
	--This comes after creating tiles so it shows up on top of the grid
	--This guy shows up wherever the players finger is
	self.selectedTileOverlay = display.newImage(
        debugTexturesImageSheet, 
        debugTexturesSheetInfo:getFrameIndex("overlay") )
	self.selectedTileOverlay.alpha = .5
	self.selectedTileOverlay.isVisible = false
	self.group:insert(self.selectedTileOverlay)
    self.selectedTileOverlay:setReferencePoint( display.TopLeftReferencePoint)
	
    
end)

Grid.createPollution = Grid:makeMethod(function(self) 
	 --CREATE SOME TOWERS & ENERGY SOURCES HERE
	local p1 = Pollution:init(Pollutions.radiation(),0,0)
	p1:setTarget(self.cityX,self.cityY)
	p1:setDirection()
	p1:addSensor()
	self.group:insert(p1.sprite)
	
    local energyBasic = Energy:init(Buildings.coal(),10*tileSize,2*tileSize)
    self:insert(energyBasic)
	--local circlePos = display.newCircle(energyBasic:x(),energyBasic:y(),2)
	--self.group:insert(circlePos)
    
    energyBasic:addListener(energyBasic.sprite, "touch", Touch.energyTouchEvent)
    
    print("Line: 546 - Hey I just finished creating pollution for you. No problem, don't worry about it.")
end)

Grid.createEnergy = Grid:makeMethod(function(self) 
	local e1 = Building:init(Buildings.tower(),10*tileSize,8*tileSize,10,8)
	--xe1.radiusSprite = e1:createSprite("pollution_wind",e1.radiusX, e1.radiusY,2,2)
	e1:displayRadius()
	--e1:addCollision(self.pollutionGroup)
	--e1:collision()
	--e1.radiusSprite.isVisible = false 
	self.group:insert(e1.sprite)
	self.group:insert(e1.radiusSprite)
	
	--e1.collision = onCollision
	--e1:addEventListener( "collision", e1 )
	
	--self.group:insert(e1.radiusSprite)
    --self:insert(Energy:init(Buildings.basic(),10*tileSize,8*tileSize),10,8)
end)

Grid.dispose = Grid:makeMethod(function(self)
	self.group:removeSelf()
	self.group = nil
	self.informationText = nil
	self.selectedTileOverlay = nil
	
	for i = 1, gridColumns do
        for j = 1, gridRows do
            self.grid[i][j]:removeSelf()
			self.grid[i][j] = nil
        end
		self.grid[i] = nil
    end
	self.grid = nil
end)

-----------------------------------------------------
-- Convert touch coordinates to in game position
-- returns vector2
-----------------------------------------------------
Grid.unproject = Grid:makeMethod(function(self, screenX, screenY)
	assert(screenX and screenY,'Please provide coordinates to unproject')
    local targetx = (screenX*(1/self.group.xScale) - self.group.x + self.group.xMax)
    local targety = (screenY*(1/self.group.yScale) - self.group.y + self.group.xMax)
    return Vector2:init(targetx,targety)
end)

Grid.setDragPipe = Grid:makeMethod(function(self,startVec,touchVec, sourcePipe)
	assert(startVec and touchVec, 'Please provide start and touch vectors')
	local p = self.pipeOverlay
    
	if p then
		local targetLocal = touchVec + -startVec
		local scale = math.min(targetLocal:length()/sun.pipeLength,1)
		local mid = startVec:mid(touchVec)
		local angle = touchVec:angle(startVec)
		angle = Util.RadToDeg(angle)
		p.sprite.xScale = scale
		p.sprite.x = mid.x
		p.sprite.y = mid.y
		p.sprite.rotation = angle+sun.pipeRotationOffset
		p.sprite.alpha = scale
        physics.removeBody(p.sprite)
        local w2, h2 = p.sprite.width*scale/2, p.sprite.height/2
        p:addPhysics({shape={w2,h2,w2,-h2,-w2,-h2,-w2,h2}, category="pipeOverlay", colliders={"pipe"}})
	else
		self.pipeOverlay = self:spawnPipe(startVec,touchVec,nil,nil,false,Touch.null)
		self.pipeOverlay.sprite.alpha = 0.0
		self.pipeOverlay.sprite.xScale = 0.01
        local w2, h2 = self.pipeOverlay.sprite.width*0.01/2, self.pipeOverlay.sprite.height/2
        self.pipeOverlay:addPhysics({shape={w2,h2,w2,-h2,-w2,-h2,-w2,h2},
                category="pipeOverlay", colliders={"pipe"} })
        local function dragPipeCollide(event)
            if event.target.actor.In ~= event.other.actor then
                --ALLOW a new pipe to be built
            end
            return true
        end
        self.pipeOverlay.In = sourcePipe
        self.pipeOverlay.sprite:addEventListener("collision", dragPipeCollide)
    end
end)

--Called after a pipe is built
Grid.clearDragPipe = Grid:makeMethod(function(self)
	if self.pipeOverlay then
		self.pipeOverlay:removeSelf()
		self.pipeOverlay = nil
	end
end)

Grid.spawnPipe = Grid:makeMethod(function(self,startVec, endVec, actorIn, actorOut, makePhysics, event)
	assert(startVec and endVec, 'Please provide start and end vector')
	local targetLocal = endVec + -startVec
    --TODO: 90 should be a variable!!
    local endPt = (targetLocal:copy()):normalized()*sun.newPipeDistance
	local mid = startVec:mid(endVec)
	local angle = endVec:angle(startVec)
	angle = Util.RadToDeg(angle)
	--spawn the pipe actor
	local pipe = Pipe:init(mid.x,mid.y,angle)
	--insert pipe into group
	self:insert(pipe, self.group.numChildren)
	
	pipe.inPos = startVec --start is the in direction
	pipe.outPos = endPt+startVec 	 --end is the out direction
	local e = event or Touch.pipeTouchEvent
	pipe:addListener(pipe.sprite, "touch", e)
    
    if makePhysics then
        pipe:addPhysics()
    end
	
	return pipe
end)

return Grid
--end grid stuff
