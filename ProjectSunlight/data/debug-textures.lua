--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:e51e4fd056eb9e76739fef02bef32056$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- badpipe
            x=142,
            y=352,
            width=68,
            height=68,

        },
        {
            -- city
            x=2,
            y=2,
            width=132,
            height=132,

        },
        {
            -- downstop
            x=142,
            y=282,
            width=68,
            height=68,

        },
        {
            -- energy
            x=142,
            y=212,
            width=68,
            height=68,

        },
        {
            -- grass
            x=142,
            y=142,
            width=68,
            height=68,

        },
        {
            -- horizontal
            x=422,
            y=72,
            width=68,
            height=68,

        },
        {
            -- leftdown
            x=352,
            y=72,
            width=68,
            height=68,

        },
        {
            -- leftstop
            x=282,
            y=72,
            width=68,
            height=68,

        },
        {
            -- lefttop
            x=212,
            y=72,
            width=68,
            height=68,

        },
        {
            -- overlay
            x=142,
            y=72,
            width=68,
            height=68,

        },
        {
            -- pollution
            x=416,
            y=2,
            width=68,
            height=68,

        },
        {
            -- pollution_coal
            x=346,
            y=2,
            width=68,
            height=68,

        },
        {
            -- pollution_geothermal
            x=276,
            y=2,
            width=68,
            height=68,

        },
        {
            -- pollution_nuclear
            x=206,
            y=2,
            width=68,
            height=68,

        },
        {
            -- pollution_solar
            x=72,
            y=416,
            width=68,
            height=68,

        },
        {
            -- pollution_water
            x=72,
            y=346,
            width=68,
            height=68,

        },
        {
            -- pollution_wind
            x=72,
            y=276,
            width=68,
            height=68,

        },
        {
            -- rightdown
            x=72,
            y=206,
            width=68,
            height=68,

        },
        {
            -- rightstop
            x=136,
            y=2,
            width=68,
            height=68,

        },
        {
            -- righttop
            x=72,
            y=136,
            width=68,
            height=68,

        },
        {
            -- stone
            x=2,
            y=416,
            width=68,
            height=68,

        },
        {
            -- tower
            x=2,
            y=346,
            width=68,
            height=68,

        },
        {
            -- upstop
            x=2,
            y=276,
            width=68,
            height=68,

        },
        {
            -- vertical
            x=2,
            y=206,
            width=68,
            height=68,

        },
        {
            -- water
            x=2,
            y=136,
            width=68,
            height=68,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["badpipe"] = 1,
    ["city"] = 2,
    ["downstop"] = 3,
    ["energy"] = 4,
    ["grass"] = 5,
    ["horizontal"] = 6,
    ["leftdown"] = 7,
    ["leftstop"] = 8,
    ["lefttop"] = 9,
    ["overlay"] = 10,
    ["pollution"] = 11,
    ["pollution_coal"] = 12,
    ["pollution_geothermal"] = 13,
    ["pollution_nuclear"] = 14,
    ["pollution_solar"] = 15,
    ["pollution_water"] = 16,
    ["pollution_wind"] = 17,
    ["rightdown"] = 18,
    ["rightstop"] = 19,
    ["righttop"] = 20,
    ["stone"] = 21,
    ["tower"] = 22,
    ["upstop"] = 23,
    ["vertical"] = 24,
    ["water"] = 25,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
