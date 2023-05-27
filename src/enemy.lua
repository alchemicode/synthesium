-- enemy.lua

require 'src/entity'
require 'src/aspect'
Enemy = Entity:extend()

local frameTime = 0.0625



function Enemy:new(player, asp)
    self.super.new(self, 16, 32, "res/enemy-" .. tostring(asp) .. ".png", 0)
    self.frames = {}
    for i = 1, 14 do
        self.frames[i] = love.graphics.newQuad(0, (i - 1) * 32, self.spriteW, self.spriteH, self.spritesheetW,
            self.spritesheetH)
    end
    self.vel = { x = 0, y = 0 }
    self.accel = { x = 0, y = 0 }
    self.speed = 150
    self.aspect = asp
    self.canWalk = true
    self.player = player
    self.deadTimer = 0
    self.md_x = 0
    self.md_y = 0

    -- 0: wander
    -- 1: chase
    -- 2: dead (deallocate)
    self.state = 0

    self.frameTimer = 0
    self.currentFrame = 1
    self.flipped = 0

    self.xScaleFactor = 1
    self.yScaleFactor = 1

    self.wanderTimer = 0
    self.wanderCooldown = 0
end

function Enemy:handleFrames(dt)
    if self.frameTimer <= 0 then
        if self.currentFrame == 11 then
            self.currentFrame = 1
        else
            self.currentFrame = self.currentFrame + 1
        end
        self.frameTimer = frameTime
    else
        self.frameTimer = self.frameTimer - dt
    end
end

function Enemy:checkOverlap(e)
    local o_left = e.x - (e.spriteW / 2)
    local o_right = e.x + (e.spriteW / 2)
    local o_top = e.y - e.spriteH
    local o_bottom = e.y
    local left = self.x - (self.spriteW / 2)
    local right = self.x + (self.spriteW / 2)
    local top = self.y - self.spriteH
    local bottom = self.y
    return right >= o_left
        and left <= o_right
        and bottom >= o_top
        and top <= o_bottom
end

function Enemy:die()
    if self.dead == false then
        print("FUCKKKKKK")
        self.deadTimer = 1
    end
end

function Enemy:checkPlayerCollision(p)
    if self:checkOverlap(p) and p.dead == false then
        if p.canWalk then
            local r = reaction(p.aspect, self.aspect)
            if r == -1 then
                p:damage()
            elseif r == 1 then
                self:die()
            end
        else
            p.aspect = self.aspect
        end
    end
end

function Enemy:behavior(p, dt)
    local dist = math.sqrt((self.x - p.x) ^ 2 + (self.y - p.y) ^ 2)
    if dist > 256 then
        if self.accel.x ~= 0 then self.accel.x = 0 end
        if self.accel.y ~= 0 then self.accel.y = 0 end
        if self.state ~= 0 and self.state ~= 2 then self.state = 0 end
        if self.wanderTimer > 0 then
            self.vel.x = self.md_x * self.speed
            self.vel.y = self.md_y * self.speed
            self.wanderTimer = math.max(self.wanderTimer - dt, 0)
            if self.wanderTimer == 0 then self.wanderCooldown = math.random(3, 10) end
        else
            if self.wanderCooldown > 0 then
                self.vel.x = 0
                self.vel.y = 0
                self.wanderCooldown = math.max(self.wanderCooldown - dt, 0)
            else
                self.md_x = math.random(-10, 10) / 10
                self.md_y = math.random(-10, 10) / 10
                self.wanderTimer = math.random(2, 6)
            end
        end
    else
        if self.state ~= 1 then self.state = 1 end
        if self.wanderTimer > 0 then
            self.vel.x = 0
            self.vel.y = 0
            self.wanderTimer = 0
        end
        if self.wanderCooldown > 0 then self.wanderCooldown = 0 end
        local rmd_x = p.x - self.x
        local rmd_y = p.y - self.y
        local v_x = rmd_x * self.speed / (dist)
        local v_y = rmd_y * self.speed / (dist)
        if dist > 16 then
            self.vel.x = 100 * v_x * dt
            self.vel.y = 100 * v_y * dt
        else
            self.vel.x = 0
            self.vel.y = 0
        end
    end
end

function Enemy:fusion(p)

end

function Enemy:update(p, dt)
    if self.vel.x > 0 then
        self.flipped = 1
    end
    if self.vel.x <= 0 then
        self.flipped = 0
    end

    self:handleFrames(dt)

    self:behavior(p, dt)
    self:checkPlayerCollision(p)

    self.x = self.x + self.vel.x * dt
    self.y = self.y + self.vel.y * dt

    self.super.update(self, dt)

    if self.deadTimer > 0 then
        self.deadTimer = math.max(self.deadTimer - dt, 0)
    end
end

function Enemy:draw()
    if self.deadTimer == 0 and self.state < 2 then
        love.graphics.draw(self.spritesheet, self.frames[self.currentFrame], math.floor(self.x), math.floor(self.y), 0,
            (1 - (2 * self.flipped)) * self.xScaleFactor, self.yScaleFactor, self.spriteW / 2, self.spriteH)
    end
    if self.deadTimer > 0 then

    end
end
