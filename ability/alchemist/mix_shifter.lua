local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

ability.unlock = {
    "alchemist.red_shift", "alchemist.blue_shift"
}

ability.target = {
    type = "self",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Mix: Shifter"
end

function ability.help_text()
    return string.format(
        ""
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    handle:wait(0.2)
    sa:set_animation("idle")
end

return ability
