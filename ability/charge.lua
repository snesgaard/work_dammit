local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

ability.target = {
    type = "single",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Charge"
end

function ability.help_text()
    return string.format(
        "Deal double damage on next attack"
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target)
    handle:wait(sfx.on_finish)
    sfx:destroy()
    set_stat("charge", target, 1)
    sa:set_animation("idle")
end

return ability
