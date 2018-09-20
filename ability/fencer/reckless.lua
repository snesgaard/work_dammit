local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 12
local SELF_DMG = 3

local ability = {}

ability.unlock = list()

function ability.name()
    return "Reckless Assault"
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
        "Deal %i damage and lose %i HP", DAMAGE, SELF_DMG
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
        nodes.game:true_damage(attacker, attacker, SELF_DMG)
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
