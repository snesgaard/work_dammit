local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"

local HEAL = 3

local potion = {}

function potion.name()
    return "Mass Potion"
end

function potion.help_text(user)
    return string.format("Restore %i health to a side", HEAL)
end

potion.target = {
    type = "multiple",
    primary = target.same_side,
    candidates = function(index, id, user)
        return target.is_alive(id)
    end
}

function potion.run(handle, caster, targets)
    local cast_hb, sa = common.cast(handle, caster)

    local on_finish = event()

    local function potion_life(handle, target)
        local potion_node = nodes.sfx:child(
            projectile.sprite, cast_hb:center(), "potion_red/idle",
            "potion_red/break"
        )

        local travel_time = 0.8 - rng() * 0.2

        local stop_pos = nodes.position:get_world(target) - vec2(0, 100)
        handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))

        potion_node.sprite:set_animation("impact")
        nodes.game:heal(caster, target, HEAL)
        local s = nodes.sfx:child(sparkle):set_pos(stop_pos)
        on_finish()
    end

    for _, id in pairs(targets) do
        handle:fork(potion_life, id)
    end

    for _, _ in pairs(targets) do
        handle:wait(on_finish)
    end
    sa:set_animation("idle")

end


return potion
