local actor = require "actor"
local ability = require "ability"

local battle = {}

function battle:create()
    local party = list(actor('fencer'))
    local foes = list(actor('box'), actor('healbox'))

    local party_id, foe_id = game.setup.actor.full(party, foes)

    local id = party_id:head()
    set_stat("armor", id, 0)
    set_stat("power", id, 7)
    set_stat(
        "ability", id,
        list(
            ability("attack"),
            ability("acid")
        )
    )
end

return battle
