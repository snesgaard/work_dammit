local actor = require "actor"

local battle = {}

function battle:create()
    local party = list(actor.fencer, actor.alchemist)
    local foes = list(actor.box, actor.box, actor.healbox)
    --local foes = list(actor.healbox)
    local party_id, foe_id = game.setup.actor.full(party, foes)
end

return battle
