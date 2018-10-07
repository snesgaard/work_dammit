local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"

local HEAL = 10

local ability = {}

function ability.name()
    return "Rejuvenating Vitae"
end

function ability.help_text(user)
    return string.format("Restore %i health to a side", HEAL)
end

ability.target = {
    type = "multiple",
    primary = target.same_side,
    candidates = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.run(handle, caster, targets)
    local cast_hb, sa = common.cast(handle, caster)

    for _, target in pairs(targets) do
        local pos = nodes.position:get_world(target)
        nodes.game:heal(caster, target, HEAL)
        local s = nodes.sfx:child(sparkle):set_pos(pos - vec2(0, 125))
    end

    handle:wait(0.4)
    sa:set_animation("idle")
end


return ability
