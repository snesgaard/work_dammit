local Label = require "ui/label"
local Bar   = require "ui/bar"
local Spatial = require "spatial"

local StatBar = {}
StatBar.__index = StatBar

function StatBar:__tostring()
    return "CharacterBar"
end

function StatBar.create()
    local this = {
        bar         = Bar.create(),
        name_label  = Label.create()
            :set_align("left")
            :set_valign("bottom")
        ,
        value_label = Label.create()
            :set_align("right")
            :set_valign("bottom")
        ,
    }
    this = setmetatable(this, StatBar)
    this:set_spatial()
    this:set_value(5, 5)
    return this
end

function StatBar:set_spatial(root)
    root = root or Spatial.create()
    root = root:set_size(125, 15)
    self.name_label.spatial = root
    self.value_label.spatial = root
    self.bar.spatial = root:move(0, 0, nil, "bottom"):set_size(nil, 5)
    return self
end

function StatBar:get_spatial()
    return self.name_label.spatial
end

function StatBar:set_value(value, max_value)
    local text = string.format("%i / %i", value, max_value)
    self.value_label.text = text
    self.bar.value = value
    self.bar.max_value = max_value
    return self
end

function StatBar:set_name(name)
    self.name_label.text = name
    return self
end

function StatBar:draw(...)
    self.bar:draw(...)
    self.name_label:draw(...)
    self.value_label:draw(...)
end

return StatBar
