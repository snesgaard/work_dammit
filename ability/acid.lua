local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local mech = require "game/mechanics"

local ARMOR = 3

local acid = {}

function acid.name()
    return "Corrosive Acid"
end

function acid.help_text()
    return string.format("Remove %i ARMOR", ARMOR)
end

acid.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
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
    --nodes.game:damage(caster, target, DAMAGE)
    map_stat(
        "armor", target, mech.map_stat(function(v) return v - ARMOR end)
    )
    handle:wait(0.5)
    sa:set_animation("idle")
end

return acid
