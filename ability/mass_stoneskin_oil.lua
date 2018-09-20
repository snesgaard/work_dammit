local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"
local mech = require "game/mechanics"

local ARMOR = 2

local potion = {}

function potion.name()
    return "Mass Stoneskin Oil"
end

function potion.help_text(user)
    return string.format("Give %i ARMOR to a side", ARMOR)
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
            projectile.sprite, cast_hb:center(), "potion_blue/idle",
            "potion_blue/break"
        )

        local travel_time = 0.7

        local stop_pos = nodes.position:get_world(target) - vec2(0, 100)
        handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))

        potion_node.sprite:set_animation("impact")
        map_stat("armor", target, mech.add_stat(ARMOR))
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
