local attack = require "ability/attack"
local target = require "ability/target"
local heal = require "ability/heal"
local shield = require "ability/shield"
local thunder = require "ability/thunder"
local sap = require "ability/sap"
local ui = require "ui"

local Planner = {}
Planner.__index = Planner

Planner.selection = {}

function Planner:create(get_target_cache, set_target_cache)
    self.menus = List.create()
    self.on_select = Event.create()
    self.get_target_cache = get_target_cache
    self.set_target_cache = set_target_cache
end


function Planner.selection.enter(self, prev_state, user, index)
    self.user = user
    self.initial_index = index
    self.pos = nodes.position:get_world(user) + vec2(-125, -425)
    self:fork(Planner.selection.control)
end

function Planner:on_destroyed()
    for _, menu in ipairs(self.menus) do
        menu:destroy()
    end
    if self.target then
        self.target:destroy()
    end
end

local control = {}

function control.reset(self)
    for _, m in pairs(self.menus) do
        self.menus:destroy()
    end
    self.menus = List.create()
    return Planner.selection.control(self)
end

function control.select_target(self, index, action)
    if not action then
        return self.on_select(nil, nil, index)
    end

    --local t = action.target.type

    --local placement = nodes.position.placements
    local target_candidates = target.candidates(action.target, self.user)

    if target_candidates.primary:size() == 0
        and target_candidates.secondary:size() == 0
    then
        -- Do a beep thing that signals invalid stuff
        return control.wait_for_item(self)
    end

    self.target = process.create(target.generic, target_candidates)

    -- Fectch cached target
    local function get_cached_target()
        if (
            not action or action.target.type == "all"
            or action.target.type == "self"
        ) then
            return
        elseif action.target.type == "multiple" then
            local batch = self.get_target_cache(action, self.user)
            if batch == 0 then return end

            local function get_mean_index(batch)
                return batch
                    :map(function(id)
                        return nodes.position:get(id) / #batch
                    end)
                    :reduce(function(a, b) return a + b end)
            end

            local mean_index = get_mean_index(batch)

            local batch = list(unpack(self.target.__target_batches))
                :map(function(l)
                    return get_mean_index(l:head())
                end)
                :map(function(i) return math.abs(i - mean_index) end)
                :argsort()
                :head()
            return 0, 1, batch
        elseif action.target.type == "single" then
            local id = self.get_target_cache(action, self.user)
            if id == 0 then return end
            local pos = nodes.position:get(id)

            local l = list()
            for b, t in pairs(self.target.__target_batches) do
                for index, id in pairs(t) do
                    l[#l + 1] = {id = id, index = index, batch = b}
                end
            end

            local function get_dist(ida)
                local posa = nodes.position:get(ida)
                return math.abs(posa - pos)
            end

            local last_target = l
                :sort(function(a, b)
                    return get_dist(a.id) < get_dist(b.id)
                end)
                :head()

            return last_target.id, last_target.index, last_target.batch
        end

    end

    local last_id, last_index, last_batch = get_cached_target()

    if last_id then
        self.target:set_batch(last_batch)
        self.target:set_target(last_index)
    end

    local l = self.target.on_change:listen(function(target)
        self.set_target_cache(action, self.user, target)
    end)

    local event_args = self:wait(
        self.target.on_select, self.target.on_abort
    )
    l:remove()
    self.target:destroy()

    if event_args.event == self.target.on_abort then
        self.target = nil
        return control.wait_for_item(self)
    else
        local target = unpack(event_args)
        self.on_select(action, target, index)
    end
end

function control.wait_for_item(self)
    local menu = self.menus:tail()
    menu:enable()
    local event_args = self:wait(menu.on_select, menu.on_abort)

    if event_args.event == menu.on_select then
        local index, name, value = unpack(event_args)
        if istype(value, List) then
            self:spawn_menu(value)
            return control.wait_for_item(self)
        else
            return control.select_target(self, index, value)
        end
    elseif self.menus:size() > 1 then
        self.menus:tail():destroy()
        self.menus = self.menus:erase()
        self.menus:tail():enable()
        return control.wait_for_item(self)
    else
        return control.wait_for_item(self)
    end
end

function Planner.selection.control(self)
    local ability = nodes.game:get_stat("ability", self.user) or list()

    local function ability2item(a, t)
        local name = a.name and a.name() or "Unknown"
        return ui.menu.item(name, a, t)
    end

    local unlocked_items = (
            nodes.game:get_stat("unlocked", self.user) or list()
        )
        :map(function(a) return ability2item(a, "blue") end)

    local main_items = ability
        :map(ability2item)
        :concat(unlocked_items)
        :insert(ui.menu.item("Pass", nil))

    self.tip = self:child(ui.textbox)
        :set_text("Foobar")
        :set_text("Deal 1 damage to a foe.")

    self:spawn_menu(main_items, self.initial_index)

    return control.wait_for_item(self)
end


function Planner:spawn_menu(items, index)
    index = index or 1
    local node = self:child(ui.menu)
        :set_items(items)
        :set_window_size(6)
        :set_selected(index)

    local function get_help_text(action)
        local s = action.help_text(self.user)
        local u = action.unlock or {}
        if #u == 0 then
            return s
        else
            local ability = require "ability"
            u = list(unpack(u))
                :map(function(p) return ability(p) end)
            local s2 = u:head().name()
            u = u:erase(1)
            for _, a in pairs(u) do
                s2 = s2 .. ', ' .. a.name()
            end
            if #s > 0 then
                return s .. "\n\nUNLOCK: " .. s2
            else
                return "UNLOCK: " .. s2
            end
        end
    end

    local function help_callback(index, name, action)
        if action ~= nil and action.help_text then
            self.tip:set_text(get_help_text(action))
        elseif action then
            self.tip:set_text("No help")
        else
            self.tip:set_text("Skip your turn")
        end
    end
    help_callback(node:get_selected_item())
    node.on_change:listen(help_callback)
    self.menus = self.menus:insert(node)
end

function Planner:__update(dt)
    for _, menu in pairs(self.menus) do
        --menu:update(dt)
    end
    if self.target then self.target:update(dt) end
end


function Planner:draw()
    local x, y = self.pos:unpack()
    for i, menu in ipairs(self.menus) do
        local s = menu:get_spatial()
        menu:draw(x + 50 * i, y + i * 10 - 150)
    end
    if self.tip then
        local anchor = self.menus:head():get_spatial()--Spatial.create(gfx.getWidth() / 2, 0, 0, 0)
        local pos = self.tip:get_spatial()
            :xalign(anchor, "center", "center")
            :yalign(anchor, "top", "bottom")
            :move(0, -3)
        local i = #self.menus
        self.tip:draw(pos.x + 50 * i + x, pos.y + y + i * 10 - 150)
    end
    if self.target then
        self.target:draw()
    end
end


return Planner
