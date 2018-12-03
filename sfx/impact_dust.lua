local particles = require "sfx/particles"
local moon = require "modules.moonshine"

local sfx = {}

local COUNT = 40

function sfx:create()
    self.dust1 = gfx.newCanvas(20, 20)
    self.dust1:renderTo(function()
        gfx.setColor(1, 1, 1)
        gfx.circle("fill", 10, 10, 5)
    end)

    self.dust2 = gfx.newCanvas(6, 16)
    self.dust2:renderTo(function()
        gfx.setColor(1, 1, 1)
        gfx.ellipse("fill", 3, 8, 3, 8)
    end)

    self.blur = moon(moon.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 0.5

    self.dust3 = gfx.newCanvas(20, 20)
    self.dust3:renderTo(function()
        gfx.setColor(1, 1, 1)
        self.blur.draw(function()
            gfx.circle("fill", 10, 10, 5)
        end)
    end)

    self.particles = list(
        particles{
            image = self.dust3,
            buffer = COUNT * 2,
            rate = 600 * 4,
            lifetime = 0.5,
            size = 4,
            speed = {200, 1000},
            acceleration = {0, -800},
            damp = 7,
            dir = -math.pi * 0.5,
            spread = math.pi * 0.7,
            color = {0.8, 0.6, 0.4, 0.5, 0.6, 0.4, 0.3, 0},
            area = {"uniform", 50, 30},
            relative_rotation = true,
            rotation = math.pi * 0.5
        },
        particles{
            image = self.dust2,
            buffer = COUNT,
            rate = 600,
            lifetime = 0.7,
            size = 0.75,
            speed = {500, 2000},
            acceleration = {0, 2000},
            damp = 4,
            dir = -math.pi * 0.5,
            spread = math.pi * 0.7,
            color = {0.8, 0.8, 0.4, 1.0, 0.6, 0.4, 0.3, 0},
            area = {"uniform", 10, 30},
            relative_rotation = true,
            rotation = math.pi * 0.5
        },
        particles{
            image = self.dust1,
            buffer = COUNT,
            rate = 600,
            lifetime = 0.7,
            size = {0.25, 1},
            speed = {500, 2000},
            acceleration = {0, 2000},
            damp = 4,
            dir = -math.pi * 0.5,
            spread = math.pi * 0.7,
            color = {0.6, 0.4, 0.3, 0.7, 0.6, 0.4, 0.3, 0},
            area = {"uniform", 10, 30},
            relative_rotation = true,
            rotation = math.pi * 0.5
        }
    )

    --self.particles[2] = nil
    self.particles[3] = nil

    self:fork(self.life)
end

function sfx:life()
    local on_done = event()

    for _, p in ipairs(self.particles) do
        self:fork(self.particle_life, p, on_done)
    end

    for _, _ in ipairs(self.particles) do
        self:wait(on_done)
    end

    self:destroy()
end

function sfx:particle_life(particles, on_done)
    while particles:getCount() ~= particles:getBufferSize() do
        self:wait_update()
    end
    particles:stop()
    while particles:getCount() ~= 0 do
        self:wait_update()
    end
    on_done()
end

function sfx:__update(dt)
    for _, p in ipairs(self.particles) do
        p:update(dt)
    end
end

function sfx:__draw(x, y)
    gfx.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        gfx.draw(p, x, y)
    end
end

return sfx
