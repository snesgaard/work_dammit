local Spatial = require "spatial"

local Label = {}
Label.__index = Label

function Label.create()
    local this = {
        text = "",
        spatial = Spatial.create(0, 0, 100, 100),
        color   = {0, 0, 0},
        valign = "center",
        align = "center",
        font = gfx.newFont(12)
    }
    return setmetatable(this, Label)
end

function Label:set_font(font)
    self.font = font
    return self
end

function Label:set_spatial(spatial)
    self.spatial = spatial
    return self
end

function Label:set_text(text)
    self.text = text
    return self
end

function Label:set_align(align)
    self.align = align
    return self
end

function Label:set_color(...)
    self.color = {...}
    return self
end

function Label:set_valign(valign)
    self.valign = valign
    return self
end

function Label:draw(x, y, r, sx, sy)
    local _x, _y, w, h = self.spatial:unpack()
    if self.font then
        gfx.setFont(self.font)
    else
        gfx.setFont()
    end
    sx = sx or 1
    sy = sy or sx
    local font = gfx.getFont()
    if self.valign == "center" then
        y = y + h * 0.5 - font:getHeight() * 0.5 * sy
    elseif self.valign == "bottom" then
        y = y + h - font:getHeight() * sy
    end

    gfx.setColor(unpack(self.color))
    gfx.printf(
        self.text, _x + x, _y + y, w / sx, self.align, r, sx, sy
    )
end

return Label
