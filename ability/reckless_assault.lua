local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"

local ARMOR = 5
local POWER = 5

local ability = {}

ability.target = {
    type = "self"
}

function ability.name()
    return "Reckless Assault"
end

function ability.help_text()
    return string.format(
        "Gain %i POWER, lose %i ARMOR",
        POWER, ARMOR
    )
end

function ability.run(handle, caster)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, caster)
    handle:wait(sfx.on_finish)
    sfx:destroy()
    map_stat("armor", caster, mech.add_stat(-ARMOR))
    map_stat("power", caster, mech.add_stat(POWER))
    sa:set_animation("idle")
end

return ability
