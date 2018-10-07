local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 5
local HEAL = 5

local attack = {}

function attack.name()
    return "Drain"
end

attack.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function attack.help_text(user)
    return string.format("Deal %i damage and restore %i health", DAMAGE, HEAL)
end

function attack.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        nodes.game:true_heal(attacker, attacker, HEAL)
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return attack
