local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        --dt = sprite:play(dt, "gunner_cast/cast2idle")
    end
    local rng = love.math.random
    sprite:loop(dt, "runesmith_idle", rng(1, 8))
end

local actor = {}

function actor.init_visual(state, id)
    local atlas = get_atlas("art/main_actors")
    local Sprite = require "animation/sprite"
    state.sprite[id] = Sprite.create(atlas, animations)
end

function actor.init_state(state, id)
    state.health.max[id] = 80
    --state.health.current[id] = 80
    state.power[id] = 4
    state.armor[id] = 3
    state.agility[id] = 1
    state.name[id] = "Rune Smith"
    state.ability[id] = list(
        ability("attack")
    )
end

function actor.__tostring()
    return "Rune Smith"
end

actor.__index = actor
return setmetatable(actor, actor)
