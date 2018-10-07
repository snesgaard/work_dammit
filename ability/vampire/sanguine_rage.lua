local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local ability = {}

function ability.name()
    return "Sanguine Rage"
end

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

ability.unlock = {
    "vampire.rejuvenating_vitae", "vampire.sanguine_rage"
}

function ability.help_text(user)
    return string.format(
        "Deal missing health as damage"
    )
end

function ability.run(handle, attacker, target)
    local function on_strike()
        local dmg = get_stat("health/max", attacker)
        dmg = dmg - get_stat("health/current", attacker)
        nodes.game:damage(attacker, target, dmg)
    end
    melee_attack(handle, attacker, target, on_strike)
end

return ability
