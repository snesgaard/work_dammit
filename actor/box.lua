local BoxSprite = {}
BoxSprite.__index = BoxSprite

function BoxSprite.__tostring()
    return "BoxSprite"
end

function BoxSprite.create()
    local this = {
    }
    return setmetatable(this, BoxSprite)
end

function BoxSprite:draw(x, y, r, sx, sy)
    gfx.setColor(255, 255, 255)
    local w, h = 30 * sx, 75 * sy
    gfx.rectangle("fill", x - w * 0.5, y, w, -h)
end

function BoxSprite:set_animation()
    return self
end

function BoxSprite:set_color(r, g, b, a)
    self.color = {r, g, b, a}
    return self
end

local box = {}

function box.init_visual(state, id)
    state.sprite[id] = BoxSprite.create()
end

function box.init_state(state, id)
    return state
        :set("max_health/" .. id, 5)
        :set("agility/" .. id, 1)
        :set("power/" .. id, 2)
        :set("name/" .. id, "Box")
end

return box
