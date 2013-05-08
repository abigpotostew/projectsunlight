--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:7f11a15ba1c26e45c84a54a25354b585$
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
            x=2,
            y=416,
            width=68,
            height=68,

        },
        {
            -- city
            x=213,
            y=2,
            width=132,
            height=132,

        },
        {
            -- downstop
            x=2,
            y=346,
            width=68,
            height=68,

        },
        {
            -- energy
            x=422,
            y=212,
            width=68,
            height=68,

        },
        {
            -- grass
            x=352,
            y=212,
            width=68,
            height=68,

        },
        {
            -- horizontal
            x=212,
            y=276,
            width=68,
            height=68,

        },
        {
            -- leftdown
            x=282,
            y=212,
            width=68,
            height=68,

        },
        {
            -- leftstop
            x=142,
            y=211,
            width=68,
            height=68,

        },
        {
            -- lefttop
            x=72,
            y=211,
            width=68,
            height=68,

        },
        {
            -- overlay
            x=2,
            y=211,
            width=68,
            height=68,

        },
        {
            -- pipe
            x=2,
            y=2,
            width=209,
            height=67,

        },
        {
            -- pollution
            x=422,
            y=142,
            width=68,
            height=68,

        },
        {
            -- pollution_coal
            x=352,
            y=142,
            width=68,
            height=68,

        },
        {
            -- pollution_geothermal
            x=212,
            y=206,
            width=68,
            height=68,

        },
        {
            -- pollution_nuclear
            x=282,
            y=142,
            width=68,
            height=68,

        },
        {
            -- pollution_solar
            x=142,
            y=141,
            width=68,
            height=68,

        },
        {
            -- pollution_water
            x=72,
            y=141,
            width=68,
            height=68,

        },
        {
            -- pollution_wind
            x=2,
            y=141,
            width=68,
            height=68,

        },
        {
            -- rightdown
            x=212,
            y=136,
            width=68,
            height=68,

        },
        {
            -- rightstop
            x=142,
            y=71,
            width=68,
            height=68,

        },
        {
            -- righttop
            x=72,
            y=71,
            width=68,
            height=68,

        },
        {
            -- stone
            x=2,
            y=71,
            width=68,
            height=68,

        },
        {
            -- tower
            x=417,
            y=72,
            width=68,
            height=68,

        },
        {
            -- upstop
            x=347,
            y=72,
            width=68,
            height=68,

        },
        {
            -- vertical
            x=417,
            y=2,
            width=68,
            height=68,

        },
        {
            -- water
            x=347,
            y=2,
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
    ["pipe"] = 11,
    ["pollution"] = 12,
    ["pollution_coal"] = 13,
    ["pollution_geothermal"] = 14,
    ["pollution_nuclear"] = 15,
    ["pollution_solar"] = 16,
    ["pollution_water"] = 17,
    ["pollution_wind"] = 18,
    ["rightdown"] = 19,
    ["rightstop"] = 20,
    ["righttop"] = 21,
    ["stone"] = 22,
    ["tower"] = 23,
    ["upstop"] = 24,
    ["vertical"] = 25,
    ["water"] = 26,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
