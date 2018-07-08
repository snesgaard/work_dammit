local attack = require "ability/attack"
local target = require "ability/target"

local Planner = {}
Planner.__index = Planner

Planner.selection = {}

function Planner:create()
    self.menus = List.create()
    self.on_select = Event.create()
end


function Planner.selection.enter(self, prev_state, user)
    self.user = user
    self.pos = nodes.position:get_world(user) + vec2(-125, -400)
    self:fork(Planner.selection.control)
end

function Planner:on_destroyed()
    for _, menu in ipairs(self.menus) do
        menu:kill()
        menu:destroy()
    end
    if self.target then
        self.target:destroy()
    end
end

local control = {}

function control.reset(self)
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
    if not menu.alive then
        menu:revive()
    end
    local event_args = self:wait(menu.on_select, menu.on_abort)

    if event_args.event == menu.on_select then
        local index, item = unpack(event_args)
        if istype(item.value, List) then
            menu:kill()
            self:spawn_menu(item.value)
            return control.wait_for_item(self)
        else
            menu:kill()
            return control.select_target(self, item.value)
        end
    elseif self.menus:size() > 1 then
        self.menus = self.menus:erase()
        self.menus:tail():revive()
        return control.wait_for_item(self)
    else
        return control.wait_for_item(self)
    end
end

function Planner.selection.control(self)
    local main_items = List.create(
        ui.menu.Item("Attack", attack),
        ui.menu.Item("Pass", nil)
        --ui.menu.Item("Attack2", attack)
    )

    self:spawn_menu(main_items)

    return control.wait_for_item(self)
end


function Planner:spawn_menu(items)
    local node = process.create(ui.menu.Menu, items)
    self.menus = self.menus:insert(node)
end


function Planner:__update(dt)
    for _, menu in pairs(self.menus) do
        menu:update(dt)
    end
    if self.target then self.target:update(dt) end
end


function Planner:draw()
    local x, y = self.pos:unpack()
    for i, menu in ipairs(self.menus) do
        menu:draw(x + 50 * i, y + i * 10)
    end
    if self.target then
        self.target:draw()
    end
end


return Planner
