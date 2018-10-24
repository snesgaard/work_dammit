local target = require "ability/target"
local action_planner = require "game/action_planner"
local ability = require "ability"

local battle_planner = {}
battle_planner.__index = battle_planner

function battle_planner.create(self)
    self.on_round_begin = event()
    self.on_round_end = event()
    self.on_action_begin = event()
    self.on_action_end = event()

    self.reactions = list()
end

function battle_planner:react(f, ...)
    local args = {...}
    self.reactions[#self.reactions + 1] = function(handle)
        return f(handle, unpack(args))
    end
    return self
end

function battle_planner:test()
    local candidates = dict{
        primary = list("A", "B", "C"),
        secondary = list("D", "E", "F"),
    }
    print(self.valid_target(candidates, "A"))
    local candidates = dict{
        primary = list(list("A", "B", "C")),
        secondary = list(list("D", "E", "F"))
    }
    print(self.valid_target(candidates, list("A", "B", "C")))

    local candidates = dict{
        primary = {"A", "B", "C"},
        secondary = { "E", "F"}
    }

    local indices = {
        [-3] = "D",
        [-2] = "E",
        [-1] = "F",
        [1] = "C",
        [2] = "B",
        [3] = "A",
    }

    for key, value in pairs(indices) do
        indices[value] = key
    end

    local function get_index(k)
        return indices[k]
    end

    print("target", self.resample_target(candidates, "single", "D", get_index))

    local candidates = dict{
        primary = list(list("A", "C")),
        secondary = list(list("E", "F"))
    }

    print("target", self.resample_target(candidates, "multiple", list("A", "B"), get_index))
    print("target", self.resample_target(candidates, "multiple", list("D", "E"), get_index))
end

function battle_planner.begin(self)
    self:fork(self.do_round)
end

function battle_planner:do_round()
    if self:is_finished() then
        return false
    end

    local actors = nodes.position.placements:values()
    actors = self.get_turn_order(actors)

    -- First reverse order
    actors = actors:reverse()

    local all_actions = {}
    local all_targets = {}

    for _, id in pairs(actors) do
        local action, target = self:get_action(id)
        all_actions[id] = action
        all_targets[id] = target
        self:show_selected_action(id, action)
    end

    -- Reverse to get execution order
    actors = actors:reverse()
    for _, id in pairs(actors) do
        local action = all_actions[id]
        local target = all_targets[id]
        self:handle_turn(id, action, target)
        self:handle_reaction()
    end

    self.on_round_end(true)
    self:handle_reaction()
end

function battle_planner:handle_turn(id, action, target)
    if not nodes.game:is_alive(id) then return end
    self.on_action_begin(id, action, target)

    set_stat("unlocked", id, list())
    local name = action.name and action.name(id) or ""
    nodes.announcer:push(name)
    nodes.sprite_server:priority(id)
    action.run(self, id, target)
    local u = list(unpack(action.unlock or {}))
        :map(function(p)
            return ability(p)
        end)
    nodes.sprite_server:priority()
    set_stat("unlocked", id, u)
    nodes.turn:pop()

    self.on_action_end(id, action, target)
end

function battle_planner:handle_reaction()
    while self.reactions:size() > 0 do
        local r = self.reactions:head()
        self.reactions = self.reactions:erase(1)
        r(self)
    end
end

function battle_planner:show_selected_action(id, action)
    local name = nodes.game:get_stat("name", id) or "Ehh"
    local icon = visual.icon[id] or gfx.newImage("art/armor.png")
    nodes.turn:add(icon, action.name(id), name)
end

function battle_planner:get_action(id)
    if nodes.position:get(id) > 0 then
        return self:get_player_action(id)
    else
        return self:get_ai_action(id)
    end
end

function battle_planner:get_player_action(id)
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

function battle_planner:get_ai_action(id)
    -- Just a precaution for now
    local script = nodes.game.actor.script[id]
    if not script then
        log.warn("no script found for <%s>", id)
        return
    end

    if type(script) == "function" then
        return script(id)
    elseif type(script) == "thread" then
        return coroutine.resume(script, id)
    end
end

function battle_planner.get_turn_order(actors)
    local __agi_cache = {}
    local rng = love.math.random

    local function agility(id)
        if not __agi_cache[id] then
            __agi_cache[id] = nodes.game.actor.agility[id] + rng()
        end
        return __agi_cache[id]
    end

    return actors:sort(function(a, b) return agility(a) > agility(b) end)
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

function battle_planner.control(self)
    local actors = nodes.position.placements:values()
    nodes.round_planner:submit(actors)
    local battle_active = self:wait(nodes.round_planner.on_round_end)

    local party_alive = is_alive("party")

    local enemy_alive = is_alive("enemy")

    if battle_active then
        return battle_planner.control(self)
    elseif nodes.round_planner:party_alive() then
        self.victory = "Victory"
    else
        self.victory = "Fail"
    end
end

function battle_planner.get_turn_order(actors)
    -- First sort actors according to agility
    local __agi_cache = {}
    local rng = love.math.random

    local function agility(id)
        if not __agi_cache[id] then
            __agi_cache[id] = nodes.game.actor.agility[id] + rng()
        end
        return __agi_cache[id]
    end

    return actors:sort(function(a, b) return agility(a) > agility(b) end)
end

function battle_planner.round()

end

function battle_planner.select_action(id)

end

function battle_planner.perform_action(actions)
    local next = queue:head()
    local id, action, target = unpack(next)

end

function battle_planner.valid_target(candidates, target)
    local function equal(a, b)
        local ta, tb = type(a), type(b)
        if ta == "table" and tb == "table" then
            for key, val in pairs(a) do
                if val ~= b[key] then return false end
            end
            for key, val in pairs(b) do
                if val ~= a[key] then return false end
            end
            return true
        else
            return a == b
        end
    end

    return candidates
        :values()
        :map(function(v)
            return v
                :map(function(a) return equal(target, a) end)
                :reduce(function(a, b) return a or b end)
        end)
        :reduce(function(a, b) return a or b end)
end

function battle_planner.resample_target(candidates, type, target, get_index)
    get_index = get_index or function(id)
        return nodes.position:get(id)
    end
    local similarity = {}
    function similarity.single(a, b)
        local ia = get_index(a)
        local ib = get_index(b)
        if ia * ib < 0 then
            return math.huge
        else
            return math.abs(ia - ib)
        end
    end

    function similarity.multiple(a, b)
        local function add(a, b) return a + b end
        print("a b", a, b)
        local ma = a:map(get_index):reduce(add, 0) / #a
        local mb = b:map(get_index):reduce(add, 0) / #b
        return math.abs(ma - mb)
    end

    function similarity.all(a, b)
        -- THis is because all only contains one candidate
        return 1
    end

    function similarity.self(a, b)
        return a ~= b
    end

    local sf = similarity[type]

    local elist = list()

    local pot_targets = candidates:values():reduce(elist.concat, elist)
    print("potential", pot_targets)
    local score = pot_targets:map(function(v) return sf(v, target) end)

    local most_likely = score:argsort():head()
    return pot_targets[most_likely]
end

function battle_planner.is_finished(self)
    local party_alive = is_alive("party")

    local enemy_alive = is_alive("enemy")

    return not party_alive or not enemy_alive
end

function battle_planner:__draw()
    local font = require "ui/fonts"
    if self.victory then
        gfx.setFont(font(60))
        if self.victory == "Fail" then
            gfx.setColor(1.0, 0.5, 0.2)
        else
            gfx.setColor(0.7, 0.9, 1.0)
        end
        gfx.printf(self.victory, gfx.getWidth() / 2 - 500, 50, 1000, "center")
    end
    if self.action_planner then
        self.action_planner:draw()
    end
end

function battle_planner:__update(dt)
    if self.action_planner then
        self.action_planner:update(dt)
    end
end

return battle_planner
