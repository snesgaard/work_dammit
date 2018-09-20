local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 4
local AGILITY = 2

local ability = {}

ability.unlock = list()

function ability.name()
    return "Evade Slash"
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
        "Deal %i damage, gain %i AGILITY and SHIELD", DAMAGE, AGILITY
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        map_stat("agility", attacker, mechanics.add_stat(AGILITY))
        set_stat("shield", attacker, 1)
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
