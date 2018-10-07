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
    "vampire.rejuvenating_vitae", "vampire.sanguine_rage"
}

function ability.name()
    return "Bloodlust"
end

function ability.help_text()
    return string.format(
        "You gain shield and charge. Set your health to 1."
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target, "red")
    handle:wait(sfx.on_finish)
    sfx:destroy()
    set_stat("charge", target, 1)
    set_stat("shield", target, 1)
    local hp = get_stat("health/current", target)
    nodes.game:true_damage(caster, target, hp - 1)

    sa:set_animation("idle")
end

return ability
