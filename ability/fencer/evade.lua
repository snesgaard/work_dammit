local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

ability.unlock = {"fencer.taunt"}

ability.target = {
    type = "self",
}

function ability.name()
    return "Evade"
end

function ability.help_text()
    return string.format(
        "Gain SHIELD"
    )
end

function ability.run(handle, caster)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, caster, "blue")
    handle:wait(sfx.on_finish)
    sfx:destroy()
    set_stat("shield", caster, 1)
    sa:set_animation("idle")
end

return ability
