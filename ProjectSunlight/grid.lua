-- A grid system for our levels. Also impliments multitouch

--http://developer.coronalabs.com/content/pinch-zoom-gesture
--Go there for multitouch (pinch, zoom) once ready.




--Begin grid stuff
local tileSize = 64

local tileWidth = tileSize --we have square tiles
local tileHeight = tileSize --we have square tiles
local gridColumns = 32 -- number of grid tiles across
local gridRows = 24 -- number of grid tiles down
local tileSheetWidth = 192 --width of sheet image
local tileSheetHeight = 256 --height of sheet image

local sheetData = { 
	width=tileWidth,
	height=tileHeight,
	numFrames=10,
	sheetContentWidth=tileSheetWidth,
	sheetContentHeight=tileSheetHeight
	}
local sheet = graphics.newImageSheet( "tiles.png", sheetData )

--local sequenceData = {}

local w = tileSize
local h = tileSize
local halfW = w*0.5
local halfH = h*0.5

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

local function createTiles( x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	
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
		{name="water", start=10, count = 1,time=0}
	}
	
	for iX = 1,gridColumns do
		for jY = 1, gridRows do
			local sprite = display.newSprite(sheet, sequenceData )
			group:insert(sprite)
			sprite:translate(iX*tileWidth,jY*tileHeight)
			sprite:setSequence(sequences[(iX+jY)%10])
			sprite:play()
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

	return group
end

local nx = 2
local ny = 2
local group = createTileGroup( nx, ny )

--until multitouch zoom is implemented, just zoom out all the way.
group:scale(1/2,0.5)

--end grid stuff

