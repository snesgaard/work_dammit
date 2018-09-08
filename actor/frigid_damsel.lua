local ability = require "ability"
local target = require "ability/target"

local animation = {}

function animation.idle(sprite, dt)
    sprite:loop(dt, "frigid_damsel")
end

function animation.cast(sprite, dt)
    sprite:loop(dt, "frigid_damsel")
end

function animation.attack(sprite, dt)
    dt = sprite:play(dt, "frigid_damsel")
    sprite.on_user("attack")
    sprite:loop(dt, "frigid_damsel")
end

local function submit_ability(id, a)
    local targets = target.candidates(a.target, id)

    return coroutine.yield(a, targets.primary:random())
end

local ai = {}

function ai.stage1(id, abilities)
    abilities = abilities or list(
        ability("frozen_reap"), ability("frozen_reap"),
        ability("hailstorm")
    )
    submit_ability(id, abilities:head())
    abilities = abilities:cycle(1)
    if get_stat("health/current", id) <= 60 then
        return ai.stage2(id, abilities)
    else
        return ai.stage1(id, abilities)
    end
end

function ai.stage2(id, abilities)
    submit_ability(id, ability("thawing_blast"))

    local function inner_action(id, abilities)
        submit_ability(id, abilities:head())
        abilities = abilities:cycle(1)

        return inner_action(id, abilities)
    end

    return inner_action(id, abilities)
end

local function ai_entry(id)
    return ai.stage1(id)
end

local actor = {}

function actor.init_visual(state, id)
    local atlas = get_atlas("art/main_actors")
    local Sprite = require "animation/sprite"
    state.sprite[id] = Sprite.create(atlas, animation)
end

function actor.init_state(state, id)
    state.health.max[id] = 80
    --state.health.current[id] = 80
    state.power[id] = 2
    state.armor[id] = 4
    state.agility[id] = 3
    state.name[id] = "Frigid Damsel"
    state.script[id] = coroutine.wrap(ai_entry)
    state.ability[id] = list(
        ability("frozen_armor"), ability("frozen_reap"),
        ability("hailstorm"), ability("thawing_blast")
    )
end

function actor.__tostring()
    return "Frigid Damsel"
end

actor.__index = actor
return setmetatable(actor, actor)
