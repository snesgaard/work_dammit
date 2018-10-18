local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"
local minion = require "minion"

local ability = {}

local DAMAGE = 15

ability.target = {
    type = "single",
    primary = target.opposite_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Summon: Unstable Bomb"
end

function ability.help_text()
    return string.format(
        "MINION: At the end of third round, explodes and deals %i damage to all foes",
        DAMAGE
    )
end

local function apply_explosion_damage(handle, caster, target)
    local index = nodes.position:get(target)

    local all = nodes.position.placements
        :filter(function(i, id)
            return i * index > 0
        end)
        :values()

    print(all)
    for _, id in pairs(all) do
        print(id)
        nodes.game:damage(caster, id, DAMAGE)
    end
end

function ability.run(handle, caster, target)
    local hb, sa = common.cast(handle, caster)

    local function cb(handle, target)
        apply_explosion_damage(handle, caster, target)
    end

    nodes.minion:set(target, minion("alch_bomb"), cb)
    handle:wait(0.4)

    sa:set_animation("idle")
end

return ability
