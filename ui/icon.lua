local Frame = require "ui/frame"
local Spatial = require "spatial"

local Icon = {}
Icon.__index = Icon

function Icon.create()
    local this = {
        frame = Frame.create(),
        margin = 2
    }
    return setmetatable(this, Icon)
end

function Icon:set_color(...)
    self.frame:set_color(...)
    return self
end

function Icon:set_image(im)
    self.im = im
    self:clear_structure()
    return self
end

function Icon:clear_structure()
    self.__structure = nil
end

function Icon:get_structure()
    if self.__structure then return self.__structure end

    local structure = Dictionary.create()
    structure.image = Spatial.create(
        0, 0, self.im and self.im:getWidth() or 0,
        self.im and self.im:getHeight() or 0
    )
    structure.frame = structure.image
        :expand(self.margin * 2, self.margin * 2)
        :move(self.margin, self.margin)
    structure.image = structure.frame
        :expand(-self.margin * 2, -self.margin * 2)

    self.frame.spatial = structure.frame

    self.__structure = structure
    return self.__structure
end

function Icon:set_margin(margin)
    self.margin = margin
    self:clear_structure()
    return self
end

function Icon:get_spatial()
    local structure = self:get_structure()
    return structure.frame
end

function Icon:draw(x, y, r, sx, sy)
    local s = self:get_structure()
    --self.frame.spatial = s.frame
    self.frame:draw(x, y)
    if self.im then
        gfx.setColor(255, 255, 255)
        gfx.draw(self.im, x + s.image.x, y + s.image.y, r, sx, sy)
    end
end

return Icon
