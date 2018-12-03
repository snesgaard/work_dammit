local Moonshine = require "modules/moonshine"
local particles = require "sfx/particles"

local sparks = {}

local COUNT = 20

function sparks:create(left)
    self.left = left
    self.particle = particles{
        image = "art/part2.png",
        buffer = COUNT,
        rate = COUNT,
        dir = -math.pi * 0,
        lifetime = 0.45,
        acceleration = {0, 1000},
        size = 0.5,
        speed =  {500, 1000},
        area = {"uniform", 10, 0, math.pi},
        color = {
            1.0, 1.0, 0.6, 1,
            1.0, 1.0, 0.6, 0
        },
        damp = 2,
        spread = math.pi * 0.65,
        relative_rotation = true,
        rotation = math.pi * 0.5
    }
    self.on_finish = event()
    self:fork(self.life)
end

function sparks:__update(dt)
    self.particle:update(dt)
end

function sparks:life()
    self.particle:emit(COUNT)
    self.particle:stop()
    while self.particle:getCount() ~= 0 do
        self:wait_update()
    end
    self.on_finish()
    self:destroy()
end

function sparks:__draw(x, y, r, sx, sy)
    sx = sx or 1
    sy = sy or 1
    if self.left then
        sx = -sx
    end
    gfx.setColor(1, 1, 1)
    gfx.draw(self.particle, x, y, r, sx, sy)
end

return sparks
