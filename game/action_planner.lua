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

function Planner:create()
    self.menus = List.create()
    self.on_select = Event.create()
end


function Planner.selection.enter(self, prev_state, user)
    self.user = user
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

function control.select_target(self, action)
    if not action then
        return self.on_select()
    end

    local t = action.target.type
    local placement = nodes.position.placements
    local targets = action.target.candidates(placement, self.user)
        :values()
        :sort(function(a, b)
            return nodes.position:get(a) > nodes.position:get(b)
        end)

    if targets:size() == 0 then
        -- Do a beep thing that signals invalid stuff
        return control.wait_for_item(self)
    end
    self.target = process.create(t, targets)

    local event_args = self:wait(self.target.on_select, self.target.on_abort)
    self.target:destroy()

    if event_args.event == self.target.on_abort then
        self.target = nil
        return control.wait_for_item(self)
    else
        self.on_select(action, unpack(event_args))
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
            return control.select_target(self, value)
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

    local function ability2item(a)
        local name = a.name and a.name() or "Unknown"
        return ui.menu.item(name, a)
    end

    local main_items = ability
        :map(ability2item)
        :insert(ui.menu.item("Pass", nil))

    self.tip = self:child(ui.textbox)
        :set_text("Foobar")
        :set_text("Deal 1 damage to a foe.")

    self:spawn_menu(main_items)

    return control.wait_for_item(self)
end


function Planner:spawn_menu(items)
    local node = self:child(ui.menu)
        :set_items(items)
        :set_window_size(6)
        :set_selected(1)
    local function help_callback(index, name, action)
        if action ~= nil and action.help_text then
            self.tip:set_text(action.help_text(self.user))
        elseif action then
            self.tip:set_text("No help.")
        else
            self.tip:set_text("Skip your turn.")
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
