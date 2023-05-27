-- player.lua

require 'src/entity'
Player = Entity:extend()

local frameTime = 0.1
local frameTimer = 0
local currentFrame = 1
local flipped = 0

local xScaleFactor = 1
local yScaleFactor = 1

local damageTime = 2
local damageTimer = 0

local fusing = false
local fuseTime = 0.4
local fuseTimer = 0
local fuseSpeed = 65
local fuseAcceleration = 1

-- fuse velocity (direction)
local fv_x = 0
local fv_y = 0

function Player:new()
    self.super:new(16, 32, "res/jackal.png")
    self.frames = {}
    for i = 1, 3 do
        for j = 1, 4 do
            self.frames[j + ((i - 1) * 4)] = love.graphics.newQuad((j - 1) * 18, (i - 1) * 34, self.spriteW, self
                .spriteH, self.spritesheetW, self.spritesheetH)
        end
    end
    self.vel = { x = 0, y = 0 }
    self.speed = 300
    self.canWalk = true

    self.aspect = 0
    self.health = 3
    self.dead = false
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function Player:onSpace()
    if self.canWalk then
        fuseTimer = fuseTime
    end
end

function fuseVelocity(t)
    local mult = 4 / fuseTime
    return (-4 * (mult * t - 2) ^ 2) + 16
end

function fuseContraction(t)
    local mult = 4 / fuseTime
    return (mult * math.sqrt(0.125) * t - math.sqrt(0.5)) ^ 2 + 0.5
end

function Player:die()
    self.health = 0
    self.canWalk = false
    self.dead = true
end

function Player:fuse(dt)
    if fuseTimer > 0 then
        if self.canWalk then
            self.canWalk = false
        end
        fuseTimer = math.max(fuseTimer - dt, 0)
        if fv_x == 0 and fv_y == 0 then
            local ffv_x = (1 - (2 * flipped))
            local ffv_y = 0
            self.vel.x = ffv_x * fuseVelocity(fuseTime - fuseTimer) * fuseSpeed
            self.vel.y = ffv_y * fuseVelocity(fuseTime - fuseTimer) * fuseSpeed
            xScaleFactor = 1 + fuseVelocity(fuseTime - fuseTimer) / 4
            yScaleFactor = fuseContraction(fuseTime - fuseTimer)
        else
            self.vel.x = fv_x + fv_x * fuseVelocity(fuseTime - fuseTimer) * fuseSpeed
            self.vel.y = fv_y + fv_y * fuseVelocity(fuseTime - fuseTimer) * fuseSpeed
            if math.abs(fv_x) > math.abs(fv_y) then
                xScaleFactor = 1 + math.abs(fv_x * fuseVelocity(fuseTime - fuseTimer) / 4)
                yScaleFactor = fuseContraction(fuseTime - fuseTimer)
            else
                xScaleFactor = 1
                yScaleFactor = 1 + math.abs(fv_y * fuseVelocity(fuseTime - fuseTimer) / 8)
            end
        end
    else
        if self.canWalk == false then self.canWalk = true end
        local mag = math.sqrt((self.vel.x ^ 2) + (self.vel.y ^ 2))
        if mag == 0 then
            fv_x = 0
            fv_y = 0
        else
            fv_x = self.vel.x / mag
            fv_y = self.vel.y / mag
        end
    end
end

function Player:handleFrames(dt)
    local mag = math.sqrt((self.vel.x ^ 2) + (self.vel.y ^ 2))
    if mag ~= 0 then
        if frameTimer <= 0 then
            if currentFrame == 4 then
                currentFrame = 1
            else
                currentFrame = currentFrame + 1
            end
            frameTimer = frameTime
        else
            frameTimer = frameTimer - dt
        end
    else
        currentFrame = 1
        frameTimer = frameTime
    end
end

function Player:damage()
    if damageTimer == 0 then
        damageTimer = damageTime
        if self.health == 1 then
            self:die()
        end
        self.health = self.health - 1
    end
end

function Player:update(dt)
    if self.canWalk then
        if love.keyboard.isDown("a") then
            self.vel.x = -self.speed
            if flipped == 0 then flipped = 1 end
        elseif love.keyboard.isDown("d") then
            self.vel.x = self.speed
            if flipped == 1 then flipped = 0 end
        else
            self.vel.x = 0
        end
        if love.keyboard.isDown("w") then
            self.vel.y = self.speed
        elseif love.keyboard.isDown("s") then
            self.vel.y = -self.speed
        else
            self.vel.y = 0
        end
    end

    self:fuse(dt)
    self:handleFrames(dt)

    self.x = self.x + self.vel.x * dt
    self.y = self.y - self.vel.y * dt

    self.super.update(self, dt)

    if damageTimer > 0 then
        damageTimer = math.max(damageTimer - dt, 0)
    end

    if self.dead then
        self.canWalk = false
        self.vel.x = 0
        self.vel.y = 0
        if xScaleFactor > 0 and yScaleFactor > 0 then
            xScaleFactor = xScaleFactor - dt
            yScaleFactor = yScaleFactor - dt
        end
    end
end

function Player:draw()
    if xScaleFactor > 0 and yScaleFactor > 0 then
        love.graphics.draw(self.spritesheet, self.frames[currentFrame + (self.aspect * 4)], math.floor(self.x),
            math.floor(self.y), 0, (1 - (2 * flipped)) * xScaleFactor, yScaleFactor, self.spriteW / 2, self.spriteH)
    end
end
