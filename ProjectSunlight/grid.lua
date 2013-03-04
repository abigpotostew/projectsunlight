-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.

require("tile")
require("constants")

tile =
  {
  NO_PIPE = -1, --can't build pipes on grid locations here
  ENERGY_SRC = -2,
  TOWER = -3,
  EMPTY = 0 --a grid position that has no pipe yet
  }

-- protect my table now
tile = protect_table (tile)

pipe = {NONE = -1, LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3}
pipe = protect_table(pipe)

-- debug stuff
local informationText = nil

--finger drag tile
local selectedTileOverlay = nil
--local tileProperties = nil

--end debug stuff

--Begin grid stuff
local tileSize = 64

local tileWidth = tileSize --we have square tiles
local tileHeight = tileSize --we have square tiles
local gridColumns = 32 -- number of grid tiles across
local gridRows = 24 -- number of grid tiles down
local tileSheetWidth = 256 --width of sheet image
local tileSheetHeight = 256 --height of sheet image

--must initially be set to 1, just cus!
local pipeCount = 1;
local currentPipe = -1;

local isScrolling = false
local isPiping = false
local isZooming = false
local isBadPipe = false

local grid = {} --a 2D array of pipe informations

for i = 1, gridColumns do
	grid[i] = {}
	for j = 1, gridRows do
		grid[i][j] = {}
		grid[i][j].type = tile.EMPTY
		grid[i][j].sprite = 0
		grid[i][j].In = pipe.NONE
		grid[i][j].Out = pipe.NONE
	end
end

local sheetData = { 
	width=tileWidth,
	height=tileHeight,
	numFrames=15,
	sheetContentWidth=tileSheetWidth,
	sheetContentHeight=tileSheetHeight
	}
local sheet = graphics.newImageSheet( "tiles.png", sheetData ) --load the actual spritesheet

--each tile can be any one of these tiles
--use spite:setSequence("FRAME NAME") to swap out the animation
local sequenceData = {
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
	{name="downstop", start=15, count = 1,time=0}
}

local w = tileSize
local h = tileSize
local halfW = w*0.5
local halfH = h*0.5

--For dragging pipes
local startTile = nil
local prevTile = nil

local sequences = {}
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

--build a tile table, which keeps track of the sprite and it's current animation (id)
local function buildTile(_sprite, _id)
	return { sprite=_sprite, id=_id}
end

-- Return the type from the mirror 2d array grid that has pipe info
local function getTileType(_sprite)
	return grid[_sprite.gridX][_sprite.gridY].type
end

local function canStartPipe(currTile)
	local out = false
	local type = getTileType(_sprite)
	local grid = currTile.grid
	--You can start dragging a pipe when the initial touch begins on an energy source
	--or on the end of a pipe
	if type == tile.ENERGY or ( type > tile.EMPTY and grid.Out >= pipe.None and grid.In == pipe.NONE) then
		out = true
		print("starting pipe")
	end
	return out
end

local function canPipeHere(_sprite)
	local out = true
	local type = getTileType(_sprite)
	if type == tile.NO_PIPE or type == tile.ENERGY or type == tile.TOWER or type > tile.EMPTY then
		out = false
	end
	return out
end

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
local function setPipe(currTile, prevTile)
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
	
	prevTile.grid.Out = direction
	currTile.grid.In = getOppositeDirection(direction)
	
	setSpritePipe(currTile)
	if prevTile.grid.type ~= tile.ENERGY then
		setSpritePipe(prevTile)
	end
	
	--("currTile: in:"..currTile.In.." out:"..currTile.Out)
	--print("prevTile: in:"..prevTile.In.." out:"..prevTile.Out)
end

local function setSequence(seqName, sprite)
	sprite:setSequence(seqName)
	sprite:play()
end



local function createTiles( x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	
	--Event listener for each tile!
	local function tileTouchEvent( event )
		local currTile = event.target
		
		if event.phase == "began" then
			--print(getTileType(currTile))
			local tileType = getTileType(currTile)
			if getTileType(currTile) == tile.EMPTY then
				isDragging = true
				currTile.group.xStart = currTile.group.x
				currTile.group.yStart = currTile.group.y
				currTile.group.xBegan = event.x
				currTile.group.yBegan = event.y
				print("start scrolling")
			else
				if canStartPipe(currTile) == true then
					
				end
				isPiping = true
				startTile = currTile
				prevTile = currTile
				selectedTileOverlay.isVisible = true
				selectedTileOverlay.x = currTile.x
				selectedTileOverlay.y = currTile.y
				
				print("start piping")
			end
		elseif event.phase == "moved" then
			if isDragging == true then
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
			elseif isPiping == true then
				if currTile ~= prevTile then
					local canPipe = (canPipeHere(prevTile) == true and currentPipe < 0) or (canPipeHere(currTile))
					if canPipe == true then
						if currentPipe < 0 then
							currentPipe = pipeCount
						end
						currTile.grid.type = currentPipe
						selectedTileOverlay.x = currTile.x
						selectedTileOverlay.y = currTile.y
						setPipe(currTile, prevTile)
						--TODO:this is a possible bug,currently no diagonal pipe error check exists
					else
						
					end
				end
			end
		elseif event.phase == "ended" or event.phase == "cancelled" then
			selectedTileOverlay.isVisible = false
			isPiping = false
			isDragging = false
			isZooming = false
			isBadPipe = false
			currentPipe = -1
		end
		
		prevTile = currTile
		
		-- Update the information text to show the tile at the selected position
		informationText.text = "Tile At Selected Grid Position Is: " .. currTile.id
		--print(tile)
	
		-- Transition the player to the selected grid position
		--transition.to( player, { x = tile.x, y = tile.y, transition = easing.outQuad } )	
		
		return true --important
	end
	
	--create grid sprites!!
	for X = 1,gridColumns do
		for Y = 1, gridRows do
			local sprite = display.newSprite(sheet, sequenceData )
			group:insert(sprite)
			sprite:translate(X*tileWidth,Y*tileHeight)
			local sequenceId
			if ( X == 2 and Y == 2 ) then
			    sequenceId = "water"
				grid[X][Y].type = tile.ENERGY
				sprite:addEventListener( "touch", tileTouchEvent )
			elseif (X == 20 and Y == 10) then
				sequenceId = "stone"
				grid[X][Y].type = tile.TOWER
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
			grid[X][Y].sprite = sprite
			sprite.grid = grid[X][Y]
		end
	end
	
	
end



local function createTileGroup( nx, ny )
	local group = display.newImageGroup( sheet )
	group.xMin = -(nx-1)*display.contentWidth - halfW
	group.yMin = -(ny-1)*display.contentHeight - halfH
	group.xMax = halfW-20
	group.yMax = halfH-20
	
	function group:touch( event )
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
	
	
	local x = halfW
	local y = halfH
	
	local xMax = nx * display.contentWidth
	local yMax = ny * display.contentHeight
	
	createTiles( x, y, xMax, yMax, group )
	
	--This comes after creating tiles so it shows up on top of the grid
	--This guy shows up wherever the players finger is
	selectedTileOverlay = display.newSprite(sheet, sequenceData )
	selectedTileOverlay:setSequence("overlay")
	selectedTileOverlay:play()
	selectedTileOverlay.alpha = .5
	selectedTileOverlay.isVisible = false
	group:insert(selectedTileOverlay)

	return group
end

local nx = 2
local ny = 2
local group = createTileGroup( nx, ny )

--until multitouch zoom is implemented, just zoom out all the way.
group:scale(1,1)

informationText = display.newText( "Tile At Selected Grid Position Is: ", 40, 10,  native.systemFontBold, 16 )

--end grid stuff

