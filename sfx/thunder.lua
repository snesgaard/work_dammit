local Moonshine = require "modules/moonshine"
local particles = require "sfx/particles"

local thunder = {}

local rng = love.math.random

function thunder:create(arg)
    arg = arg or {}
    self.start = arg.start or vec2(0, -400)
    self.stop = arg.stop or vec2(0, 0)
    self.detail = 5
    self.blur = Moonshine(Moonshine.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 1.5
    self.seed = love.timer.getTime()
    self.sparks = particles{
        image = "art/part2.png",
        buffer = 50,
        rate = 30,
        dir = -math.pi * 0.5,
        lifetime = 0.5,
        acceleration = {0, 500},
        size = 0.5,
        speed = 500,
        area = {"uniform", 5, 0, math.pi},
        color = {
            1.0, 1.0, 0.6, 1,
            1.0, 1.0, 0.6, 1,
            1.0, 1.0, 0.6, 1,
            1.0, 1.0, 0.6, 0
        },
        spread = math.pi,
        relative_rotation = true,
        rotation = math.pi * 0.5
    }
    self:fork(self.life)
end

function thunder:__update(dt)
    self.seed = self.seed + dt
    self.sparks:update(dt)

    if self.terminate and self.sparks:getCount() == 0 then
        self:destroy()
    end
end

function thunder:life()
    self:wait(0.6)
    self:halt()
end

function thunder:halt()
    self.terminate = true
    self.sparks:stop()
end

local function do_draw(self, x1, y1, x2, y2, d, thicc)
    if d < self.detail then
        gfx.circle("fill", x1, y1, thicc * 0.5)
        gfx.line(x1, y1, x2, y2)
    else
        local mx = (x1 + x2) * 0.5
        local my = (y1 + y2) * 0.5
        mx = mx + (rng() - 0.5) * d
        my = my + (rng() - 0.5) * d
        do_draw(self, x1, y1, mx, my, d * 0.5, thicc)
        do_draw(self, x2, y2, mx, my, d * 0.5, thicc)
    end
end

function thunder:__draw(x, y)
    x = x or 0
    y = y or 0
    local x1, y1 = (self.start + vec2(x, y)):unpack()
    local x2, y2 = (self.stop + vec2(x, y)):unpack()
    local seed = self.seed * 40
    local s = math.remap(math.cos(self.seed * 30), -1, 1, 0.75, 1.3)

    local function f(thicc, c)
        love.math.setRandomSeed(seed)
        gfx.setLineWidth(thicc * s)
        do_draw(self, x1, y1, x2, y2, 125, thicc)
        gfx.circle("fill", x1, y1, c * s, 10)
        gfx.circle("fill", x2, y2, c * s, 10)
    end

    local function draw_all()
        gfx.setColor(200 / 255.0, 50 / 255.0, 255 / 255.0)
        f(12, 10)
        gfx.setColor(255, 255, 255)
        f(4, 6)
    end
    gfx.setColor(255, 255, 255)
    if not self.terminate then
        self.blur.draw(draw_all)
    end
    gfx.setColor(255, 255, 255)
    gfx.draw(self.sparks, x2, y2)
end

function thunder:set_pos(pos)
    self.start = pos + vec2(0, -400)
    self.stop = pos
end

return thunder
