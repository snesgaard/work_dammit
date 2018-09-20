local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

local ARMOR = 4

ability.target = {
    type = "self",
}

function ability.name()
    return "Parry"
end

function ability.help_text()
    return string.format(
        "Gain SHIELD and %i ARMOR", ARMOR
    )
end

function ability.run(handle, caster)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, caster, "blue")
    handle:wait(sfx.on_finish)
    sfx:destroy()
    set_stat("shield", caster, 1)
    map_stat("armor", caster, mechanics.add_stat(ARMOR))
    sa:set_animation("idle")
end

return ability
