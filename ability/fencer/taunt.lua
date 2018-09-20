local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

POWER = 2
ARMOR = 2

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Taunt"
end

function ability.help_text()
    return string.format(
        "Reduce target's ARMOR by %i and gain %i POWER",
        ARMOR, POWER
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target, "blue")
    handle:wait(sfx.on_finish)
    map_stat("armor", target, mechanics.add_stat(-ARMOR))
    map_stat("power", caster, mechanics.add_stat(POWER))
    sfx:destroy()
    sa:set_animation("idle")
end

return ability
