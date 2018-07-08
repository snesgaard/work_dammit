local action_planner = require "game/action_planner"

local round_planner = {}
round_planner.__index = round_planner

function round_planner.create(self)
    self.on_round_finish = Event.create()
end

function round_planner.submit(self, actors)
    if self.plan then
        log.warn("Planning already in progress")
        return
    end
    -- First sort actors according to agility
    local __agi_cache = {}
    local rng = love.math.random

    local function agility(id)
        if not __agi_cache[id] then
            __agi_cache[id] = nodes.game.actor.agility[id] + rng()
        end
        return __agi_cache[id]
    end

    actors = actors:sort(function(a, b) return agility(a) > agility(b) end)

    self.plan = self:fork(round_planner.__plan, actors)
end

function round_planner.__plan(self, actors)
    local function handle_player(id)
        self.action_planner = process.create(action_planner)
            :set_state(action_planner.selection, id)

        local action, target = self:wait(self.action_planner.on_select)
        self.action_planner:destroy()
        self.action_planner = nil

        return action, target
    end

    local function handle_ai(id)
        -- Just a precaution for now
        local script = nodes.game.actor.script[id]
        if not script then return end

        if type(script) == "function" then
            return script(id)
        elseif type(script) == "thread" then
            return coroutine.resume(script, id)
        end
    end

    local function get_action(id)
        if not nodes.game:is_alive(id) or not self:battle_active() then
            return
        end
        if nodes.position:get(id) > 0 then
            return handle_player(id)
        else
            return handle_ai(id)
        end
    end

    for _, id in ipairs(actors) do
        local action, target = get_action(id)
        if action then
            nodes.animation:add(action.run, id, target)
            self:wait(nodes.animation.on_done)
        end
    end

    self.plan = nil
    self.on_round_finish(self:battle_active())
end

local function is_alive(faction)
    local s = faction == "party" and 1 or -1
    return nodes.position.placements
        :filter(function(index, id)
            return s * index > 0
        end)
        :values()
        :map(function(id)
            return nodes.game:is_alive(id)
        end)
        :reduce(function(a, b) return a or b end)
end

function round_planner:party_alive()
    return is_alive("party")
end

function round_planner:enemy_alive()
    return is_alive("enemy")
end

function round_planner:battle_active()
    return self:party_alive() and self:enemy_alive()
end

function round_planner:__update(dt)
    if self.action_planner then
        self.action_planner:update(dt)
    end
end

function round_planner:draw()
    if self.action_planner then
        self.action_planner:draw()
    end
end


return round_planner
