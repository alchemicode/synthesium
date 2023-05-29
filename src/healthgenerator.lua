-- healthgenerator.lua

require 'src/entity'
HealthGenerator = Entity:extend()

local gfx = love.graphics

function HealthGenerator:new(x, y, p, gd, asp)
    self.super.new(self, 32,37,"res/sprites/healthGenerator.png", 1)
    self.x = x
    self.y = y
    
    self.frames = {}
    for i = 1, 5 do
        table.insert(self.frames, gfx.newQuad((i - 1) * 32, 0, self.spriteW, self
                .spriteH, self.spritesheetW, self.spritesheetH))
    end

    self.showUI = false

    self.aspect = asp
    self.player = p
    self.gameData = gd

end

function HealthGenerator:checkOverlap(e)
    local o_left = e.x - (e.spriteW/2)
    local o_right = e.x + (e.spriteW/2)
    local o_top = e.y - e.spriteH
    local o_bottom = e.y
    local left = self.x
    local right = self.x + self.spriteW
    local top = self.y-5
    local bottom = self.y + self.spriteH/2
    return right >= o_left 
    and left <= o_right 
    and bottom >= o_top 
    and top <= o_bottom
end

function HealthGenerator:checkCollision(e)
    if self:checkOverlap(e) then
        e.x = e.last_x
        e.y = e.last_y
    end
end

function HealthGenerator:interact(p, asp)
    local req = 5
    if self.aspect == asp then req = 3 end
    if asp == 1 then 
        if p.fireEssence >= req then
            p.fireEssence = p.fireEssence - req
            p.health = p.health+1
            self.aspect = asp
            SFX_PlayHeal()
        else
            SFX_PlayError()
        end
    elseif asp == 2 then
        if p.waterEssence >= req then
            p.waterEssence = p.waterEssence - req
            p.health = p.health+1
            self.aspect = asp
            SFX_PlayHeal()
        else
            SFX_PlayError()
        end
    elseif asp == 3 then
        if p.elecEssence >= req then
            p.elecEssence = p.elecEssence - req
            p.health = p.health+1
            self.aspect = asp
            SFX_PlayHeal()
        else
            SFX_PlayError()
        end
    elseif asp == 4 then
        if p.earthEssence >= req then
            p.earthEssence = p.earthEssence - req
            p.health = p.health+1
            self.aspect = asp
            SFX_PlayHeal()
        else
            SFX_PlayError()
        end
    end
    
end

function HealthGenerator:update(dt)
    local dist = Distance(self.x+self.spriteW/2,self.y+self.spriteH,self.player.x, self.player.y)
    self.showUI = dist < 96
end

function HealthGenerator:inView(cam_x, cam_y)
    local width = gfx.getWidth()
    local height = gfx.getHeight()
    local p_x = self.x
    local p_y = self.y
    return p_x >= cam_x - width / 2
        and p_x - 32 <= cam_x + width / 2
        and p_y >= cam_y - height / 2
        and p_y - 32 <= cam_y + height / 2
end

function HealthGenerator:draw(cam_x,cam_y)
    if self:inView(cam_x, cam_y) then
        gfx.draw(self.spritesheet, self.frames[self.aspect+1], math.floor(self.x), math.floor(self.y-5))
    end
end


