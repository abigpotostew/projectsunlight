-- 
-- Abstract: SpriteTilesComplex
-- By "complex", we mean it's more work; you specify the data for each frame manually.
--
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

--display.setDefault( "background", 255 )
display.setStatusBar( display.HiddenStatusBar )

local tileWidth = 32
local tileHeight = 32
local gridColumns = 24
local gridRows = 32
local tileSheetWidth = 192
local tileSheetHeight = 256

local sheetData = { 
	width=tileWidth,
	height=tileHeight,
	numFrames=10,
	sheetContentWidth=tileSheetWidth/2, --not sure why this works
	sheetContentHeight=tileSheetHeight/2 --not sure why this works
	}
local sheet = graphics.newImageSheet( "tiles.png", sheetData )

--local sequenceData = {}

local w = 32
local h = 32
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
	group:addEventListener( "touch", group )
	
	
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

local prevTime = system.getTimer()
local fps = display.newText( "30", 30, 47, nil, 24 )
fps:setTextColor( 255 )
fps.prevTime = prevTime

local function enterFrame( event )
	local curTime = event.time
	local dt = curTime - prevTime
	prevTime = curTime
	if ( (curTime - fps.prevTime ) > 100 ) then
		-- limit how often fps updates
		fps.text = string.format( '%.2f', 1000 / dt )
	end
end
Runtime:addEventListener( "enterFrame", enterFrame )
