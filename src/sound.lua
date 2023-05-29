-- sound.lua

local l_a = love.audio

local s_confirm
local s_error
local s_heal
local s_damage
local s_death
local s_fuse

local m_synth

function LoadSound()
    s_confirm = l_a.newSource("res/sfx/confirm.ogg", "static")
    s_confirm:setVolume(0.5)
    s_error = l_a.newSource("res/sfx/error.ogg", "static")
    s_error:setVolume(0.5)
    s_heal = l_a.newSource("res/sfx/heal.ogg", "static")
    s_heal:setVolume(0.7)
    s_damage = l_a.newSource("res/sfx/damage.ogg", "static")
    s_damage:setVolume(0.7)
    s_death = l_a.newSource("res/sfx/death.ogg", "static")
    s_death:setVolume(0.5)
    s_fuse = l_a.newSource("res/sfx/fuse.ogg", "static")
    s_fuse:setVolume(0.5)

    m_synth = l_a.newSource("res/music/Synthesium.ogg", "static")
    m_synth:setVolume(0.25)
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

function SFX_PlayHeal()
    if not s_heal:isPlaying() then
        s_heal:play()
    end
end

function SFX_PlayDamage()
    if not s_damage:isPlaying() then
        s_damage:play()
    end
end

function SFX_PlayDeath()
    if not s_death:isPlaying() then
        s_death:play()
    end
end

function SFX_PlayFuse()
    if not s_fuse:isPlaying() then
        s_fuse:play()
    end
end

function Music_PlaySynthesium()
    if not m_synth:isPlaying() then
        m_synth:play()
    end
end

function Music_PauseSynthesium()
    if not m_synth:isPlaying() then
        m_synth:pause()
    end
end

function Music_StopSynthesium()
    if m_synth:isPlaying() then
        m_synth:stop()
    end
end
