local actor = require "actor"
local ability = require "ability"

local battle = {}

function battle:create()
    local party = list(actor('fencer'))
    local foes = list(actor('explody_boi'))
    --local foes = list(actor.healbox)
    local party_id, foe_id = game.setup.actor.full(party, foes)

    local id = party_id:head()

    set_stat("armor", id, 0)
    set_stat("power", id, 0)
    set_stat("ability", id, list(ability("attack"), ability("acid")))
    --set_stat("", id, 0)
end

return battle
