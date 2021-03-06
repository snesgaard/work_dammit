local target = require "ability/target"
local ease = require "ease"
local slash = require "sfx/slash"
local melee_attack = require "animation/melee_attack"
local common = require "animation.common"
local sfx = require "sfx"
local flash = require "post_process/flash"

local DAMAGE = 3

local ability = {}

function ability.name()
    return "Devastate"
end

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.help_text(user)
    return string.format(
        "Lose all power. Deal %i damage for each power lost.", DAMAGE
    )
end

function ability.run(handle, caster, target)
    local cast_hb, sa = common.cast(handle, caster)

    local flame = nodes.sfx:child(sfx("flame"))
    flame.__transform.pos = nodes.position:get_world(target)

    for i = 1, 3 do
        nodes.game:damage(caster, target, DAMAGE)
        handle:wait(0.5)
    end
    flame:stop()
    sa:set_animation("idle")
end

return ability
