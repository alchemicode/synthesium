-- enemy.lua

require 'src/entity'
require 'src/aspect'
local gfx = love.graphics
Enemy = Entity:extend()

local frameTime = 0.0625
local deathFrameTime = 0.0909090909

function Enemy:new(player, asp)
    self.super.new(self, 16, 32, "res/sprites/enemy-" .. tostring(asp) .. ".png", 0)
    self.frames = {}
    self.deathFrames = {}
    for i = 1, 11 do
        self.frames[i] = gfx.newQuad((i - 1) * 16, 0, self.spriteW, self.spriteH, self.spritesheetW,
            self.spritesheetH)
        self.deathFrames[i] = gfx.newQuad((i - 1) * 16, 32, self.spriteW, self.spriteH, self.spritesheetW,
            self.spritesheetH)
    end
    self.vel = { x = 0, y = 0 }
    self.accel = { x = 0, y = 0 }
    self.speed = 180
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

-- Switches between animation frames based on frameTimers
function Enemy:handleFrames(dt)
    if self.frameTimer <= 0 then
        if self.currentFrame == 11 then
            if self.deadTimer == 0 then
                self.currentFrame = 1
            end
        else
            self.currentFrame = self.currentFrame + 1
        end
        self.frameTimer = frameTime
    else
        self.frameTimer = self.frameTimer - dt
    end
end

-- Checks for overlap(collision) between this and another entity
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

function Enemy:die(gd, p)
    if self.deadTimer == 0 then
        self.deadTimer = 0.9
        self.currentFrame = 1
        SFX_PlayDeath()
        self:updateKills(gd, p)
    end
end

-- Updates GameData and player instance kill counts
function Enemy:updateKills(gd, player)
    if self.aspect == 1 then
        gd.fireKills = gd.fireKills + 1
        player.fireEssence = player.fireEssence + 1
    elseif self.aspect == 2 then
        gd.waterKills = gd.waterKills + 1
        player.waterEssence = player.waterEssence + 1
    elseif self.aspect == 3 then
        gd.elecKills = gd.elecKills + 1
        player.elecEssence = player.elecEssence + 1
    elseif self.aspect == 4 then
        gd.earthKills = gd.earthKills + 1
        player.earthEssence = player.earthEssence + 1
    end
end

-- Updates GameData and player instance fusion counts
function Enemy:updateFusions(gd)
    if self.aspect == 1 then
        gd.fireFusions = gd.fireFusions + 1
    elseif self.aspect == 2 then
        gd.waterFusions = gd.waterFusions + 1
    elseif self.aspect == 3 then
        gd.elecFusions = gd.elecFusions + 1
    elseif self.aspect == 4 then
        gd.earthFusions = gd.earthFusions + 1
    end
end

-- Checks and handles collisions with player
function Enemy:checkPlayerCollision(gd, p)
    if self:checkOverlap(p) and not p.dead then
        if p.canWalk then
            local r = Reaction(p.aspect, self.aspect)
            if r == -1 then
                p:damage()
            elseif r == 1 then
                self:die(gd, p)
            end
        else
            if p.aspect ~= self.aspect then
                p.aspect = self.aspect
                self:updateFusions(gd)
            end
        end
    end
end

-- Switches enemy between wander and chase states
function Enemy:behavior(p, dt)
    local dist = math.sqrt((self.x - p.x) ^ 2 + (self.y - p.y) ^ 2)
    if dist < 256 and p.aspect ~= self.aspect then
        if self.state < 1 then self.state = 1 end
        self:chase(p, dist, dt)
    else
        if self.state == 1 and self.state ~= 2 then self.state = 0 end
        self:wander(p, dt)
    end
end

-- Sends enemy in random direction for random length of time
function Enemy:wander(p, dt)
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
            self.wanderTimer = math.random(2, 5)
        end
    end
end

-- Enemy chases player very aggressively until out of range
function Enemy:chase(p, dist, dt)
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

function Enemy:update(gd, p, dt)
    -- Handling sprite direction
    if self.state ~= 2 then
        if self.vel.x > 0 then
            self.flipped = 1
        end
        if self.vel.x <= 0 then
            self.flipped = 0
        end

        if self.deadTimer == 0 then
            self:behavior(p, dt)
            self:checkPlayerCollision(gd, p)
        end

        self:handleFrames(dt)

        self.x = Clamp(32,self.x + self.vel.x * dt, (MapW-1)*32)
        self.y = Clamp(32,self.y + self.vel.y * dt, (MapH-1)*32)

        -- Updates last_x and last_y
        self.super.update(self, dt)

        if self.deadTimer > 0 then
            self.vel.x = 0
            self.vel.y = 0
            self.deadTimer = math.max(self.deadTimer - dt, 0)
            if self.deadTimer == 0 then self.state = 2 end
        end
    end
end

function Enemy:inView(cam_x, cam_y)
    local width = gfx.getWidth()
    local height = gfx.getHeight()
    return self.x >= cam_x - width / 2
        and self.x - 16 <= cam_x + width / 2
        and self.y >= cam_y - height / 2
        and self.y - 32 <= cam_y + height / 2
end

function Enemy:draw(cam_x, cam_y)
    if self.state < 2 then
        if self:inView(cam_x, cam_y) then 
            if self.aspect == 1 then
                gfx.setColor(1,0.4,0,0.25)
                gfx.circle("fill", math.floor(self.x), math.floor(self.y)-16, 24)
                gfx.setColor(1,1,1,1)
            end
            local frame
            if self.deadTimer == 0 then
                frame = self.frames[self.currentFrame]
            else
                frame = self.deathFrames[self.currentFrame]
            end
            gfx.draw(self.spritesheet, frame, math.floor(self.x), math.floor(self.y),
                0,
                (1 - (2 * self.flipped)) * self.xScaleFactor, self.yScaleFactor, self.spriteW/2, self.spriteH)
            
            
        end
    end
end
