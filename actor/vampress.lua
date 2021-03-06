local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        dt = sprite:play(dt, "vampress_cast/cast2idle")
    end
    local rng = love.math.random
    sprite:loop(dt, "vampress_idle", rng(1, 8))
end

function animations.chant(sprite, dt)
    dt = sprite:play(dt, "vampress_cast/idle2chant")
    sprite:loop(dt, "vampress_cast/chant")
end

function animations.cast(sprite, dt)
    dt = sprite:play(dt, "vampress_cast/chant2cast")
    sprite:loop(dt, "vampress_cast/cast")
end

function animations.dash(sprite, dt)
    sprite:loop(dt, "vampress_dash/dash")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "vampress_dash/evade")
end

function animations.attack(sprite, dt)
    dt = sprite:play(dt, "vampress_cast/chant2cast")
    sprite.on_user("attack")
    dt = sprite:play(dt, "vampress_cast/cast")
    sprite.on_user("done")
    sprite:loop(dt, "vampress_cast/cast")
end

local function attack_offset(sprite)
    local frames = sprite.atlas:get_animation("vampress_cast/chant2cast")
    local origin = frames[2].hitbox.origin
    local attack = frames[2].hitbox.cast
    return math.ceil(attack.cx - origin.cx) * sprite.scale
end

local function create_sprite(atlas)
    local sprite = Sprite.create(atlas)

    for key, anime in pairs(animations) do
        sprite:register(key, anime)
    end

    sprite.attack_offset = attack_offset
    return sprite
end

local actor = {}

function actor.__tostring()
    return "Vampress"
end

function actor.init_visual(state, id)
    local atlas_path = "art/main_actors"
    local atlas = state.atlas[atlas_path] or Atlas.create(atlas_path)
    local sprite = create_sprite(atlas)

    state.atlas[atlas_path] = atlas
    state.sprite[id] = sprite
end

function actor.init_state(state, id)
    state.health.current[id] = 12
    state.health.max[id] = 12
    state.power[id] = 0
    state.armor[id] = 3
    state.agility[id] = 3
    state.name[id] = "Vampress"
    state.ability[id] = list(
        ability.acid
    )
end

actor.__index = actor
actor = setmetatable(actor, actor)

return actor
