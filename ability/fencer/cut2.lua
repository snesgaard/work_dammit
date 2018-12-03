local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 2
local POWER = 1

local ability = {}

function ability.name()
    return "Cut2"
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
        "Deal 2x%i damage. You gain %i power.", DAMAGE, POWER
    )
end

function ability.run(handle, attacker, target)
    local function on_strike1()
        nodes.game:damage(attacker, target, DAMAGE)
    end
    local function on_strike2()
        nodes.game:damage(attacker, target, DAMAGE)
        add_stat("power", attacker, POWER)
    end
    melee_attack(handle, attacker, target, on_strike1, true)
    melee_attack(handle, attacker, target, on_strike2)
end

return ability
