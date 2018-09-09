local mech = require "game/mechanics"
local common = require "animation/common"
local charge_sfx = require "sfx/charge_cast"
local target = require "ability/target"

local ability = {}

ability.target = {
    type = "multiple",
    primary = target.same_side,
    condition = function(index, id, user)
        return target.is_alive(id)
    end
}

function ability.name()
    return "Mass Shield"
end

function ability.help_text()
    return string.format(
        "Void next incoming attack for an entire side"
    )
end

function ability.run(handle, caster, targets)
    local hb, sa = common.cast(handle, caster)

    local on_done = event()

    local function life(handle, target)
        local sfx = nodes.sfx:child(charge_sfx, target, "blue")
        handle:wait(sfx.on_finish)
        sfx:destroy()
        set_stat("shield", target, 1)
        on_done()
    end

    for _, t in pairs(targets) do
        handle:fork(life, t)
    end

    for _, t in pairs(targets) do
        handle:wait(on_done)
    end

    sa:set_animation("idle")
end

return ability
