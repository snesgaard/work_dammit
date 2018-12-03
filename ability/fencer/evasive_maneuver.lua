local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

AGILITY_COST = 3

ability.target = {
    type = "single",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Evasive Maneuver"
end

function ability.help_text()
    return string.format(
        "If you have %i agility of more, grant shield. Lose %i agility.",
        AGILITY_COST, AGILITY_COST
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target, "blue")
    handle:wait(sfx.on_finish)
    if get_stat("agility", caster) >= AGILITY_COST then
        set_stat("shield", target, 1)
    end
    add_stat("agility", caster, -AGILITY_COST)
    sa:set_animation("idle")
end

return ability
