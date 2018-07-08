local target = require "ability/target"
local sfx = require "sfx/thunder"

local thunder = {}

thunder.target = {
    type = target.single,
    candidates = function(placement, user)
        return placement
            :filter(target.opposite_side(user))
            :filter(target.is_alive())
    end
}

function thunder.run(handle, caster, target)
    local sc = visual.sprite[caster]
    sc:set_animation("chant")
    handle:wait(0.5)
    sc:set_animation("cast")
    nodes.game:damage(caster, target, 3)
    local pos = nodes.position:get_world(target)
    local s = nodes.sfx:child(sfx):set_pos(pos)
    handle:wait(0.5)
    sc:set_animation("idle")
end

return thunder
