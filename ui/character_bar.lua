local StatBar = require "ui/stat_bar"
local Label   = require "ui/label"
local Spatial = require "spatial"

local CharacterBar = {}
CharacterBar.__index = CharacterBar

function CharacterBar.create()
    local this = {
        hp_bar = StatBar.create():set_name("HP"):set_value(10, 10),
        mp_bar = StatBar.create():set_name("MP"):set_value(5, 5),
        name_label = Label.create():set_text("Fencer")
            :set_valign("bottom")
            :set_align("right")
            :set_color(255, 255, 255)
    }
    this = setmetatable(this, CharacterBar)
    this:set_spatial()
    return this
end

function CharacterBar:set_spatial(root)
    root = root or Spatial.create()

    self.name_label.spatial = root:set_size(50, 20)
    self.hp_bar:set_spatial(
        self.name_label.spatial:move(10, 0, "right")
    )
    self.mp_bar:set_spatial(
        self.hp_bar:get_spatial():move(10, 0, "right")
    )
end

function CharacterBar:draw(...)
    self.name_label:draw(...)
    self.hp_bar:draw(...)
    self.mp_bar:draw(...)
end

return CharacterBar
