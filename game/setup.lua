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
    visual = {
        sprite = {},
        ui = {},
        atlas = {},
        icon = {},
    }

    nodes.position = process.create(position)
    nodes.animation = process.create(server)
    nodes.round_planner = process.create(planner.round)
    nodes.battle_planner = process.create(planner.battle)

    nodes.game = process.create(state)

    -- Create shortcuts
    function get_atlas(path)
        if not visual.atlas[path] then
            visual.atlas[path] = Atlas.create(path)
        end
        return visual.atlas[path]
    end

    function get_stat(...)
        return nodes.game:get_stat(...) or 0
    end

    function set_stat(...)
        return nodes.game:set_stat(...)
    end

    function map_stat(...)
        nodes.game:map_stat(...)
    end

    function monitor_stat(...)
        return nodes.game:monitor_stat(...)
    end

    nodes.damage_number = process.create(ui.damage_number)
    nodes.char_monitor = process.create(ui.char_monitor)
    nodes.sfx = process.create()
    nodes.elem_monitor = process.create(require "element/visual")

    nodes.charge = process.create(sfx.manager.charge)
    nodes.turn = process.create(ui.turn_row)

    nodes.game.event.on_damage:listen(function(info)
        if not info.miss and not info.shield and info.damage > 0 then
            visual.sprite[info.defender]:shake(info.crit or info.charge)
        end
    end)

    --set_stat("ground/type", -1, "burn")
end

setup.actor = {}

function setup.actor.state(position, type)
    if not type then return end
    local id = id_gen.register(type)
    type.init_state(nodes.game.actor, id)
    nodes.position:set(id, position)
    if get_stat("health/current", id) == 0 then
        set_stat(
            "health/current", id, get_stat("health/max", id)
        )
    end
    return id
end

function setup.actor.visual(id, type)
    type.init_visual(visual, id)
    visual.ui[id] = process.create(ui.char_bar, id)

    local p = nodes.position:get(id)
    local s = visual.sprite[id]
    if p < 0 and s then
        s:set_mirror()
    end
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
