local target = require "ability/target"
local charge_cast = require "sfx/charge_cast"

local HP_THRESHOLD = 6

local shield = {}

function shield.name()
    return "Shield"
end

function shield.help_text(user)
    return string.format(
        "Give an ally SHIELD.\
        \
        Give CHARGE, if your health is %i or below.",
        HP_THRESHOLD
    )
end

shield.target = {
    type = "single",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}


function shield.run(handle, caster, target)
    local cs = visual.sprite[caster]
    cs:set_animation("chant")
    handle:wait(0.5)
    cs:set_animation("cast")
    local sfx = nodes.sfx:child(charge_cast, target)
    handle:wait(sfx.on_finish)
    nodes.game:set_stat("shield", target, 1)
    if nodes.game:get_stat("health/current", caster) <= HP_THRESHOLD then
        nodes.game:set_stat("charge", target, 1)
    end
    cs:set_animation("idle")
end

return shield
