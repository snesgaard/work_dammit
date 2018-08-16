local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"

local fencer = {}
fencer.__index = fencer
fencer = setmetatable(fencer, fencer)

local animation_aliases = {
    idle = "fencer_idle",
    attack = "fencer_attack/attack",
    cast = "fencer_cast",
    dash = "fencer_attack/dash",
    evade = "fencer_attack/evade",
}

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        dt = sprite:play(dt, "fencer_cast/cast2idle")
    end
    sprite:loop(dt, "fencer_idle")
end

function animations.chant(sprite, dt)
    dt = sprite:play(dt, "fencer_cast/idle2chant")
    sprite:loop(dt, "fencer_cast/chant")
end

function animations.cast(sprite, dt)
    dt = sprite:play(dt, "fencer_cast/chant2cast")
    sprite:loop(dt, "fencer_cast/cast")
end

function animations.dash(sprite, dt)
    sprite:loop(dt, "fencer_dash/dash")
end

function animations.attack(sprite, dt)
    dt = sprite:play(dt, "fencer_dash/windup")
    sprite.on_user("attack")
    dt = sprite:play(dt, "fencer_dash/attack")
    sprite.on_user("done")
    sprite:loop(dt, "fencer_dash/post_attack")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "fencer_dash/evade")
end

local function attack_offset(sprite)
    local frames = sprite.atlas:get_animation("fencer_dash/attack")
    local origin = frames:head().hitbox.origin
    local attack = frames:head().hitbox.attack
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

function fencer.__tostring()
    return "Fencer"
end

function fencer.init_visual(state, id)
    --local atlas_path = "res/sprites/misc"
    local atlas_path = "art/main_actors"
    local atlas = state.atlas[atlas_path] or Atlas.create(atlas_path)
    local sprite = create_sprite(atlas)--atlas:sprite(animation_aliases)
    local icon_path = "res/sprites/icon"
    --local icon_atlas = state.atlas[icon_path] or Atlas.create(icon_path)

    state.atlas[atlas_path] = atlas
    state.atlas[icon_path] = icon_atlas
    state.sprite[id] = sprite
    state.icon[id] = gfx.newImage("art/fencer_icon.png")
end

function fencer.init_state(state, id)
    state.health.max[id] = 10
    state.health.current[id] = 10
    state.power[id] = 3
    state.agility[id] = 9
    state.name[id] = "Fencer"
    state.ability[id] = list(
        ability.attack, ability.heal, ability.sap
    )
end

return fencer
