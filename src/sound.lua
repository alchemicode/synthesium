-- sound.lua

local l_a = love.audio

local s_confirm
local s_error

function LoadSound()
    s_confirm = l_a.newSource("res/sfx/confirm.ogg", "static")
    s_error = l_a.newSource("res/sfx/error.ogg", "static")
end

function SFX_PlayConfirm()
    if not s_confirm:isPlaying() then
        s_confirm:play()
    end
end

function SFX_PlayError()
    if not s_error:isPlaying() then
        s_error:play()
    end
end
