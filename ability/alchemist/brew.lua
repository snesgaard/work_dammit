local target = require "ability/target"
local ease = require "ease"
local Sprite = require "animation/sprite"
local projectile = require "animation/projectile"
local common = require "animation/common"
local sparkle = require "sfx/sparkle"

local HEAL = 3

local potion = {}

function potion.name()
    return "Brew: Ale"
end

potion.unlock = {"alchemist.ale", "alchemist.brew_alestorm"}

function potion.help_text(user)
    return string.format(
        "Restore %i health to self", HEAL, ARMOR, POWER
    )
end

potion.target = {
    type = "self",
}

function potion.run(handle, caster, target)
    local cast_hb, sa = common.cast(handle, caster)

    nodes.game:heal(caster, target, HEAL)
    local stop_pos = nodes.position:get_world(target) - vec2(0, 100)
    local s = nodes.sfx:child(sparkle):set_pos(stop_pos)

    handle:wait(0.4)
    sa:set_animation("idle")
end


return potion
