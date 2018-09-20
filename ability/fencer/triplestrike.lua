local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 1

local ability = {}

ability.unlock = {
}

function ability.name()
    return "Triple Strike"
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
        "Deal %i damage thrice", DAMAGE
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
    end
    melee_attack(handle, attacker, target, on_strike, true)
    melee_attack(handle, attacker, target, on_strike, true)
    melee_attack(handle, attacker, target, on_strike)
end

return ability
