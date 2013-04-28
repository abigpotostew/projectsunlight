--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:928b730a4f58e356c47721c411203968$
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
            x=226,
            y=152,
            width=68,
            height=68,

        },
        {
            -- city
            x=4,
            y=4,
            width=132,
            height=132,

        },
        {
            -- downstop
            x=152,
            y=374,
            width=68,
            height=68,

        },
        {
            -- energy
            x=152,
            y=300,
            width=68,
            height=68,

        },
        {
            -- grass
            x=152,
            y=226,
            width=68,
            height=68,

        },
        {
            -- horizontal
            x=152,
            y=152,
            width=68,
            height=68,

        },
        {
            -- leftdown
            x=374,
            y=78,
            width=68,
            height=68,

        },
        {
            -- leftstop
            x=300,
            y=78,
            width=68,
            height=68,

        },
        {
            -- lefttop
            x=226,
            y=78,
            width=68,
            height=68,

        },
        {
            -- overlay
            x=152,
            y=78,
            width=68,
            height=68,

        },
        {
            -- pollution
            x=438,
            y=4,
            width=68,
            height=68,

        },
        {
            -- pollution_coal
            x=364,
            y=4,
            width=68,
            height=68,

        },
        {
            -- pollution_geothermal
            x=290,
            y=4,
            width=68,
            height=68,

        },
        {
            -- pollution_nuclear
            x=216,
            y=4,
            width=68,
            height=68,

        },
        {
            -- pollution_solar
            x=78,
            y=438,
            width=68,
            height=68,

        },
        {
            -- pollution_water
            x=78,
            y=364,
            width=68,
            height=68,

        },
        {
            -- pollution_wind
            x=78,
            y=290,
            width=68,
            height=68,

        },
        {
            -- rightdown
            x=78,
            y=216,
            width=68,
            height=68,

        },
        {
            -- rightstop
            x=142,
            y=4,
            width=68,
            height=68,

        },
        {
            -- righttop
            x=78,
            y=142,
            width=68,
            height=68,

        },
        {
            -- stone
            x=4,
            y=438,
            width=68,
            height=68,

        },
        {
            -- topstop
            x=4,
            y=364,
            width=68,
            height=68,

        },
        {
            -- tower
            x=4,
            y=290,
            width=68,
            height=68,

        },
        {
            -- vertical
            x=4,
            y=216,
            width=68,
            height=68,

        },
        {
            -- water
            x=4,
            y=142,
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
    ["topstop"] = 22,
    ["tower"] = 23,
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
