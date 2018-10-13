local action_planner = require "game/action_planner"
local ui = require "ui"

local round_planner = {}
round_planner.__index = round_planner

function round_planner:__tostring()
    return "Round Planner"
end

function round_planner.create(self)
    self.on_round_end = Event.create()
    self.on_round_begin = Event.create()
    self.on_turn_begin = Event.create()
    self.on_turn_end = Event.create()
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

        local function target_cache_id(action, id)
            return action.name() .. id
        end

        local function get_target_cache(action, id)
            return get_stat("target_memory", target_cache_id(action, id))
        end

        local function set_target_cache(action, id, target)
            return set_stat(
                "target_memory", target_cache_id(action, id), target
            )
        end

        self.action_planner = process.create(
            action_planner, get_target_cache, set_target_cache
        )
            :set_state(
                action_planner.selection, id, get_stat("menu_memory", id)
            )

        local action, target, action_index = self:wait(
            self.action_planner.on_select
        )
        self.action_planner:destroy()
        self.action_planner = nil

        set_stat("menu_memory", id, action_index)

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

    actors = actors:filter(function(id)
        return nodes.game:is_alive(id)
    end)

    for _, id in ipairs(actors:reverse()) do
        local name = nodes.game:get_stat("name", id) or "Ehh"
        local icon = visual.icon[id] or gfx.newImage("art/armor.png")
        nodes.turn:add(icon, name)
        nodes.turn:set_selected(#actors)
    end

    self.on_round_begin(actors)

    for i, id in ipairs(actors) do
        self.active_actor = id
        local action, target = get_action(id)

        self.on_turn_begin(i, id)
        if action then
            -- TODO Consider just removing the specific action
            local name = action.name and action.name() or "Foobar"
            --self.announcer = self:child(ui.textbox)
            --    :set_width(500, 500)
            --    :set_text(name)
            --    :set_font(ui.font(20))
            nodes.announcer:push(name)

            local function __do_run(handle, id, ...)
                set_stat("unlocked", id, list())
                nodes.sprite_server:priority(id)
                action.run(handle, id, ...)
                local ability = require "ability"
                local u = list(unpack(action.unlock or {}))
                    :map(function(p)
                        print(p, ability(p).name())
                        return ability(p)
                    end)
                nodes.sprite_server:priority()
                set_stat("unlocked", id, u)
            end

            nodes.animation:add(__do_run, id, target)
            --self.announcer:destroy()
            self.announcer = nil
        end
        self.on_turn_end(i, id)

        nodes.turn:pop()
        nodes.turn:set_selected(#actors - i)
        self.active_actor = nil
        self:wait(nodes.animation:for_finish())
    end

    self.plan = nil
    self.on_round_end(self:battle_active())
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
    if self.active_actor then
        local id = self.active_actor
        local anchor = nodes.position:get_world(id)
        anchor = spatial(anchor.x, anchor.y, 0, 0)

        local shape = spatial(0, 0, 100, 10)
            :yalign(anchor, "center", "center")
            :xalign(anchor, "center", "center")
            :move(0, 20)

        gfx.setColor(1.0, 1.0, 0.1, 0.4)
        gfx.rectangle("fill", shape:unpack())
    end
    if self.action_planner then
        self.action_planner:draw()
    end
    if self.announcer then
        local base = spatial(gfx.getWidth() / 2, 50, 0, 0)
        local s = self.announcer:get_spatial()
            :xalign(base, "center", "center")
            :yalign(base, "top", "top")
        self.announcer:draw(s:pos())
    end
end


return round_planner
