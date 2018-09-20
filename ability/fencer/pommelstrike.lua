local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 3
local ARMOR = 2

local ability = {}

ability.unlock = {
    "fencer.reckless", "fencer.evadeslash"
}

function ability.name()
    return "Pommelstrike"
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
        "Deal %i damage and remove %i ARMOR", DAMAGE, ARMOR
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        map_stat("armor", target, mechanics.add_stat(-ARMOR))
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
