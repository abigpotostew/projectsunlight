-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.

local constants = require("src.constants")
local class = require "src.class"

local Grid = class:makeSubclass("Grid")

local tile =
	{
	NO_PIPE = -1, --can't build pipes on grid locations here
	ENERGY = -2,
	TOWER = -3,
	EMPTY = 0 --a grid position that has no pipe yet
}
-- protect my table now
local tile = constants.protect_table (tile)
local pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}
local pipe = constants.protect_table(pipe)

local IN = 0
local OUT = 1

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

    self.isDragging = false
    self.isPiping = false
    self.isZooming = false
    self.isBadPiping = false

    self.grid = {} --a 2D array of pipe informations

    for i = 1, gridColumns do
        self.grid[i] = {}
        for j = 1, gridRows do
            self.grid[i][j] = {}
            self.grid[i][j].type = tile.EMPTY
            self.grid[i][j].sprite = 0
            self.grid[i][j].In = pipe.NONE
            self.grid[i][j].Out = pipe.NONE
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

    self.informationText = display.newText( "Tile At Selected Grid Position Is: ", 40, 10,  native.systemFontBold, 16 )

    
    
    
    
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
	local out = false
	local type = self:getTileType(currTile)
	--local grid = currTile.grid
	--You can start dragging a pipe when the initial touch begins on an energy source
	--or on the end of a pipe
	if type == tile.ENERGY or 
		( type > tile.EMPTY and 
		  currTile.grid.Out == pipe.NONE 
		  and currTile.grid.In > pipe.NONE) then
		out = true
	end
	return out
end)

Grid.canPipeHere = Grid:makeMethod(function(self, _sprite)
	local out = true
	local type = self:getTileType(_sprite)
	if type == tile.NO_PIPE or type == tile.ENERGY or type == tile.TOWER or type > tile.EMPTY then
		out = false
	end
	return out
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
	local tile = _sprite.grid
	if (tile.In == pipe.LEFT and tile.Out == pipe.UP) or
	   (tile.In == pipe.UP and tile.Out == pipe.LEFT) then
		_sprite:setSequence("leftup",_sprite)
	elseif (tile.In == pipe.UP and tile.Out == pipe.RIGHT) or
		   (tile.In == pipe.RIGHT and tile.Out == pipe.UP) then
		_sprite:setSequence("rightup",_sprite)
	elseif (tile.In == pipe.LEFT and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.LEFT) then
		_sprite:setSequence("leftdown",_sprite)
	elseif (tile.In == pipe.RIGHT and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.RIGHT) then
		_sprite:setSequence("rightdown",_sprite)
	elseif (tile.In == pipe.LEFT and tile.Out == pipe.RIGHT) or
		   (tile.In == pipe.RIGHT and tile.Out == pipe.LEFT) then
		_sprite:setSequence("horz",_sprite)
	elseif (tile.In == pipe.UP and tile.Out == pipe.DOWN) or
		   (tile.In == pipe.DOWN and tile.Out == pipe.UP) then
		_sprite:setSequence("vert",_sprite)
	elseif tile.Out == pipe.UP or tile.In == pipe.UP then
		_sprite:setSequence("upstop",_sprite)
	elseif tile.Out == pipe.DOWN or tile.In == pipe.DOWN then
		_sprite:setSequence("downstop",_sprite)
	elseif tile.Out == pipe.RIGHT or tile.In == pipe.RIGHT then
		_sprite:setSequence("rightstop",_sprite)
	elseif tile.Out == pipe.LEFT or tile.In == pipe.LEFT then
		_sprite:setSequence("leftstop",_sprite)
	else
		_sprite:setSequence("grass",_sprite)
	end

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
	
	self.prevTile.grid.Out = direction
	currTile.grid.In = getOppositeDirection(direction)
	
	setSpritePipe(currTile)
	if self.prevTile.grid.type ~= tile.ENERGY then
		setSpritePipe(prevTile)
	end
	
	--("currTile: in:"..currTile.In.." out:"..currTile.Out)
	--print("prevTile: in:"..prevTile.In.." out:"..prevTile.Out)
end)

local function setSequence(seqName, sprite)
	sprite:setSequence(seqName)
	sprite:play()
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

local function distance(A,B)
	return math.sqrt((B.gridX-A.gridX)*(B.gridX-A.gridX)+(B.gridY-A.gridY)*(B.gridY-A.gridY))*tileSize
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
			--print(getTileType(currTile))
			local tileType = self:getTileType(currTile)
			if tileType == tile.EMPTY then
				self.isDragging = true
				currTile.group.xStart = currTile.group.x
				currTile.group.yStart = currTile.group.y
				currTile.group.xBegan = event.x
				currTile.group.yBegan = event.y
				print("start scrolling")
			elseif self:canStartPipe(currTile) == true then
				self.isPiping = true
				self.startTile = currTile
				self.prevTile = currTile
				self.selectedTileOverlay.isVisible = true
				self.selectedTileOverlay.x = currTile.x
				self.selectedTileOverlay.y = currTile.y
				setSequence("overlay",self.selectedTileOverlay)
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
				local dx = event.x - currTile.group.xBegan
				local dy = event.y - currTile.group.yBegan
				local x = dx + currTile.group.xStart
				local y = dy + currTile.group.yStart
				if ( x < currTile.group.xMin ) then x = currTile.group.xMin end
				if ( x > currTile.group.xMax ) then x = currTile.group.xMax end
				if ( y < currTile.group.yMin ) then y = currTile.group.yMin end
				if ( y > currTile.group.yMax ) then y = currTile.group.yMax end
				currTile.group.x = x
				currTile.group.y = y
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
							if self.prevTile.grid.type <= 0 then
								self.currentPipe = self.pipeCount
							else
								self.currentPipe = self.prevTile.grid.type
							end
						end
						currTile.grid.type = self.currentPipe
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
					print("currTilex:"..currTile.x.." currTiley:"..currTile.y)
					local targetx = currTile.x - display.contentWidth/self.zoomAmt
					local targety = currTile.x - display.contentHeight/self.zoomAmt
					print("width:"..display.contentWidth.." height:"..display.contentHeight)
					print("TARGET: x:"..targetx.." y:"..targety)
					if ( targetx > 0 ) then
						targetx = 0
					elseif ( targetx < -display.contentWidth/2 ) then
						targetx = display.contentWidth/2
					end
					if ( targety > 0 ) then
						targety = 0
					elseif ( targety < -display.contentHeight/2 ) then
						targety = display.contentHeight/2
					end
					--targetx = targetx - display.contentWidth/4
					--targety = targety - display.contentHeight/4
					print("zooming IN!\nx:"..targetx.." y:"..targety)
					zoom_id = { zoom=transition.to(currTile.group,{xScale = 1, yScale=1, transition=easing.outQuad, onComplete=zoomingListener}), 
								position=transition.to(currTile.group,{x=targetx, y=targety, transition=easing.outQuad}) }
				end
				self.doubleTapMark = 0
			else
				self.doubleTapMark = system.getTimer()
			end
		
		end
		
		self.prevTile = currTile
		
		-- Update the information text to show the tile at the selected position
		self.informationText.text = "Selected Grid Type: " .. currTile.grid.type .. " Current Pipe: " .. self.currentPipe
		--print(tile)
	
		-- Transition the player to the selected grid position
		--transition.to( player, { x = tile.x, y = tile.y, transition = easing.outQuad } )	
		
		return true --important
	end
	
	--create grid sprites!!
	for X = 1,gridColumns do
		for Y = 1, gridRows do
			local sprite = display.newSprite(self.sheet, self.sequenceData )
			self.group:insert(sprite)
			sprite:translate(X*tileWidth,Y*tileHeight)
			local sequenceId
			if ( X == 2 and Y == 2 ) then
			    sequenceId = "water"
				self.grid[X][Y].type = tile.ENERGY
				sprite:addEventListener( "touch", tileTouchEvent )
			elseif (X == 20 and Y == 10) then
				sequenceId = "stone"
				self.grid[X][Y].type = tile.TOWER
				sprite:addEventListener( "touch", tileTouchEvent )
			else
                sequenceId = "grass"
				sprite:addEventListener( "touch", tileTouchEvent )
            end
			
			sprite:setSequence(sequenceId)
			sprite:play()
			sprite.id = sequenceId
			sprite.gridX = X
			sprite.gridY = Y
			sprite.In = pipe.NONE
			sprite.Out = pipe.NONE
			sprite.group = group
			self.grid[X][Y].sprite = sprite
			sprite.grid = self.grid[X][Y]
		end
	end
end)


Grid.createTileGroup = Grid:makeMethod(function(self, nx, ny )
	self.group = display.newImageGroup( self.sheet )
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
	self.selectedTileOverlay = display.newSprite(self.sheet, self.sequenceData )
	self.selectedTileOverlay:setSequence("overlay")
	self.selectedTileOverlay:play()
	self.selectedTileOverlay.alpha = .5
	self.selectedTileOverlay.isVisible = false
	self.group:insert(self.selectedTileOverlay)

end)

return Grid
--end grid stuff

