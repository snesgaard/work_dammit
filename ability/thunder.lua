local target = require "ability/target"
local sfx = require "sfx/thunder"

local DAMAGE = 10

local thunder = {}

function thunder:__tostring()
    return "Thunder"
end

function thunder.help_text(user)
    return string.format(
        "Deal %i damage twice.",
        DAMAGE
    )
end

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
    for i = 1, 2 do
        nodes.game:damage(caster, target, DAMAGE)
        local pos = nodes.position:get_world(target)
        local s = nodes.sfx:child(sfx):set_pos(pos)
        handle:wait(0.75)
    end
    sc:set_animation("idle")
end

return thunder
