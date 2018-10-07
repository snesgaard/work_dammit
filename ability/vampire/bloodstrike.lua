local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 5
local SELF_DAMAGE = 5

local ability = {}

function ability.name()
    return "Crimson Strike"
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
        "Take %i damange and deal %i damage twice ", DAMAGE, SELF_DAMAGE
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
    end
    melee_attack(handle, attacker, target, on_strike, true)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        nodes.game:true_damage(attacker, attacker, SELF_DAMAGE)
    end
    melee_attack(handle, attacker, target, on_strike)
end

return ability
