local spAnimInfo = require "src.libs.swiftping.sp_animinfo"
local spAnimSet = require "src.libs.swiftping.sp_animset"
local audio = require "audio"
local class = require "src.class"
local assetManager = require "src.assetManager"
local util = require "src.util"

local Actor = class:makeSubclass("Actor")

Actor:makeInit(function(class, self)
	class.super:initWith(self)
	
	--need to set a position sometime later
	--The sprite needs all the animations
	self.sprite = nil
	--set anims in some other child class, and Actor:load() will load those from asset manager
	self.anims = {}
	self.sounds = {}

	self.physics = {
		mass = 1,
		friction = 0.3,
		bounce = 0.2,
		bodyType = "kinematic",
		category = "",
		collidables = {},
		gravity = 0,
	 }
	 util.errorOnUndefinedProperty(self.physics)

	self.scale = 1
	util.errorOnUndefinedProperty(self.scale)

	self.animSet = nil --the actual animations
	self.soundSet = nil --the actual sounds

	return self
end)

--Put all the animations and sounds in anims & sounds, then call this
ActorType.load = ActorType:makeMethod(function(self)

	self.animSet = spAnimSet.init(nil)
	for animName, anim in pairs(self.anims) do
		self.animSet:addAnim(assetManager.getAsset(anim, "anim"), animName)
	end

	self.soundSet = {}
	for soundName, sound in pairs(self.sounds) do
		self.soundSet[soundName] = assetManager.getAsset("sfx/" .. sound, "sound")
	end
end)

return ActorType
