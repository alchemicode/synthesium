-- entity.lua
Object = require 'dependencies/classic'
Entity = Object:extend()

function Entity:new(sW, sH, spritepath, col)
    self.x = 0
    self.y = 0
    self.last_x = 0
    self.last_y = 0
    self.collision = col    -- 0: overlap - No physical collision, trigger detection
                            -- 1: collision - Physical collision

    self.spritesheet = love.graphics.newImage(spritepath)
    self.spriteW = sW
    self.spriteH = sH
    self.spritesheetW = self.spritesheet:getWidth()
    self.spritesheetH = self.spritesheet:getHeight()

end

function Entity:translate(new_x,new_y)
    self.x = new_x
    self.y = new_y
end

function Entity:update(dt)
    self.last_x = self.x
    self.last_y = self.y
end

-- This function assumes both entities have their origin at bottom center
function Entity:checkOverlap(e)
    local o_left = e.x - (e.spriteW/2)
    local o_right = e.x + (e.spriteW/2)
    local o_top = e.y - e.spriteH
    local o_bottom = e.y
    local left = self.x - (self.spriteW/2)
    local right = self.x + (self.spriteW/2)
    local top = self.y - self.spriteH
    local bottom = self.y
    return right >= o_left 
    and left <= o_right 
    and bottom >= o_top 
    and top <= o_bottom
end

function Clamp(val, min, max)
	if val < min then
		val = min
	elseif max < val then
		val = max
	end
	return val
end