local ability = {}

local target = require "ability/target"
local common = require "animation/common"

local DAMAGE = 15

function ability.name()
    return "Explode"
end

ability.target = {
    type = "all"
}

function ability.run(handle, caster, targets)
    local _, sa = common.cast(handle, caster)

    for _, id in pairs(targets) do
        nodes.game:damage(caster, id, DAMAGE)
    end
    handle:wait(0.5)
    sa:set_animation("idle")
end

return ability
