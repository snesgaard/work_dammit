local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local mech = require "game/mechanics"


local ability = {}

function ability.name()
    return "Red Shifter"
end

function ability.help_text()
    return string.format("Cycle STATs to the right")
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
        projectile.sprite, cast_hb:center(), "potion_red/idle",
        "potion_red/break"
    )

    local travel_time = 0.7

    local stop_pos = nodes.position:get_world(target) - vec2(0, 100)

    handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))
    potion_node.sprite:set_animation("impact")

    local power = get_stat("power", target)
    local armor = get_stat("armor", target)
    local agility = get_stat("agility", target)

    set_stat("power", target, agility)
    set_stat("armor", target, power)
    set_stat("agility", target, armor)

    handle:wait(0.5)
    sa:set_animation("idle")
end

return ability
