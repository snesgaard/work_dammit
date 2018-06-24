local Spatial = require "spatial"
local Mechanics = require "game/mechanics"

local Attack = {}

function Attack.animate(context, main_graph, sub_graph)
    local attack_node = sub_graph:find("attack")
    local src, dst = attack_node:info().src, attack_node:info().dst
    print(visualstate.spatial[dst])
end

function Attack.draw(context)

end

function Attack.map(state_graph, src, dst)
    return state_graph
        :node(Mechanics.Attack, src, dst, 5):tag("attack")
end

return Attack
