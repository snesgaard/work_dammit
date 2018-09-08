local icespike = require "sfx/icespike"
local target = require "ability/target"
local mech = require "game/mechanics"
local common = require "animation/common"

local DAMAGE = 1
local ARMOR = 0

local SPIKES = 5

local storm = {}

storm.target = {
    type = "multiple",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function storm.name()
    return "Hail Storm"
end

function storm.help_text()
    return string.format(
        "Deal %i damage to and remove %i ARMOR from three random foes.",
        DAMAGE, ARMOR
    )
end

function storm.run(handle, caster, targets)
    local _, sa = common.cast(handle, caster)

    local dir = nodes.position:get(caster) > 0 and "left" or "right"
    local poses = targets:map(function(id)
        return nodes.position:get_world(id)
    end)
    local x_min = poses
        :map(function(p) return p.x end)
        :reduce(math.min) - 100
    local x_max = poses
        :map(function(p) return p.x end)
        :reduce(math.max)

    local context = {
        x_max = x_max + 200,
        x_min = x_min - 50,
        y = poses:head().y,
        alive = true,
        rng = love.math.random
    }

    local function spike_life()
        local spike = nodes.sfx:child(icespike)
        while context.alive do
            local s = context.rng()
            local pos = vec2(
                context.x_min * (1 - s) + context.x_max * s, context.y
            )
            spike:fly(pos, dir)
            handle:wait(spike.on_shattered)
        end
        spike:destroy()
    end

    local function spawner()
        for i = 1, SPIKES do
            handle:wait(0.15)
            handle:fork(spike_life)
            handle:wait(0.1)
            handle:fork(spike_life)
            handle:wait(0.1)
            handle:fork(spike_life)
        end
    end

    handle:fork(spawner)

    handle:wait(1.0)
    local valid_targets = targets
    for i = 1, 3 do
        handle:wait(0.25)
        local id = valid_targets:random()
        if id then
            nodes.game:damage(caster, id, DAMAGE)
            map_stat(
                "armor", id, mech.map_stat(function(v) return v - ARMOR end)
            )
        end
        valid_targets = valid_targets:filter(function(id)
            return nodes.game:is_alive(id)
        end)
    end
    sa:set_animation("idle")
    context.alive = false

end

return storm
