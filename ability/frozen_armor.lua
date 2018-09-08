local target = require "ability/target"
local common = require "animation/common"
local mech = require "game/mechanics"

local ARMOR = 8
local MIN_ARMOR = 2

local ability = {}

function ability.name()
    return "Frozen Armor"
end

function ability.help_text()
    return string.format(
        "Gain %i ARMOR.\n\nIf your ARMOR is %i or less, gain SHIELD.",
        ARMOR, MIN_ARMOR
    )
end

ability.target = {
    type = "self",
    primary = target.same_side,
}

function ability.run(handle, caster)
    local cast_hb, sa = common.cast(handle, caster)
    local a = get_stat("armor", caster)
    map_stat("armor", caster, mech.add_stat(ARMOR))
    if a <= MIN_ARMOR then
        set_stat("shield", caster, 1)
    end
    handle:wait(0.5)
    sa:set_animation("idle")
end

return ability
