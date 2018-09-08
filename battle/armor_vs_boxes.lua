local actor = require "actor"
local ability = require "ability"
local target = require "ability/target"

local battle = {}

local function ai(id)
    if get_stat("health/current", id) == get_stat("health/max", id) then
        local a = ability("attack")
        local targets = target.candidates(a.target, id)
        return a, targets.primary:random()
    else
        return ability("heal"), id
    end
end

function battle:create()
    local party = list(actor('fencer'))
    local foes = list(actor('box'), actor('box'))

    local party_id, foe_id = game.setup.actor.full(party, foes)

    for _, id in pairs(foe_id) do
        set_stat("power", id, 2)
        set_stat("armor", id, 2)
        set_stat("script", id, ai)
    end

    local id = party_id:head()

    set_stat("armor", id, 0)
    set_stat("power", id, 4)
    set_stat(
        "ability", id,
        list(
            ability("attack"),
            ability("stoneskin_oil"),
            ability("acid")
        )
    )
    --set_stat("", id, 0)
end

return battle
