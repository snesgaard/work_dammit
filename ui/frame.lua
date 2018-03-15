local Spatial = require "spatial"

local Frame = {}
Frame.__index = Frame

function Frame.create()
    local this = {
        spatial = Spatial.create(0, 0, 0, 0),
        corner = 5,
        color = {255, 255, 255},
    }
    return setmetatable(this, Frame)
end

function Frame:set_color(r, g, b, a)
    self.color = {r, g, b, a}
    return self
end
function Frame:set_spatial(spatial)
    self.spatial = spatial
    return self
end
function Frame:set_corner(corner)
    self.corner = corner
    return self
end

function Frame:draw(x, y)
    gfx.setColor(unpack(self.color))
    local pos, size = self.spatial:unpack()
    gfx.rectangle("fill", x + pos[1], y + pos[2], size[1], size[2], self.corner)
end

return Frame
