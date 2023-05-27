-- camera.lua

Object = require 'dependencies/classic'
Camera = Object:extend()

local shakeWait = 0
local shakeOffset = {x = 0, y = 0}
local shakeTime = 0
local shakeIntensity = 1

local p_x, p_y

local lerpSpeed = 3

function Camera:new(player)
    self.player = player
    self.x = 0
    self.y = 0
    self.screenWidth = 1280
    self.screenHeight = 720
end



function Camera:shake(duration, intensity)
    shakeTime = duration
    shakeIntensity = intensity
end

function Camera:update(dt)
    if shakeTime > 0 then
        shakeTime = shakeTime - dt
        if shakeWait > 0 then
            shakeWait = shakeWait - dt
        else
            shakeOffset.x = love.math.random(-5,5) * shakeIntensity
            shakeOffset.y = love.math.random(-5,5) * shakeIntensity
            shakeWait = 0.01  * (shakeIntensity/3)
        end
    else
        shakeOffset.x = 0
        shakeOffset.y = 0
    end

    p_x = self.player.x
    p_y = self.player.y
    self.x = self.x - (self.x-(p_x+shakeOffset.x)) * math.min(dt*lerpSpeed,1)
    self.y = self.y - (self.y-(p_y+shakeOffset.y)) * math.min(dt*lerpSpeed, 1)
end

function Camera:draw()
    love.graphics.translate(math.floor(-self.x + self.screenWidth/2), math.floor(-self.y + self.screenHeight/2))
    
end
