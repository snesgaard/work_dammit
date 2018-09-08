local target = require "ability/target"
local sparkle = require "sfx/sparkle"

local HEAL = 30

local heal = {}

function heal.name()
    return "Heal"
end

function heal.help_text(user)
    return string.format("Restore %i health.", HEAL)
end

heal.target = {
    type = "single",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function heal.test_setup(user, target)
    nodes.game.actor.health.current[target] = 1
end

function heal.run(handle, caster, target)
    local sc = visual.sprite[caster]
    sc:set_animation("chant")
    handle:wait(0.5)
    sc:set_animation("cast")
    nodes.game:heal(caster, target, HEAL)
    local pos = nodes.position:get_world(target) - vec2(0, 75)
    local s = nodes.sfx:child(sparkle):set_pos(pos)
    handle:wait(0.5)
    sc:set_animation("idle")
end

return setmetatable(heal, heal)
