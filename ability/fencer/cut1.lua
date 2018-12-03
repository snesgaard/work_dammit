local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 2
local POWER = 2

local ability = {}

function ability.name()
    return "Cut1"
end

ability.unlock = {"fencer.cut2", "fencer.strike2", "fencer.pierce2"}

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.help_text(user)
    return string.format(
        "Deal %i damage. You gain %i power.", DAMAGE, POWER
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        add_stat("power", attacker, POWER)
    end
    melee_attack(handle, attacker, target, on_strike)
end

return ability
