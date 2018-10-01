local label = require "ui/label"
local frame = require "ui/frame"
local spatial = require "spatial"
local font = require "ui/fonts"

local labelbox = {}

function labelbox:create()
    self.ui = {
        label = {
            text = label.create()
                :set_font(font(14))
                :set_align("center")
                :set_valign("center")
            ,
            title = label.create()
                :set_font(font(12))
                :set_align("center")
                :set_valign("center")
        },
        inner_frame = {
            text = frame.create()
                :set_color(1, 1, 1)
                :set_corner(5),
            title = frame.create()
                :set_color(1, 1, 1)
                :set_corner(5)
        },
        outer_frame = {
            text = frame.create()
                :set_color(0.55, 0.55, 0.55)
                :set_corner(5),
            title = frame.create()
                :set_color(0.55, 0.55, 0.55)
                :set_corner(5)
        }
    }

    self.pos = vec2(0, 0)
    self.max_width = 300
    self.min_width = 200
    self.margin = {
        text = {
            inner = 20,
            outer = 10
        },
        title = {
            inner = 5,
            outer = 10,
        }
    }
    local foo = "Deal 1 damage.\n\nIf armor is greater than 4."
    self:set_text(foo):set_title("HELP"):set_theme()
end

function labelbox:set_width(min, max)
    min = min or 300
    max = max or min
    if self.min_width ~= min or self.max_width ~= max then
        self.min_width = min
        self.max_width = max or min
        return self:structure()
    else
        return self
    end
end

function labelbox:structure()
    local w, h = self.ui.label.text:get_text_size(self.max_width)
    w = math.max(w, self.min_width)
    local base = spatial.create(
        (self.margin.text.inner + self.margin.text.outer) / 2,
        (self.margin.text.inner + self.margin.text.outer) / 2,
        w, h
    )
    self.ui.label.text:set_spatial(base)
    local inner = base:expand(self.margin.text.inner)
    self.ui.inner_frame.text:set_spatial(inner)
    self.ui.outer_frame.text:set_spatial(
        inner:expand(self.margin.text.outer)
    )

    self.border = spatial.join(
        self.ui.outer_frame.text:get_spatial()
    )
    return self
end

function labelbox:set_text(text)
    self.ui.label.text:set_text(text)
    return self:structure()
end

function labelbox:set_title(title)
    self.ui.label.title:set_text(title)
    return self
end

function labelbox:get_spatial()
    return self.ui.outer_frame.text:get_spatial()
end

function labelbox:set_spatial(spatial)
    self.pos = vec2(spatial.x, spatial.y)
    return self
end

function labelbox:set_font(font)
    self.ui.label.text:set_font(font)
    return self:structure()
end

function labelbox:set_theme(theme)
    theme = theme or "white"

    local __themes = {
        white = {
            outer_frame = {0.55, 0.55, 0.55},
            inner_frame = {1, 1, 1},
            label = {0, 0, 0},
        },
        blue = {
            inner_frame = {0.0, 0.0, 0.2, 0.3},
            outer_frame = {0.0, 0.0, 0.1, 0.3},
            label = {1, 1, 1}
        }
    }

    local t = __themes[theme]

    if t then
        for key, val in pairs(t) do
            self.ui[key].text:set_color(unpack(val))
        end
    end

    return self
end

function labelbox:__draw(x, y)
    x = (x or 0) + self.pos.x
    y = (y or 0) + self.pos.y
    self.ui.outer_frame.text:draw(x, y)
    --self.ui.outer_frame.title:draw(x, y)
    self.ui.inner_frame.text:draw(x, y)
    --self.ui.inner_frame.title:draw(x, y)
    self.ui.label.text:draw(x, y)
    --self.ui.label.title:draw(x, y)
end

return labelbox
