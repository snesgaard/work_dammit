local position = require "game/position"
local server = require "animation/server"
local planner = {
    action = require "game/action_planner",
    battle = require "game/battle_planner",
    round = require "game/round_planner"
}
local state = require "game/state"
local ui = require "ui"
local sfx = require "sfx"

local setup = {}

function setup.init_battle()
    nodes.position = process.create(position)
    nodes.animation = process.create(server)
    nodes.round_planner = process.create(planner.round)
    nodes.battle_planner = process.create(planner.battle)

    nodes.game = process.create(state)
    nodes.damage_number = process.create(ui.damage_number)
    nodes.sfx = process.create()

    nodes.charge = process.create(sfx.manager.charge)
    nodes.turn = process.create(ui.turn_row)

    visual = {
        sprite = {},
        ui = {},
        atlas = {},
    }

    nodes.game.event.on_damage:listen(function(info)
        if not info.miss and not info.shield and info.damage > 0 then
            visual.sprite[info.defender]:shake(info.crit or info.charge)
        end
    end)
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
    visual.ui[id] = process.create(ui.char_bar, id)
end

function setup.actor.full(party, foes)
    local function init(pos, type)
        local id = setup.actor.state(pos, type)
        setup.actor.visual(id, type)
        if visual.sprite[id] then
            visual.sprite[id]:set_animation("idle")
        end
        return id
    end
    local function foe_init(pos, type)
        return init(-pos, type)
    end
    return party:argmap(init), foes:argmap(foe_init)
end

return setup
