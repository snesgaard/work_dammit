local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 5
local BONUS_DAMAGE = 0
local MIN_ARMOR = -2

local ability = {}

function ability.name()
    return "Frozen Reap"
end

function ability.help_text()
    return string.format(
        "Deal %i damage.\n\nIf target has %i or less ARMOR add %i damage.",
        DAMAGE, MIN_ARMOR, BONUS_DAMAGE
    )
end

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.run(handle, attacker, target)
    local function on_strike()
        local dmg = DAMAGE
        local a = get_stat("armor", target) or 0
        if a <= MIN_ARMOR then
            dmg = dmg + BONUS_DAMAGE
        end
        nodes.game:damage(attacker, target, dmg)
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return ability
