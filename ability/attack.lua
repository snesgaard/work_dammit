local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"

local DAMAGE = 2

local attack = {}

function attack.name()
    return "Attack"
end

attack.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function attack.help_text(user)
    return string.format("Deal %i damage.", DAMAGE)
end

function attack.run(handle, attacker, target)
    local function on_strike()
        nodes.game:damage(attacker, target, DAMAGE)
    end
    return melee_attack(handle, attacker, target, on_strike)
end

return attack
