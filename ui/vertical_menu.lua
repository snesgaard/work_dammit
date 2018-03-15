local Event = require "event"
local List  = require "list"
local Vec2  = require "vec2"
local Dictionary = require "dictionary"
local Spatial = require "spatial"
local FSM = require "fsm"

local Frame = require "ui/frame"
local Label = require "ui/label"

local VItem = {}
VItem.__index = VItem

setmetatable(VItem, {__index = FSM})

VItem.STATES = {selected = {}, unselected = {}}

function VItem.STATES.selected:begin()
    Timer.tween(0.25, {[self.frame.color] = {255, 255, 0}})
end

function VItem.STATES.selected.update(dt)
end

function VItem.STATES.unselected:begin()
    self.frame:set_color(255, 255, 255)

end

function VItem.create(text)
    local this = {}
    this.frame = Frame.create():set_color(255, 255, 255)
    this.label = Label.create():set_text(text)

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
        shape = Vec2(100, 30),
    }
    this = setmetatable(this, VMenu)
    this:set_items(List.create("Foo", "Bar", "Spam"))
    return this
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
            :set_state(i == 1 and "selected" or "unselected")
    end
    self.outer_frame = Frame.create()
        :set_spatial(self.structure.frame)
        :set_color(125, 125, 125)
    return self
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
