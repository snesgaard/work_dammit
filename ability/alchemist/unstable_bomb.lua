local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"
local minion = require "minion"

local ability = {}

local DAMAGE = 15

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Summon: Unstable Bomb"
end

function ability.help_text()
    return string.format(
        "MINION: At the end of third round, explodes and deals %i damage to all foes",
        DAMAGE
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)

    nodes.minion:set(target, minion("alch_bomb"))
    handle:wait(0.4)

    sa:set_animation("idle")
end

return ability
