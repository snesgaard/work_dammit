local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local mech = require "game/mechanics"

local ARMOR = 4
local DAMAGE = 5

local ability = {}

function ability.name()
    return "Base"
end

function ability.help_text()
    return string.format("Deal %i true damage and give %i ARMOR", DAMAGE, ARMOR)
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
        projectile.sprite, cast_hb:center(), "potion_blue/idle",
        "potion_blue/break"
    )

    local travel_time = 0.7

    local stop_pos = nodes.position:get_world(target) - vec2(0, 100)

    handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))
    potion_node.sprite:set_animation("impact")
    nodes.game:true_damage(caster, target, DAMAGE)
    map_stat(
        "armor", target, mech.add_stat(ARMOR)
    )
    handle:wait(0.5)
    sa:set_animation("idle")
end

return ability
