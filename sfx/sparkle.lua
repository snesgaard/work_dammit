local particles = require "sfx/particles"

local sparkle = {}

function sparkle.create(self)
    self.particles = list()
    self.particles[1] = particles{
        image = "art/part.png",
        buffer = 100,
        move = {0, 50},
        lifetime = 0.75,
        rate = 75,
        area = {"uniform", 50, 100},
        size = 0.35,
        speed = 75,
        dir = -math.pi * 0.5,
        damp = {0.5, 0.5},
        color = {
            50 / 255.0, 255 / 255.0, 50 / 255.0, 0,
            50 / 255.0, 255 / 255.0, 50 / 255.0, 255 / 255.0,
            50 / 255.0, 255 / 255.0, 50 / 255.0, 255 / 255.0,
            0, 0, 0, 0
        }
    }
    self.particles[2] = particles{
        image = "art/part2.png",
        buffer = 100,
        move = {0, 30},
        lifetime = 0.75,
        rate = 35,
        area = {"uniform", 50, 100},
        size = 0.5,
        speed = 250,
        dir = -math.pi * 0.5,
        damp = {0.25, 0.25},
        color = {
            150 / 255.0, 255 / 255.0, 150 / 255.0, 0 / 255.0,
            150 / 255.0, 255 / 255.0, 150 / 255.0, 255 / 255.0,
            150 / 255.0, 255 / 255.0, 150 / 255.0, 255 / 255.0,
            0, 0, 0, 0
        }
    }

    self.circle = dict{
        color = list(50 / 255.0, 255 / 255.0, 50 / 255.0, 255 / 255.0),
        radius = 0,
        width = 3
    }
    self.pos = vec2(0, 0)
    self:fork(self.life)
end

function sparkle:__update(dt)
    for _, p in ipairs(self.particles) do
        p:update(dt)
    end
    if self.terminate then
        self:terminate()
    end
end

function sparkle:__draw()
    gfx.setColor(255, 255, 255)
    local x, y = self.pos:unpack()
    for _, p in ipairs(self.particles) do
        gfx.draw(p, x, y)
    end
    gfx.setColor(self.circle.color:unpack())
    gfx.setLineWidth(self.circle.width)
    gfx.circle(
        "line", x, y, self.circle.radius, 30
    )
end

function sparkle:set_pos(pos)
    self.pos = pos
    return self
end

function sparkle:life()
    local tween = Timer.tween(
        0.5,
        {
            [self.circle] = {radius = 300, width = 16},
            [self.circle.color] = {[4] = 0}
        }
    )
    self:wait(tween, 0.4)
    for _, p in pairs(self.particles) do
        p:stop()
    end
    function self:terminate()
        local do_stop = self.particles
            :map(function(p)
                return p:getCount() == 0
            end)
            :reduce(function(a, b)
                return a and b
            end)
        if do_stop then
            self:destroy()
        end
    end
end

return sparkle
