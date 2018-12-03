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

    local function on_strike()
        local power = get_stat("power", caster)
        local dmg = power * DAMAGE
        set_stat("power", caster, 0)
        nodes.game:damage(caster, target, dmg)
    end

    nodes.post_process:child(flash)

    local dirt = nodes.sfx:child(sfx("impact_dust"))
    dirt.__transform.pos = nodes.position:get_world(target)
    local bolt = nodes.sfx:child(
        sfx("thunderbolt"),
        {start=vec2(0, -700), thicc=45, blur=6}
    )
    bolt.__transform.pos = nodes.position:get_world(target)

    on_strike()
    handle:wait(0.4)
    sa:set_animation("idle")
end

return ability
