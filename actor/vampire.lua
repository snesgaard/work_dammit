local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        dt = sprite:play(dt, "vampire_cast/cast2idle")
    end
    local rng = love.math.random
    sprite:loop(dt, "vampire_idle", rng(1, 8))
end

function animations.chant(sprite, dt)
    dt = sprite:play(dt, "vampire_cast/idle2chant")
    sprite:loop(dt, "vampire_cast/chant")
end

function animations.cast(sprite, dt)
    dt = sprite:play(dt, "vampire_cast/chant2cast")
    sprite:loop(dt, "vampire_cast/cast")
end

function animations.dash(sprite, dt)
    sprite:loop(dt, "vampire_dash/dash")
end

function animations.attack(sprite, dt)
    dt = sprite:play(dt, "vampire_dash/windup")
    sprite.on_user("attack")
    dt = sprite:play(dt, "vampire_dash/attack")
    sprite.on_user("done")
    sprite:loop(dt, "vampire_dash/post_attack")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "vampire_dash/evade")
end

local function attack_offset(sprite)
    local frames = sprite.atlas:get_animation("vampire_dash/attack")
    local origin = frames:head().hitbox.origin
    local attack = frames:head().hitbox.attack
    return math.ceil(attack.cx - origin.cx) * sprite.scale
end

local actor = {}

function actor.init_visual(state, id)
    local atlas = get_atlas("art/main_actors")
    local Sprite = require "animation/sprite"
    state.sprite[id] = Sprite.create(atlas, animations)
    state.sprite[id].attack_offset = attack_offset

    state.icon[id] = function(x, y, w, h)
        local icon_atlas = get_atlas("art/icons")
        icon_atlas:draw("vampire", x, y, 0, 2, 2)
    end
end

function actor.init_state(state, id)
    state.health.max[id] = 15
    --state.health.current[id] = 80
    state.power[id] = 2
    state.armor[id] = 2
    state.agility[id] = 3
    state.name[id] = "Kindred"
    state.ability[id] = list(
        ability("attack")
    )
end



function actor.__tostring()
    return "Vampire"
end

actor.__index = actor
return setmetatable(actor, actor)
