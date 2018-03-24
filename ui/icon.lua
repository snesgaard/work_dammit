local Frame = require "ui/frame"

local Icon = {}
Icon.__index = Icon

function Icon.create()
    local this = {
        frame = Frame.create(),
        color = {255, 255, 255, 255},
        margin = 2
    }
    return setmetatable(this, Icon)
end

function Icon:set_margin(margin)
    self.margin = margin
    return self
end

function Icon:set_spatial(spatial)
    local w = self.im and self.im:getWidth() or 0
    local h = self.im and self.im:getHeight() or 0
    spatial = spatial:set_size(w + self.margin * 2, h + self.margin * 2)
    self.frame:set_spatial(spatial)
    return self
end

function Icon:get_spatial()
    return self.frame.spatial
end

function Icon:draw(x, y, r, sx, sy)
    self.frame:draw()
    if self.im then
        gfx.setColor(unpack(self.color))
        gfx.draw(self.im, x, y, r, sx, sy)
    end
end

return Icon
