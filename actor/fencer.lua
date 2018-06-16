local Atlas = require "atlas"
local Sprite = require "animation/sprite"

local fencer = {}

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
    dt = sprite:play(dt, "fencer_dash/attack")
    sprite:loop(dt, "fencer_dash/post_attack")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "fencer_dash/evade")
end

local function create_sprite(atlas)
    local sprite = Sprite.create(atlas)
    for key, anime in pairs(animations) do
        sprite:register(key, anime)
    end
    return sprite
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
    --state.icon.color[id] = icon_atlas:icon("fencer_large")
    --state.icon.bw[id] = icon_atlas:icon("fencer_bw")
end

function fencer.init_state(state, id)
    return state
        :set("max_health/" .. id, 10)
        :set("agility/" .. id, 3)
        :set("power/" .. id, 4)
        :set("name/" .. id, "Fencer")
end

return fencer
