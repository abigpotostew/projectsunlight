-- Create a default level - For documentation on all available parameters, read "defaults.lua" in the levels directory!
local util = require "src.util"
local level = require "src.level"
local levelDefaults = require "levels.defaults"
local huts = require "actors.huts"
local birds = require "actors.birds"
local ammos = require "actors.ammos"

-- The bouncy Level.


local l = level:init()
levelDefaults(l)

l.gravity = { x = 4,  y = 20.0 } -- The level's gravitational acceleration
l.width = 2000 -- The size of the level's long direction.

l.background = "art/scenery/level4_bk.png" -- The level's static background image

l:TimelineSpawnHut{hutType = huts.BrickHut(), x = 1700, y = 1250}
l:TimelineSpawnHut{hutType = huts.BrickHut(), x = 1200, y = 1250}
--l:TimelineSpawnHut{hutType = huts.BrickHut(), x = 800, y = 1250}
--l:TimelineSpawnHut{hutType = huts.BrickHut(), x = 890, y = 625}

--l.groundBounce = 0.03 -- How bouncy the level's ground is
--l.groundFriction = 0.3 -- How much friction the level's ground has

l.ammoType = ammos.tomato()
l.ammoType.transition.flightSpeed = 10
l.ammoType.physics.rotation = -60
l.ammoType.scale = 0.4-- Start size
l.ammoType.speed = 1200
l.ammoType.mass = 1
l.ammoType.lifeSpan = 1.6

l:SetTrajectoryStart(1, { -- Comes in from upper left
	position = {x = 10, y = 10},
	angle = -10,
	speed = 223,
})

l:SetTrajectoryStart(2, { -- Comes in from middle left and grazes barns in reverse order
	position = {x = 300, y = 150},
	angle = -5,
	speed = 140,
})

l:SetTrajectoryStart(3, { -- Comes in from the top middle and hits the right two crates
	position = {x = 100, y = -10},
	angle = 20,
	speed = 300,
})

-- Timeline: Specify events that happen in sequence, including bird spawning
l:TimelineWait(1.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.5}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 0.5}
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.5}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 0.5}
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.0}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 0.5}
l:TimelineSpawnBird{bird = 1, trajectory = 1, wait = 1.0}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.0}
l:TimelineSpawnBird{bird = 1, trajectory = 1, wait = 1.0}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.0}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 4, trajectory = 1, wait = 1.0}

l:TimelineWait(2.0)
l:TimelineSpawnBird{bird = 1, trajectory = 1, wait = 1.0}



--l:TimelineWait(3.0)

--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 1.0}

--l:TimelineWait(1.0)

--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 0.5}
--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 0.5}
--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 0.5}

--l:TimelineWait(3.0)

--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 0.5}
--l:TimelineSpawnBird{bird = 1, trajectory = 2, wait = 0.5}
--l:TimelineSpawnBird{bird = 4, trajectory = 2, wait = 0.5}


return l.scene
