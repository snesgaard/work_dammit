local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local mech = require "game/mechanics"

local ARMOR = 2
local DAMAGE = 1

local ability = {}

ability.unlock = {"alchemist.strongacid", "alchemist.base"}

function ability.name()
    return "Acid"
end

function ability.help_text()
    return string.format("Deal %i damage and remove %i ARMOR", DAMAGE, ARMOR)
end

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.run(handle, caster, target)
    local cast_hb, sa = common.cast(handle, caster)

    local potion_node = nodes.sfx:child(
        projectile.sprite, cast_hb:center(), "potion_green/idle",
        "potion_green/break"
    )

    local travel_time = 0.7

    local stop_pos = nodes.position:get_world(target) - vec2(0, 100)

    handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))
    potion_node.sprite:set_animation("impact")
    nodes.game:damage(caster, target, DAMAGE)
    map_stat(
        "armor", target, mech.add_stat(-ARMOR)
    )
    handle:wait(0.5)
    sa:set_animation("idle")
end

return ability
