local position = require "game/position"
local server = require "animation/server"
local planner = {
    action = require "game/action_planner",
    battle = require "game/battle_planner"
}
local state = require "game/state"
local ui = require "ui"

local setup = {}

function setup.init_battle()
    nodes.position = process.create(position)
    nodes.animation = process.create(server)
    nodes.round_planner = process.create(planner.round)
    nodes.battle_planner = process.create(planner.battle)

    nodes.game = process.create(state)
    nodes.damage_number = process.create(ui.damage_number)
    nodes.sfx = process.create()

    visual = {
        sprite = {},
        ui = {},
        atlas = {},
    }
end

setup.actor = {}

function setup.actor.state(position, type)
    if not type then return end
    local id = id_gen.register(type)
    type.init_state(nodes.game.actor, id)
    nodes.position:set(id, position)
    return id
end

function setup.actor.visual(id, type)
    type.init_visual(visual, id)
    visual.ui[id] = process.create(ui.stat_bar, id)
end

return setup
