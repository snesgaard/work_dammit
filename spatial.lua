local Vec2 = require "vec2"
local List = require "list"

local Spatial = {}
Spatial.__index = Spatial

function Spatial.__tostring(s)
    return string.format(
        'Spatial :: pos = [%f, %f], size = [%f, %f]', s.x, s.y, s.w, s.h
    )
end

function Spatial.create(x, y, w, h)
    return setmetatable(
        {x = x or 0, y = y or 0, w = w or 0, h = h or 0}, Spatial
    )
end

function Spatial:copy()
    return Spatial.create(self.x, self.y, self.w, self.h)
end

function Spatial:move(x, y, align, valign)
    align = align or "left"
    x = align == "right" and x + self.w or x
    y = valign == "bottom" and y + self.h or y
    --return Spatial.create(self.pos:add(pos), self.size)
    return Spatial.create(self.x + x, self.y + y, self.w, self.h)
end

function Spatial:set_position(x, y)
    local pos = Vec2(x or self.pos[1], y or self.pos[2])
    --return Spatial.from_vec(pos, self.size)
    return Spatial.create(x or self.x, y or self.y, self.w, self.h)
end

function Spatial:unpack()
    return self.x, self.y, self.w, self.h
end

function Spatial:expand(w, h, align)
    local scale = {left = 0, center = 0.5, right = 1}
    local s = scale[align or "center"]
    s = s or scale.center
    --return Spatial.from_vec(
    --    self.pos:sub(size:dot(s)), self.size:add(size)
    --)
    return Spatial.create(
        self.x - w * s, self.y - h * s, self.w + w, self.h + h
    )
end

function Spatial:set_size(w, h)
    --local size = Vec2(w or self.size[1], h or self.size[2])
    --return Spatial.from_vec(self.pos, size)
    return Spatial.create(self.x, self.y, w or self.w, h or self.h)
end

function Spatial.border(...)
    local function to_border(spatial)
        local x, y, w, h = spatial:unpack()
        return {x, y, x + w, y + h}
    end
    local function merge_border(a, b)
        local ax_l, ay_l, ax_u, ay_u = unpack(a)
        local bx_l, by_l, bx_u, by_u = unpack(b)
        return {
            ax_l < bx_l and ax_l or bx_l,
            ay_l < by_l and ay_l or by_l,
            ax_u < bx_u and bx_u or ax_u,
            ay_u < by_u and by_u or ay_u,
        }
    end
    local border = List.create(...):map(to_border):reduce(merge_border)
    return Spatial.create(
        border[1], border[2], border[3] - border[1],
        border[4] - border[2]
    )
end

return Spatial
