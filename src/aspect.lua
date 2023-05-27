-- aspect.lua

-- Aspects include 0 - none, 1 - fire, 2 - water, 3 - plant, 4 - lightning, 
-- 0 is weak to all, 
-- 1 fire is weak to water & strong to plant, lightning
-- 2 water is weak to lightning, plant & strong to fire
-- 3 plant is weak to fire, lightning, & strong to water
-- 4 lightning is weak to fire & strong to water and plant 

function reaction(a, b)  
    if a == b then return 0 end
    if a == 0 then return -1 end
    if b == 0 then return 1 end
    if a == 1 then
        if b == 2 then return -1 end
        if b == 3 or b == 4 then return 1 end
    end
    if a == 2 then
        if b == 3 or b == 4 then return -1 end
        if b == 1 then return 1 end
    end
    if a == 3 then
        if b == 1 or b == 4 then return -1 end
        if b == 2 then return 1 end
    end
    if a == 4 then
        if b == 1 then return -1 end
        if b == 2 or b == 3 then return 1 end
    end
    return 0
end     -- returns -1 if a is weak to b, 
        -- returns 0 if theyre equal
        -- returns 1 if b is weak to a