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
    return "Shield"
end

function ability.help_text()
    return string.format(
        "Void next incoming attack"
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target, "blue")
    handle:wait(sfx.on_finish)
    sfx:destroy()
    set_stat("shield", target, 1)
    sa:set_animation("idle")
end

return ability
