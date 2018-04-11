local Spatial = require "spatial"
local Mechanics = require "game/mechanics"

local Drain = {}

function Drain.animate(convoke, context, visualstate, main_graph, sub_graph)
    local attack_node, heal_node = sub_graph:find("attack"), sub_graph:find("heal")
    local src, dst = attack_node:info().src, attack_node:info().dst
    local dmg_pos = visualstate.spatial[dst]:move(0, -75)
    local heal_pos = visualstate.spatial[src]:move(0, -75)

    context.sphere = {x = dmg_pos.x, y = dmg_pos.y, r = 0, a = 0}
    convoke:wait(
        convoke:tween(0.25, {[context.sphere] = {r = 15, a = 150}})
    )
    main_graph:progress(attack_node)
    convoke:wait(0.1)
    convoke:wait(
        convoke:tween(
            0.25, {[context.sphere] = {x = heal_pos.x, y = heal_pos.y}}
        )
    )
    main_graph:progress(heal_node)
    convoke:wait(
        convoke:tween(
            0.25, {[context.sphere] = {r = 100, a = 0}}
        )
    )
end

function Drain.draw(context)
    gfx.setColor(100, 10, 100, context.sphere.a)
    gfx.circle("fill", context.sphere.x, context.sphere.y, context.sphere.r)
end

function Drain.map(state_graph, src, dst)
    local function get_damage(node)
        return node:find("attack"):info().damage
    end
    return state_graph
        :node(Mechanics.Attack, src, dst, 5):tag("attack")
        :node(Mechanics.Heal, src, src, get_damage):tag("heal")
end

return Drain
