local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"
local sfx = require "sfx/thunder"

local DAMAGE = 8

local ability = {}

function ability.name()
    return "Thunderstrike"
end

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.help_text(user)
    return string.format(
        "Deal %i true damage", DAMAGE
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:true_damage(attacker, target, DAMAGE)
        nodes.sfx:child(sfx)
            :set_pos(nodes.position:get_world(target))
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
