local Atlas = require "atlas"
local Sprite = require "animation/sprite"
local ability = require "ability"
local target = require "ability/target"

local animations = {}

function animations.idle(sprite, dt, prev)
    if prev == animations.cast then
        --dt = sprite:play(dt, "gunner_cast/cast2idle")
    end
    local rng = love.math.random
    sprite:loop(dt, "golem_idle", rng(1, 8))
end

function animations.chant(sprite, dt)
    dt = sprite:play(dt, "golem_cast/idle2chant")
    sprite:loop(dt, "golem_cast/chant")
end

function animations.chant(sprite, dt)
    dt = sprite:play(dt, "golem_cast/idle2chant")
    sprite:loop(dt, "golem_cast/chant")
end

function animations.cast(sprite, dt)
    dt = sprite:play(dt, "golem_cast/chant2cast")
    sprite:loop(dt, "golem_cast/cast")
end

function animations.dash(sprite, dt)
    sprite:loop(dt, "golem_dash/dash")
end

function animations.attack(sprite, dt)
    dt = sprite:play(dt, "golem_dash/windup")
    sprite.on_user("attack")
    dt = sprite:play(dt, "golem_dash/attack")
    for i = 1, 3 do
        dt = sprite:play(dt, "golem_dash/post_attack")
    end
    sprite.on_user("done")
    sprite:loop(dt, "golem_dash/post_attack")
end

function animations.evade(sprite, dt)
    sprite:loop(dt, "golem_dash/evade")
end

local function submit_ability(id, a)
    local targets = target.candidates(a.target, id)
    return coroutine.yield(a, targets.primary:random())
end

local function ai(id)
    local l = list(
        ability("attack"),
        ability("attack"),
        function()
            local a = ability("stoneskin_oil")
            coroutine.yield(a, id)
        end
    )

    local HEALTH = get_stat("health/max", id)
    while get_stat("health/current", id) > HEALTH / 2 do
        local a = l:head()
        l = l:cycle(1)
        if type(a) == "function" then
            a()
        else
            submit_ability(id, a)
        end
    end

    nodes.enrage_monitor:enrage(id)

    while true do
        submit_ability(id, ability("thawing_blast"))
        submit_ability(id, ability("attack"))
        submit_ability(id, ability("hailstorm"))
    end

    return ai(id, blast_done)
end

local function attack_offset(sprite)
    local frames = sprite.atlas:get_animation("golem_dash/attack")
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
    visual.ui_offset[id] = 100
end

function actor.init_state(state, id)
    state.health.max[id] = 80
    state.power[id] = 0
    state.armor[id] = 0
    state.agility[id] = 0
    state.name[id] = "Golem"
    state.script[id] = coroutine.wrap(ai)
    state.ability[id] = list(
        ability("attack")
    )
end

function actor.__tostring()
    return "Golem"
end

actor.__index = actor
return setmetatable(actor, actor)
