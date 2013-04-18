-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.

local class = require "src.class"
local actor = require("src.actors.actor")
local Pollution = require "src.actors.pollution"
local pollutionType = require "src.actors.pollutionType"
local Tile = require "src.tile"

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


Grid:makeInit(function(class, self)
	class.super:initWith(self)

	self.typeName = "grid"

	-- debug stuff
	self.informationText = nil
	
	--finger drag tile
	self.selectedTileOverlay = nil
	
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

	--Initialize the grid
    for i = 1, gridColumns do
        self.grid[i] = {}
        for j = 1, gridRows do
            self.grid[i][j] = Tile:init()
        end
    end
    
    self.sheetData = { 
        width=tileWidth,
        height=tileHeight,
        numFrames=16,
        sheetContentWidth=tileSheetWidth,
        sheetContentHeight=tileSheetHeight
	}
    self.sheet = graphics.newImageSheet( "data/tiles.png", self.sheetData ) --load the actual spritesheet

    --each tile can be any one of these tiles
    --use spite:setSequence("FRAME NAME") to swap out the animation
    self.sequenceData = {
        {name="wood", start=1, count = 1,time=0},
        {name="grass", start=2, count = 1,time=0},
        {name="horz", start=3, count = 1,time=0},
        {name="leftdown", start=4, count = 1,time=0},
        {name="rightdown", start=5, count = 1,time=0},
        {name="stone", start=6, count = 1,time=0},
        {name="leftup", start=7, count = 1,time=0},
        {name="rightup", start=8, count = 1,time=0},
        {name="vert", start=9, count = 1,time=0},
        {name="water", start=10, count = 1,time=0},
        {name="overlay", start=11, count = 1,time=0},
        {name="leftstop", start=12, count = 1,time=0},
        {name="rightstop", start=13, count = 1,time=0},
        {name="upstop", start=14, count = 1,time=0},
        {name="downstop", start=15, count = 1,time=0},
        {name="badpipe", start=16, count = 1,time=0}
    }

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

    --self.informationText = display.newText( "Tile At Selected Grid Position Is: ", 40, 10,  native.systemFontBold, 16 )

    
    
    
    
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

Grid.canStartPipe = Grid:makeMethod(function(self, currTile)
	return currTile.canStartPipe()
end)

Grid.canPipeHere = Grid:makeMethod(function(self, tile)
	return tile.canPipeHere()
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

--set the correct pipe in the grid data structure and on the sprite

Grid.setPipe = Grid:makeMethod(function(self, currTile, prevTile)
	local direction = pipe.NONE
	if currTile.x < prevTile.x then
		direction = pipe.LEFT
	elseif currTile.x > prevTile.x then
		direction = pipe.RIGHT
	elseif currTile.y < prevTile.y then
		direction = pipe.UP
	elseif currTile.y > prevTile.y then
		direction = pipe.DOWN
	end
	
	self.prevTile.tile.Out = direction
	currTile.tile.In = getOppositeDirection(direction)
	
	setSpritePipe(currTile)
	if self.prevTile.tile.type ~= tile.ENERGY then
		setSpritePipe(prevTile)
	end
	
	--("currTile: in:"..currTile.In.." out:"..currTile.Out)
	--print("prevTile: in:"..prevTile.In.." out:"..prevTile.Out)
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
		local currTile = event.target.tile
		
		if event.phase == "began" then
			--print(getTileType(currTile))
			local tileType = currTile.type
			if currTile:isEmpty() then
				self.isDragging = true
				self.group.xStart = currTile.group.x
				self.group.yStart = currTile.group.y
				self.group.xBegan = event.x
				self.group.yBegan = event.y
				print("start scrolling")
			elseif currTile:canStartPipe() == true then
				self.isPiping = true
				self.startTile = currTile
				self.prevTile = currTile
                setSequence("overlay",self.selectedTileOverlay)
				self.selectedTileOverlay.isVisible = true
				self.selectedTileOverlay.x = currTile.x
				self.selectedTileOverlay.y = currTile.y
				print("start piping WOO!")
			else
				self.isBadPiping = true
				self.selectedTileOverlay.isVisible = true
				setSequence("badpipe",self.selectedTileOverlay)
				self.selectedTileOverlay.x = currTile.x
				self.selectedTileOverlay.y = currTile.y
				print("bad pipe!")
			end
		elseif event.phase == "moved" then
			if self.isDragging == true then
				local dx = event.x - self.group.xBegan
				local dy = event.y - self.group.yBegan
				local x = dx + self.group.xStart
				local y = dy + self.group.yStart
				if ( x < self.group.xMin ) then x = self.group.xMin end
				if ( x > self.group.xMax ) then x = self.group.xMax end
				if ( y < self.group.yMin ) then y = self.group.yMin end
				if ( y > self.group.yMax ) then y = self.group.yMax end
				self.group.x = x
				self.group.y = y
			elseif self.isPiping == true then
				if currTile ~= self.prevTile then
					local path = bresenhams(self.prevTile,currTile)
					
					--local freshPipe = (canPipeHere(prevTile) == true and currentPipe < 0)
					--if freshPipe then print("fresh!") end
					local canPipe = (self:canPipeHere(currTile))
					if canPipe then print("can pipe!") end
					if self:getTileType(self.prevTile) == tile.ENERGY and self:getTileType(currTile) == tile.EMPTY then
						self.pipeCount = self.pipeCount + 1
					end
					--freshPipe == true or
					if canPipe == true then
						if self.currentPipe < 0 then 
							if self.prevTile.tile.type <= 0 then
								self.currentPipe = self.pipeCount
							else
								self.currentPipe = self.prevTile.tile.type
							end
						end
						currTile.tile.type = self.currentPipe
						self.selectedTileOverlay.x = currTile.x
						self.selectedTileOverlay.y = currTile.y
						self:setPipe(currTile, self.prevTile)
						--TODO:this is a possible bug,currently no diagonal pipe error check exists
					else
						self.isPiping = false
						self.isBadPiping = true
						self.selectedTileOverlay.x = currTile.x
						self.selectedTileOverlay.y = currTile.y
						setSequence("badpipe",self.selectedTileOverlay)
					end
				end
			elseif self.isBadPiping == true then
				--selectedTileOverlay.x = currTile.x
				--selectedTileOverlay.y = currTile.y
			end	
		elseif event.phase == "ended" or event.phase == "cancelled" then
			self.selectedTileOverlay.isVisible = false
			self.isPiping = false
			self.isDragging = false
			self.isZooming = false
			self.isBadPiping = false
			self.currentPipe = -1
			--double tap speed == 500
			if ( system.getTimer() - self.doubleTapMark < 500 ) then
				print("double tap!!")
				if ( zoom_id ) then
					transition.cancel(zoom_id.zoom)
					transition.cancel(zoom_id.position)
				end
				if ( self.zoomState == IN ) then
					print("zooming OUT!")
					self.zoomState = OUT
					zoom_id = { zoom=transition.to(currTile.group,{xScale = self.zoomAmt, yScale=self.zoomAmt, transition=easing.outQuad, onComplete=zoomingListener}),
								position=transition.to(currTile.group,{x = 0, y=0, transition=easing.outQuad}) }
				else
					self.zoomState = IN
					--print("currTilex:"..currTile.x.." currTiley:"..currTile.y)
					local targetx = -currTile.x + display.contentWidth/4
					local targety = -currTile.y + display.contentHeight/4
					--print("width:"..display.contentWidth.." height:"..display.contentHeight)
					--print("Before Scaling!x:"..targetx.." y:"..targety)
					if ( targetx > 0 ) then
						targetx = 0
					elseif ( targetx < -display.contentWidth/2 ) then
						targetx = -display.contentWidth/2
					end
					if ( targety > 0 ) then
						targety = 0
					elseif ( targety < -display.contentHeight/2 ) then
						targety = -display.contentHeight/2
					end
					print("TARGET: x:"..targetx.." y:"..targety)
					--targetx = targetx - display.contentWidth/4
					--targety = targety - display.contentHeight/4
					--print("zooming IN!x:"..targetx.." y:"..targety)
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
	
	
    --create grid sprites!!
	for X = 1,gridColumns do
		for Y = 1, gridRows do
			local sprite = display.newImage(debugTexturesImageSheet , debugTexturesSheetInfo:getFrameIndex("grass"))
			--local sprite = display.newSprite(self.sheet, self.sequenceData )--OLD
			
			--[[local sequenceId
			if ( X == 2 and Y == 2 ) then
			    sequenceId = "energy"
				self.grid[X][Y].type = tile.ENERGY
				--sprite:addEventListener( "touch", tileTouchEvent )
			elseif (X == 20 and Y == 10) then
				sequenceId = "tower"
				self.grid[X][Y].type = tile.TOWER
				--sprite:addEventListener( "touch", tileTouchEvent )
			end
			
			if sequenceId then
				sprite:removeSelf()
				sprite = display.newImage(debugTexturesImageSheet , debugTexturesSheetInfo:getFrameIndex(sequenceId))
			end]]--
			
			self.group:insert(sprite)
			sprite:translate(X*tileWidth,Y*tileHeight)
			sprite:addEventListener( "touch", tileTouchEvent )
			
			--sprite:setSequence(sequenceId)
			--sprite:play()
			--sprite.id = sequenceId
			--sprite.gridX = X
			--sprite.gridY = Y
			--sprite.In = pipe.NONE
			--sprite.Out = pipe.NONE
			sprite.group = self.group
            
			self.grid[X][Y].terrain = sprite
            self.grid[X][Y].gridX = X
            self.grid[X][Y].gridY = Y
			sprite.tile = self.grid[X][Y]
		end
	end
    
    --CREATE SOME TOWERS & ENERGY SOURCES HERE
    
end)


Grid.createTileGroup = Grid:makeMethod(function(self, nx, ny )
	self.group = display.newImageGroup( debugTexturesImageSheet )--self.sheet )
	self.group.xMin = -(nx-1)*display.contentWidth - self.halfW
	self.group.yMin = -(ny-1)*display.contentHeight - self.halfH
	self.group.xMax = self.halfW-20
	self.group.yMax = self.halfH-20
	
	function self.group:touch( event )
		if ( "began" == event.phase ) then
			self.xStart = self.x
			self.yStart = self.y
			self.xBegan = event.x
			self.yBegan = event.y
		elseif ( "moved" == event.phase ) then
			local dx = event.x - self.xBegan
			local dy = event.y - self.yBegan
			local x = dx + self.xStart
			local y = dy + self.yStart
			if ( x < self.xMin ) then x = self.xMin end
			if ( x > self.xMax ) then x = self.xMax end
			if ( y < self.yMin ) then y = self.yMin end
			if ( y > self.yMax ) then y = self.yMax end
			self.x = x
			self.y = y
		end
		return true
	end
	--TODO: until multitouch is enabled, don't allow scroll the group
	--Uncomment line below to enable touch scrolling on the grid
	--group:addEventListener( "touch", group )
	
	
	local x = self.halfW
	local y = self.halfH
	
	local xMax = nx * display.contentWidth
	local yMax = ny * display.contentHeight
	
	self:createTiles( x, y, xMax, yMax, self.group )
	
	--This comes after creating tiles so it shows up on top of the grid
	--This guy shows up wherever the players finger is
	--self.selectedTileOverlay = display.newSprite(self.sheet, self.sequenceData )
	self.selectedTileOverlay = display.newImage(debugTexturesImageSheet, debugTexturesSheetInfo:getFrameIndex("overlay") )
	--self.selectedTileOverlay:setSequence("overlay")
	--self.selectedTileOverlay:play()
	self.selectedTileOverlay.alpha = .5
	self.selectedTileOverlay.isVisible = false
	self.group:insert(self.selectedTileOverlay)
	
	local p1 = Pollution:init(pollutionType:init())
	self.group:insert(p1.sprite)

end)

Grid.dispose = Grid:makeMethod(function(self)
	self.group:removeSelf()
	self.group = nil
	self.informationText = nil
	self.selectedTileOverlay = nil
	
	for i = 1, gridColumns do
        for j = 1, gridRows do
            self.grid[i][j].terrain:removeSelf()
			self.grid[i][j].terrain = nil
			self.grid[i][j] = nil
        end
		self.grid[i] = nil
    end
	self.grid = nil
end)

return Grid
--end grid stuff

