local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

ability.target = {
    type = "self",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

ability.unlock = {
    "vampire.summon_bat"
}

function ability.name()
    return "Chant: Summon Familiar"
end

function ability.help_text()
    return ""
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)

    handle:wait(0.4)

    sa:set_animation("idle")
end

return ability
