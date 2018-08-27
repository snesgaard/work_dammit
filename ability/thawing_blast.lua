local target = require "ability/target"
local mech = require "game/mechanics"
local blast_sfx = require "sfx/blast"
local common = require "animation/common"

local DAMAGE = 4

local blast = {}

blast.target = {
    type = "multiple",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function blast.name()
    return "Thawing Blast"
end

function blast.help_text()
    return string.format(
        "All foes takes %i damage and loses all ARMOR",
        DAMAGE
    )
end

function blast.run(handle, caster, targets)
    local cast_hb, sa = common.cast(handle, caster)

    local pos = targets
        :map(function(id)
            return nodes.position:get_world(id)
        end)
        :reduce(function(v1, v2) return v1 + v2 end) / #targets

    local sfx = nodes.sfx:child(blast_sfx)
    sfx.__transform.pos = pos

    handle:wait(sfx.on_blast)
    for _, id in ipairs(targets) do
        nodes.game:damage(caster, id, 5)
        set_stat("armor", id, 0)
    end
    sa:set_animation("idle")
end

return blast
