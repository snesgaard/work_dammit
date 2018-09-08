local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"
local mech = require "game/mechanics"

local HEAL = 2
local ARMOR = 4

local potion = {}

function potion.name()
    return "Stoneskin Oil"
end

function potion.help_text(user)
    return string.format("Give %i ARMOR.", ARMOR)
end

potion.target = {
    type = "single",
    primary = target.same_side,
    candidates = function(index, id, user)
        return target.is_alive(id)
    end
}

function potion.run(handle, caster, target)
    local cast_hb, sa = common.cast(handle, caster)

    local potion_node = nodes.sfx:child(
        projectile.sprite, cast_hb:center(), "potion_blue/idle",
        "potion_blue/break"
    )

    local travel_time = 0.7

    local stop_pos = nodes.position:get_world(target) - vec2(0, 100)
    handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))

    potion_node.sprite:set_animation("impact")
    --nodes.game:heal(caster, target, HEAL)
    map_stat("armor", target, mech.add_stat(ARMOR))
    local s = nodes.sfx:child(sparkle):set_pos(stop_pos)
    sa:set_animation("idle")
end


return potion
