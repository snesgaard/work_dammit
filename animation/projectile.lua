local ease = require "ease"
local Sprite = require "animation/sprite"

local projectile = {}

function projectile.ballistic(node, h, travel_time, stop_pos)
    local xtween = Timer.tween(
        travel_time,
        {
            [node.pos] = {x = stop_pos.x},
        }
    )
    local atween = Timer.tween(
        travel_time,
        {
            [node] = {angle = math.pi * 2}
        }
    )
        :ease(ease.inQuad)
    local ytween = Timer.tween(
        travel_time,
        {
            [node.pos] = {y = stop_pos.y}
        }
    )
        :ease(function(t, init, dy, time)
            a = -h * 4.0 + 2 * dy
            b = h * 4.0 - dy
            t = t / time
            return a * t * t + b * t + init
        end)

    return xtween, ytween, atween
end

projectile.sprite = {}

function projectile.sprite:create(pos, idle, impact, atlas)
    self.pos = pos or vec2(0, 0)
    self.angle = 0
    self.sprite = self:__create_sprite(idle, impact, atlas)
        :set_animation("idle")
end

function projectile.sprite:__create_sprite(idle, impact, atlas)
    local animations = {}

    function animations.idle(sprite, dt)
        sprite:loop(dt, idle)
    end

    function animations.impact(sprite, dt)
        sprite:play(dt, impact)
        self:destroy()
    end

    return Sprite.create(get_atlas(atlas or "art/props"), animations)
end

function projectile.sprite:__update(dt)
    self.sprite:update(dt)
end

function projectile.sprite:__draw(x, y)
    gfx.setColor(0, 1, 0)
    x = (x or 0) + self.pos.x
    y = (y or 0) + self.pos.y
    gfx.push()
    gfx.origin()
    gfx.translate(x, y)
    gfx.rotate(self.angle)
    self.sprite:draw(0, 0)
    gfx.pop()

end


return projectile
