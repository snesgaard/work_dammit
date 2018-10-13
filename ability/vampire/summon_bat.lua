local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"
local minion = require "minion"

local DRAIN = 5

local ability = {}

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Summon: Vampire Bat Swarm"
end

function ability.help_text()
    return string.format(
        "MINION: Drain %i health from a foe at the end of each action",
        DRAIN
    )
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)

    nodes.minion:set(target, minion("box"), DRAIN, caster)
    handle:wait(0.4)

    sa:set_animation("idle")
end

return ability
