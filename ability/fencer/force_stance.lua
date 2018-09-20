local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local POWER = 2

local ability = {}

ability.target = {
    type = "self",
}

ability.unlock = {
    "fencer.force_stance", "fencer.triplestrike"
}

function ability.name()
    return "Force Stance"
end

function ability.help_text()
    return string.format("Gain %i POWER", POWER)
end

function ability.run(handle, caster)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, caster, "red")
    handle:wait(sfx.on_finish)
    map_stat("power", caster, mechanics.add_stat(POWER))
    sfx:destroy()
    sa:set_animation("idle")
end

return ability
