-- deathtile.lua

require 'src/entity'
DeathTile = Entity:extend()

function DeathTile:new(w,h,x,y)
    self.x = x
    self.y = y
    self.spriteW = w
    self.spriteH = h
    self.last_x = 0
    self.last_y = 0
    self.collision = 0 
end

function DeathTile:checkOverlap(e)
    local o_left = e.x - (e.spriteW/2)
    local o_right = e.x + (e.spriteW/2)
    local o_top = e.y - e.spriteH
    local o_bottom = e.y
    local left = self.x
    local right = self.x + (self.spriteW)
    local top = self.y
    local bottom = self.y + self.spriteH
    return o_bottom > top
    and o_bottom < bottom
    and o_left > left
    and o_right < right
end
