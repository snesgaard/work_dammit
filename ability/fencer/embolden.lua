local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

local POWER = 2
local ARMOR = 2

ability.unlock = {
    "fencer.triplestrike"
}

ability.target = {
    type = "self",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Embolden"
end

function ability.help_text()
    return string.format(
        "You gain %i POWER and lose %i ARMOR", POWER, ARMOR
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)
    local sfx = nodes.sfx:child(charge_sfx, target, "red")
    handle:wait(sfx.on_finish)
    sfx:destroy()
    map_stat("power", target, mechanics.add_stat(POWER))
    map_stat("armor", target, mechanics.add_stat(-ARMOR))
    sa:set_animation("idle")
end

return ability
