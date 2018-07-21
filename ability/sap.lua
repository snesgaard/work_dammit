local target = require "ability/target"
local slash = require "sfx/slash"

local ARMOR = 3

local sap = {}

function sap.name()
    return "Sap"
end

sap.target = {
    type = target.single,
    candidates = function(placement, user)
        return placement
            :filter(target.opposite_side(user))
            :filter(target.is_alive())
    end
}

function sap.help_text(user)
    return string.format(
        "Remove %i ARMOR.\n\nRemove all ARMOR, if target ARMOR > 8.", ARMOR
    )
end

function sap.test_setup(user, target)
    nodes.game:set_stat("armor", target, 5)
end

function sap.run(handle, caster, target)
    local sc = visual.sprite[caster]
    sc:set_animation("chant")
    handle:wait(0.5)
    sc:set_animation("cast")
    local function f(v)
        return math.max(0, v - ARMOR)
    end
    nodes.game:map_stat("armor", target, f)
    local pos = nodes.position:get_world(target) - vec2(0, 75)
    local s = nodes.sfx:child(slash):set_pos(pos)
    handle:wait(0.5)
    sc:set_animation("idle")
end

return sap
