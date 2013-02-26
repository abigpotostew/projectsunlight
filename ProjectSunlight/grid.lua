-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.

require("tile")

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

local grid = {} --a 2D array of sprites and their id and stuff

for i = 1, gridColumns do
	grid[i] = {}
	for j = 1, gridRows do
		grid[i][j] = 0
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

local function setSpritePipe(sprite)
	if sprite.left or sprite.right then
		sprite:setSequence("horz",sprite)
	elseif sprite.up or sprite.down then
		sprite:setSequence("vert",sprite)
	end
	if sprite.left and sprite.up then
		sprite:setSequence("leftup",sprite)
	end
	if sprite.left and sprite.down then
		sprite:setSequence("leftdown",sprite)
	end
	if sprite.right and sprite.up then
		sprite:setSequence("rightup",sprite)
	end
	if sprite.right and sprite.down then
		sprite:setSequence("rightdown",sprite)
	end
end

local function setSequence(seqName, sprite)
	sprite:setSequence(seqName)
	sprite:play()
end

local function createTiles( x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	
	
	
	--Event listener for each tile!
	local function getTileAtGridPosition( event )
		local currTile = event.target
		
		if event.phase == "began" then
			startTile = currTile
			prevTile = currTile
			selectedTileOverlay.isVisible = true
			selectedTileOverlay.x = currTile.x
			selectedTileOverlay.y = currTile.y
			--print(selectedTileOverlay.visible)
		elseif event.phase == "moved" then
			if currTile ~= prevTile then
				selectedTileOverlay.x = currTile.x
				selectedTileOverlay.y = currTile.y
				if currTile.x < prevTile.x then
					prevTile.left = true
				end
				if currTile.x > prevTile.x then
					prevTile.right = true
				end
				if currTile.y < prevTile.y then
					prevTile.up = true
				end
				if currTile.y > prevTile.y then
					prevTile.down = true
				end
				setSpritePipe(prevTile)
				--TODO:this is a possible bug,currently no diagonal pipe error check exists
			end
		elseif event.phase == "ended" or event.phase == "cancelled" then
			selectedTileOverlay.isVisible = false
		end
		
		prevTile = currTile
		
		-- Update the information text to show the tile at the selected position
		informationText.text = "Tile At Selected Grid Position Is: " .. currTile.id
		--print(tile)
	
		-- Transition the player to the selected grid position
		--transition.to( player, { x = tile.x, y = tile.y, transition = easing.outQuad } )	
		
		return true --important
	end
	
	for iX = 1,gridColumns do
		for jY = 1, gridRows do
			local sprite = display.newSprite(sheet, sequenceData )
			group:insert(sprite)
			sprite:translate(iX*tileWidth,jY*tileHeight)
			local sequenceId = "grass"--sequences[(iX+jY)%10]
			sprite:setSequence(sequenceId)
			sprite:play()
			sprite.id = sequenceId
			sprite.left = false
			sprite.right = false
			sprite.up = false
			sprite.down = false
			--grid[iX][jY] = Tile(sprite,sequenceId)
			
			sprite:addEventListener( "touch", getTileAtGridPosition )
		end
	end
end



local function createTileGroup( nx, ny )
	local group = display.newImageGroup( sheet )
	group.xMin = -(nx-1)*display.contentWidth - halfW
	group.yMin = -(ny-1)*display.contentHeight - halfH
	group.xMax = halfW
	group.yMax = halfH
	
	
	
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

