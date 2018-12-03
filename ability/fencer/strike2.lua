local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 2
local GAIN_ARMOR = 2
local LOSE_ARMOR = 2

local ability = {}

function ability.name()
    return "Strike2"
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
        "Deal %i damage and remove %i armor. You gain %i armor.", DAMAGE,
        GAIN_ARMOR, LOSE_ARMOR
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        add_stat("armor", target, -LOSE_ARMOR)
        add_stat("armor", attacker, GAIN_ARMOR)
    end
    melee_attack(handle, attacker, target, on_strike)
end

return ability
