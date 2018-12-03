local actor = require "actor"
local ability = require "ability"
local target = require "ability/target"
local minion = require "minion"

local battle = {}

function battle:create()
    local party = list(
        actor('fencer'), actor('alchemist'), actor("vampire")
    )
    local foes = list(actor('golem'))

    local party_id, foe_id = game.setup.actor.full(party, foes)

    set_stat("power", foe_id:head(), 6)
    set_stat("armor", foe_id:head(), 2)

    local id = party_id[2]
    set_stat(
        "ability", id,
        list(
            ability("alchemist.acid"),
            ability("alchemist.brew"),
            ability("alchemist.unstable_bomb"),
            ability("potion")
        )
    )

    local id = party_id[1]
    set_stat(
        "ability", id,
        list(
            ability("fencer.cut1"),
            ability("fencer.strike1"),
            ability("fencer.pierce1"),
            ability("fencer.evasive_maneuver")
        )
    )

    local id = party_id[3]
    set_stat(
        "ability", id,
        list(
            ability("vampire.drain"),
            ability("vampire.bloodstrike"),
            ability("vampire.bloodlust"),
            ability("vampire.chant_summon")
        )
    )
end

return battle
