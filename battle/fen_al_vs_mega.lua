local actor = require "actor"
local ability = require "ability"
local target = require "ability/target"

local battle = {}

function battle:create()
    local party = list(actor('fencer'), actor('alchemist'))
    local foes = list(actor('megabox'))

    local party_id, foe_id = game.setup.actor.full(party, foes)

    set_stat("power", foe_id:head(), 6)
    set_stat("armor", foe_id:head(), 2)

    local id = party_id:tail()
    set_stat(
        "ability", id,
        list(
            ability("attack"),
            ability("potion"),
            ability("acid"),
            ability("mix/base")
        )
    )

    local id = party_id:head()
    set_stat(
        "ability", id,
        list(
            ability("fencer.cut"),
            ability("fencer.hamstring"),
            ability("fencer.evade"),
            ability("fencer.embolden"),
            ability("potion")
        )
    )
end

return battle
