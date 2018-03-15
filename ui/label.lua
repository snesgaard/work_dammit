local Spatial = require "spatial"

local Label = {}
Label.__index = Label

function Label.create()
    local this = {
        text = "",
        spatial = Spatial.create(0, 0, 100, 100),
        valign = "center",
        align = "center",
    }
    return setmetatable(this, Label)
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

function Label:set_valign(valign)
    self.valign = valign
    return self
end

function Label:draw(x, y, r, sx, sy)
    local pos, size = self.spatial.pos, self.spatial.size
    local w, h = unpack(size)
    --gfx.setColor(0, 0, 255, 100)
    --gfx.rectangle("fill", pos[1] + x, pos[2] + y, w, h)
    --gfx.setColor(255, 255, 255)
    sx = sx or 1
    sy = sy or sx
    local font = gfx.getFont()
    if self.valign == "center" then
        y = y + h * 0.5 - font:getHeight() * 0.5 * sy
    elseif self.valign == "bottom" then
        y = y + h - font:getHeight() * sy
    end

    gfx.printf(
        self.text, pos[1] + x, pos[2] + y, w / sx, self.align, r, sx, sy
    )
end

return Label
