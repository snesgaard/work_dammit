local target = require "ability/target"
local sparkle = require "sfx/sparkle"

local heal_effect = {}


local heal = {}
heal.__index = heal

heal.target = {
    type = target.single,
    candidates = function(placement, user)
        return placement
            :filter(target.same_side(user))
            :filter(target.is_alive())
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
    nodes.game:heal(caster, target, 3)
    local pos = nodes.position:get_world(target) - vec2(0, 75)
    local s = nodes.sfx:child(sparkle):set_pos(pos)
    handle:wait(0.5)
    sc:set_animation("idle")
end

return setmetatable(heal, heal)
