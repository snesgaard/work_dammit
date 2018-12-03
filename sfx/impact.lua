local Moonshine = require "modules/moonshine"
local particles = require "sfx/particles"

local sfx = {}

local DURATION = 0.5
local COUNT = 30

function sfx:create()
    self.particle = particles{
        image = "art/part.png",
        buffer = COUNT,
        rate = COUNT,
        dir = -math.pi * 0,
        lifetime = 0.2,
        acceleration = {-1000, 0},
        size = 0.5,
        speed =  {1400, 1500},
        area = {"borderellipse", 50, 50, 0, false},
        color = {
            1.0, 0.5, 0.5, 1,
            1.0, 0.5, 0.5, 0
        },
        damp = 5,
        spread = 1.0,
        relative_rotation = true,
        rotation = math.pi * 0.5
    }
    self.on_finish = event()
    self:fork(self.life)
end

function sfx:life()
    self.particle:emit(COUNT)
    self.particle:stop()
    while self.particle:getCount() ~= 0 do
        self:wait_update()
    end
    self.on_finish()
    self:destroy()
end

function sfx:__update(dt)
    self.particle:update(dt)
end

function sfx:__draw(x, y)
    gfx.draw(self.particle, x, y)
end

return sfx
