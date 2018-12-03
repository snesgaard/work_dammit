local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"

local HEAL = 3
local ARMOR = 2
local POWER = 1

local potion = {}


function potion.name()
    return "Storm of Ale"
end

function potion.help_text(user)
    return string.format(
        "Restore %i health, grant %i ARMOR and %i POWER to three random allies",
        HEAL, ARMOR, POWER
    )
end

potion.target = {
    type = "multiple",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function potion.run(handle, caster, targets)

    local on_throw = event()
    local on_finish = event()

    local function potion_life(handle, i, target)
        local cast_hb, sa = common.cast(handle, caster)
        on_throw()

        local potion_node = nodes.sfx:child(
            projectile.sprite, cast_hb:center(), "potion_red/idle",
            "potion_red/break"
        )

        local travel_time = 0.7

        local stop_pos = nodes.position:get_world(target) - vec2(0, 100)
        handle:wait(projectile.ballistic(potion_node, -200, travel_time, stop_pos))

        potion_node.sprite:set_animation("impact")
        nodes.game:heal(caster, target, HEAL)
        map_stat("armor", target, mechanics.add_stat(ARMOR))
        map_stat("power", target, mechanics.add_stat(POWER))
        local s = nodes.sfx:child(sparkle):set_pos(stop_pos)
        on_finish(i)
    end

    for i = 1, 3 do
        handle:fork(potion_life, i, targets:random())
        handle:wait(on_throw)
        handle:wait(0.1)
    end

    local sa = visual.sprite[caster]
    sa:set_animation("idle")

    while 3 ~= handle:wait(on_finish) do end

end


return potion
