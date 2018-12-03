local ease = require "ease"
local blast = {}

function blast:create()
    local moon = require "modules/moonshine"
    self.blur = moon(moon.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 2.5
    self.on_done = event()

    self:fork(self.animation)
end

function blast.__create_fog_particles()
    local particle = require "sfx/particles"
    local atlas = get_atlas("art/props")

    return particle{
        image = atlas.sheet,
        buffer = 20,
        lifetime = {1.0, 1.2},
        rate = 10000,
        spread = 0,
        size = 2,
        speed = {10, 3000},
        damp = 10,
        acceleration = {75, 0},
        color = {1, 1, 1, 0.2, 1, 1, 1, 0.2, 1, 1, 1, 0},
        quad = atlas:get_animation("blast_fog"):head().quad,
        area = {"uniform", 10, 50}
    }
end

function blast:__draw(x, y)
    x = x or 0
    y = y or 0
    local function draw_fog()
        gfx.setColor(1, 0.7, 0.2)
        if self.left_part then
            gfx.draw(self.left_part, x, y - 75, 0, -1, 1)
        end
        if self.right_part then
            gfx.draw(self.right_part, x, y - 75)
        end
    end
    gfx.setColor(1, 1, 1)
    self.blur(draw_fog)
end

function blast:__monitor_particles(on_done)
    local l, r = self.left_part, self.right_part
    local dt = self:wait_update()
    l:update(dt)
    r:update(dt)
    l:stop()
    r:stop()

    repeat
        local dt = self:wait_update()
        l:update(dt)
        r:update(dt)
    until l:getCount() == 0 and r:getCount() == 0

    return on_done()
end

function blast:animation()
    self.left_part = self.__create_fog_particles()
    self.right_part = self.__create_fog_particles()
    self:fork(self.__monitor_particles, self.on_done)
    self:wait(self.on_done)
    self:destroy()
end

return blast
