local Vec2 = require "vec2"
local List = require "list"

local Spatial = {}
Spatial.__index = Spatial

function Spatial.__tostring(s)
    return string.format(
        'Spatial :: pos = %s, size = %s', tostring(s.pos), tostring(s.size)
    )
end

function Spatial.create(x, y, w, h)
    local pos, size = Vec2(x or 0, y or 0), Vec2(w or 0, h or 0)
    return setmetatable({pos = pos, size = size}, Spatial)
end

function Spatial.from_vec(pos, size)
    return Spatial.create(pos[1], pos[2], size[1], size[2])
end

function Spatial:move(x, y, align, valign)
    align = align or "left"
    local pos = Vec2(
        align == "right" and x + self.size[1] or x,
        valign == "bottom" and y + self.size[2] or y
    )
    return Spatial.from_vec(self.pos:add(pos), self.size)
end

function Spatial:set_position(x, y)
    local pos = Vec2(x or self.pos[1], y or self.pos[2])
    return Spatial.from_vec(pos, self.size)
end

function Spatial:unpack()
    return self.pos, self.size
end

function Spatial:expand(w, h, align)
    local size = Vec2(w, h)
    local scale = {left = 0, center = 0.5, right = 1}
    local s = scale[align or "center"]
    s = s or scale.center
    return Spatial.from_vec(
        self.pos:sub(size:dot(s)), self.size:add(size)
    )
end

function Spatial:set_size(w, h)
    local size = Vec2(w or self.size[1], h or self.size[2])
    return Spatial.from_vec(self.pos, size)
end

function Spatial.border(...)
    local function to_border(spatial)
        local pos, size = spatial.pos, spatial.size
        return {pos[1], pos[2], pos[1] + size[1], pos[2] + size[2]}
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
