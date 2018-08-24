local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local mech = require "game/mechanics"

local ARMOR = 3
local DAMAGE = 1

local acid = {}

function acid.name()
    return "Corrosive Acid"
end

function acid.help_text()
    return string.format("Deal %i damage and remove %i ARMOR", DAMAGE, ARMOR)
end

acid.target = {
    type = target.single,
    candidates = function(placement, user)
        return placement
            :filter(target.opposite_side(user))
            :filter(target.is_alive())
    end
}

function acid.run(handle, caster, target)
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
        "armor", target, mech.map_stat(function(v) return v - ARMOR end)
    )
    handle:wait(0.5)
    sa:set_animation("idle")
end

return acid
