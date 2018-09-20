local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 2
local AGILITY = 3

local ability = {}

ability.unlock = {
    "fencer.parry", "fencer.embolden"
}

function ability.name()
    return "Hamstring"
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
        "Deal %i damage and remove %i AGILITY", DAMAGE, AGILITY
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        map_stat("agility", target, mechanics.add_stat(-AGILITY))
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
