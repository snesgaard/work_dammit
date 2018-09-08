local actor = require "actor"
local ability = require "ability"
local target = require "ability/target"

local function ai(id)
    local a = ability("thawing_blast")
    local targets = target.candidates(a.target, id)
    return a, targets.primary:random()
end

local battle = {}

function battle:create()
    local party = list(actor('fencer'), actor('alchemist'))
    local foes = list(
        actor('explody_boi'), actor('box'), actor('box'), actor('box')
    )

    local party_id, foe_id = game.setup.actor.full(party, foes)

    set_stat("power", foe_id:head(), 9)
    set_stat("agility", foe_id:head(), 3)

    for _, id in ipairs(foe_id:body(1)) do
        set_stat("script", id, ai)
    end

    local id = party_id:head()
    set_stat(
        "ability", id,
        list(
            ability("attack"),
            ability("shield")
        )
    )

    local id = party_id:tail()
    set_stat(
        "ability", id,
        list(
            ability("attack"),
            ability("shield")
        )
    )
end

return battle
