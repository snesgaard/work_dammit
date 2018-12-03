local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 5
local AGILITY = 1

local ability = {}

function ability.name()
    return "Pierce2"
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
        "Deal %i true damage. You gain %i agility.", DAMAGE, AGILITY
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:true_damage(attacker, target, DAMAGE)
        add_stat("agility", attacker, AGILITY)
    end
    melee_attack(handle, attacker, target, on_strike)
end

return ability
