
local Sprite = require "animation/sprite"

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
    gfx.setColor(unpack(self.color))
    local amp = self.shake_data.amp
    local phase = self.shake_data.phase
    x = x + self.spatial.x + math.sin(phase) * amp
    y = y + self.spatial.y
    sx = sx or 1
    sy = sy or 1
    sx = sx * self.scale
    sy = sy * self.scale

    local w, h = 30 * sx, 75 * sy
    gfx.rectangle("fill", x - w * 0.5, y, w, -h)
end

function BoxSprite:set_origin() return self end

function BoxSprite:set_animation()
    return self
end

function BoxSprite:attack_offset() return 0 end

function BoxSprite:update() end

function BoxSprite:set_color(r, g, b, a)
    self.color = {r, g, b, a or 1}
    return self
end

local function attack_animation(self)
    self.on_user("attack")
    self.on_user("done")
end

local function cast_animation(self)
    while true do
        coroutine.yield()
        self.on_hitbox({cast = spatial(0, 0, 0, 0)})
    end
end

local function create_sprite()
    local sprite = Sprite.create()
    sprite.draw = BoxSprite.draw
    sprite:register("attack", attack_animation)
    sprite:register("cast", cast_animation)
    return sprite
end

return create_sprite
