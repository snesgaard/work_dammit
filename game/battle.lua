local VerticalMenu = require "ui/vertical_menu"
local FSM = require "fsm"
local Event = require "event"
local Animation = require "animation/server"
local Moonshine = require "modules/moonshine"
local Node = require "game/node"
local PickAction = require "game/pickaction"

local Battle = {}
Battle.__index = Battle

setmetatable(Battle, {__index = FSM})

Battle.STATES = {
    battle_begin   = {},
    round_begin    = {},
    pick_action    = {},
    execute_action = {},
    round_end      = {},
    battle_end     = {},
}

function Battle.create(gamestate, visualstate)
    local this = {
        visualstate = visualstate,
        actions = List.create(),
        graph = Graph.create():progress(Node.init(gamestate))
    }
    return setmetatable(this, Battle)
end

function Battle.STATES.battle_begin:begin()
    return self:set_state("round_begin")
end

function Battle.STATES.round_begin:begin()
    --self.actor_order = self.graph:present():read():get("place/")
    --    :keys()
    --    :shuffle()
    self.graph:progress(
        self.graph:present():node(Mechanics.NewTurn):node(Mechanics.TurnOrder)
    )
    self.graph:present():read()
    log.info("Action order %s", tostring(self.graph:present():read():get("turn/order")))
    return self:set_state("pick_action")
end

function Battle.STATES.pick_action:begin()
    local state = self.graph:present():read()
    local actions = state:get("turn/actions")
    local order = state:get("turn/order")

    if actions:size() == order:size() then
        return self:set_state("execute_action")
    end

    local function callback(action, target)
        local actor =  order[actions:size() + 1]
        log.info("Adding action %s -> %s for actor %s", action, target, actor)
        print(self.visualstate.sprite[actor]:set_animation("chant"))
        --self.actions = self.actions:insert({action, target})
        self.graph:progress(
            self.graph:present()
                :node(Mechanics.AddAction, action, List.create(target))
        )
        self:set_state("pick_action")
    end

    local actor = order[actions:size() + 1]
    self.__workspace.pick_action = PickAction.create(
        self.graph:present():read(), self.visualstate, actor
    ):set_state("base_menu")
    self.__workspace.listener = self.__workspace.pick_action.on_select:listen(callback)
end

function Battle.STATES.pick_action:update(dt)
    self.__workspace.pick_action:update(dt)
end

function Battle.STATES.pick_action:keypressed(...)
    self.__workspace.pick_action:keypressed(...)
end

function Battle.STATES.pick_action:keyreleased(...)
    self.__workspace.pick_action:keyreleased(...)
end

function Battle.STATES.pick_action:draw()
    self.__workspace.pick_action:draw()
end

function Battle.STATES.pick_action:exit()
    if self.__workspace.listener then self.__workspace.listener:remove() end
end

function Battle.STATES.execute_action:begin()
    local state = self.graph:present():read()
    local action = state:get("turn/actions"):tail()
    local targets = state:get("turn/targets"):tail()
    local actor  = state:get("turn/order"):tail()
    if not actor then return self:set_state("round_begin") end

    self.__group = self.__group or {}
    local drain = require "ability/drain"
    local attack = require "ability/phys_attack"
    action = action == "Attack" and attack or drain
    local init_graph = self.graph:present()
    local end_graph = action.map(init_graph, actor, targets:head())

    local function finish_callback()
        self.graph:progress(end_graph:node(Mechanics.ActionExecuted))
        return self:set_state("execute_action")
    end
    local anime = Animation.animate(action, self.__group)
    self.__workspace.listener = {
        on_terminate = anime.on_terminate:listen(finish_callback):take(1)
    }
    return anime:run(self.visualstate, self.graph, end_graph)
end

function Battle.STATES.execute_action:update(dt)
    Animation.update(dt, self.__group)
end

function Battle.STATES.execute_action:draw(...)
    Animation.draw(self.__group)
end

return Battle
