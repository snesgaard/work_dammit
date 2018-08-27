local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        dt = sprite:play(dt, "gunner_cast/cast2idle")
    end
    sprite:loop(dt, "gunner_idle")
end

function animations.chant(sprite, dt)
    sprite:loop(dt, "gunner_cast/chant")
end

function animations.cast(sprite, dt)
    dt = sprite:play(dt, "gunner_cast/chant2cast")
    sprite:loop(dt, "gunner_cast/cast")
end

function animations.dash(sprite, dt)
    sprite:loop(dt, "gunner_dash/dash")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "gunner_dash/evade")
end

function animations.attack(sprite, dt)
    dt = sprite:play(dt, "gunner_cast/chant2cast")
    sprite.on_user("attack")
    dt = sprite:play(dt, "gunner_cast/cast")
    sprite.on_user("done")
    sprite:loop (dt, "gunner_cast/cast")
end

local function attack_offset(sprite)
    local frames = sprite.atlas:get_animation("gunner_cast")
    local origin = frames[6].hitbox.origin
    local attack = frames[6].hitbox.cast
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

local alchemist = {}

function alchemist.__tostring()
    return "Alchemist"
end

function alchemist.init_visual(state, id)
    local atlas_path = "art/main_actors"
    local atlas = state.atlas[atlas_path] or Atlas.create(atlas_path)
    local sprite = create_sprite(atlas)

    state.atlas[atlas_path] = atlas
    state.sprite[id] = sprite
    --state.icon[id] = gfx.newImage("art/fencer_icon.png")
end

function alchemist.init_state(state, id)
    state.health.max[id] = 15
    state.health.current[id] = 15
    state.power[id] = 2
    state.agility[id] = 5
    state.name[id] = "Alchemist"
    state.ability[id] = list(
        ability.acid, ability.potion, ability.hailstorm
    )
end

return alchemist
