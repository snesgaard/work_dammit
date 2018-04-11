local Event = require "event"
local List  = require "list"
local Vec2  = require "vec2"
local Dictionary = require "dictionary"
local Spatial = require "spatial"
local FSM = require "fsm"

local Frame = require "ui/frame"
local Label = require "ui/label"
local Fonts = require "ui/fonts"

local VItem = {}
VItem.__index = VItem

setmetatable(VItem, {__index = FSM})

VItem.STATES = {selected = {}, unselected = {}}

function VItem.STATES.selected:begin()
    self.__workspace.spatial = self.frame.spatial:copy()
end

function VItem.STATES.selected.convoke(handle, self)
    local spatial = self.__workspace.spatial
    local tween = handle:tween(0.1, {
        [self.frame.spatial] = spatial:expand(5, 5)
    })
    handle:tween(0.1, {[self.frame.color] = {255, 255, 0}})
    handle:wait(tween)
    tween = handle:tween(0.1, {
        [self.frame.spatial] = spatial:expand(2, 2)
    })
    handle:tween(0.1, {[self.frame.color] = {255, 255, 125}})
    handle:wait(tween)
    while true do
        tween = handle:tween(0.5, {[self.frame.color] = {255, 255, 50}})
        handle:wait(tween)
        tween = handle:tween(0.5, {[self.frame.color] = {255, 255, 125}})
        handle:wait(tween)
        handle:wait(0.5)
    end
end


function VItem.STATES.selected:exit()
    self.frame.spatial = self.__workspace.spatial
end

function VItem.STATES.unselected:begin()
    self.frame:set_color(255, 255, 255)
end

function VItem.create(text)
    local this = {}
    this.frame = Frame.create():set_color(255, 255, 255)
    this.label = Label.create():set_text(text):set_font(Fonts(14))

    this = setmetatable(this, VItem)
    this:set_state("unselected")
    return this
end

function VItem:set_spatial(spatial)
    self.frame:set_spatial(spatial)
    self.label:set_spatial(spatial)
    return self
end

function VItem:draw(...)
    self.frame:draw(...)
    gfx.setColor(0, 0, 0)
    self.label:draw(...)
end

local VMenu = {}
VMenu.__index = VMenu

function VMenu.create()
    local this = {
        margin = 4,
        border_margin = 8,
        shape = Vec2(150, 30),
        on_select = Event.create(),
        on_escape = Event.create(),
    }
    this = setmetatable(this, VMenu)
    this:set_items(List.create("Foo", "Bar", "Spam", "foo", "bar", "spam"))
    this:set_selection(1)
    return this
end

function VMenu:set_selection(index)
    local size = #self.items
    if index < 1 then
        return self:set_selection(index + size)
    elseif index > size then
        return self:set_selection(index - size)
    end
    if self.selected then
        self.ui_items[self.selected]:set_state("unselected")
    end
    self.selected = index
    self.ui_items[self.selected]:set_state("selected")
    return self
end

function VMenu:get_selection()
    local index = self.selected
    local item = self.items and self.items[index] or nil
    return item, index
end

function VMenu:next_item()
    return self:set_selection(self.selected + 1)
end

function VMenu:prev_item()
    return self:set_selection(self.selected - 1)
end

function VMenu:get_structure()
    local structure = Dictionary.create()
    local pos = Spatial.create(
        self.margin, self.margin, self.shape[1], self.shape[2]
    )
    for i = 1, self.items:size() do
        structure[i] = pos
        pos = pos:move(0, self.margin, nil, "bottom")
    end
    structure.frame = Spatial.border(unpack(structure))
        :expand(self.border_margin, self.border_margin)
    return structure
end

function VMenu:set_items(items)
    self.items = items
    self.structure = self:get_structure()
    self.ui_items = {}
    for i, spatial in ipairs(self.structure) do
        self.ui_items[i] = VItem.create(items[i])
            :set_spatial(spatial)
            --:set_state(i == 1 and "selected" or "unselected")
    end
    self.outer_frame = Frame.create()
        :set_spatial(self.structure.frame)
        :set_color(125, 125, 125)
    self.selected = nil
    self:set_selection(1)
    return self
end

function VMenu:keypressed(key)
    local interval = 0.35
    if key == "up" then
        self:prev_item()
        --self.up_tween = Timer.every(interval, function() self:prev_item() end)
    elseif key == "down" then
        self:next_item()
        --self.down_tween = Timer.every(interval, function() self:next_item() end)
    elseif key == "space" then
        self.on_select(self:get_selection())
    elseif key == "lshift" then
        self.on_escape()
    end
end

function VMenu:keyreleased(key)
    if key == "up" then
        if self.up_tween then self.up_tween:remove() end
    elseif key == "down" then
        if self.down_tween then self.down_tween:remove() end
    end
end

function VMenu:halt()
    if self.up_tween then  self.up_tween:remove() end
    if self.down_tween then self.down_tween:remove() end
end

function VMenu:draw(...)
    self.outer_frame:draw(...)
    for _, item in ipairs(self.ui_items) do
        item:draw(...)
    end
end

function VMenu:update(...)
    for _, item in ipairs(self.ui_items) do item:update(...) end
end


return VMenu
