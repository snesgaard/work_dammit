local moon = require "modules/moonshine"

local sfx = {}

function sfx:create(arg)
    arg = arg or {}
    self.start = arg.start or vec2(0, -400)
    self.stop = arg.stop or vec2(0, 0)
    self.detail = 10
    self.amp = 1.5
    self.seed = love.timer.getTime()
    self.thicc = arg.thicc or 20
    self.color = arg.color or {0.8, 0.7, 0.4}
    self.opacity = 1
    self.blur = moon(moon.effects.gaussianblur)
    self.blur.gaussianblur.sigma = arg.blur or 3.5

    self:fork(self.life)
end

function sfx:life()
    self:wait(0.1)
    local tween = Timer.tween(
        0.5,
        {
            [self] = {opacity = 0}
        }
    )
    self:wait(tween)
    self:destroy()
end

function sfx:__draw(x, y)
    x = x or 0
    y = y or 0
    local x1, y1 = (self.start + vec2(x, y)):unpack()
    local x2, y2 = (self.stop + vec2(x, y)):unpack()
    local seed = self.seed * 40
    local s = math.remap(math.cos(self.seed * 30), -1, 1, 0.75, 1.3)

    local function do_draw(self, x1, y1, x2, y2, d, thicc)
        if d < self.detail then
            gfx.circle("fill", x1, y1, thicc * 0.5)
            gfx.circle("fill", x2, y2, thicc * 0.5)
            gfx.line(x1, y1, x2, y2)
        else
            local mx = (x1 + x2) * 0.5
            local my = (y1 + y2) * 0.5
            mx = mx + (rng() - 0.5) * d * self.amp
            my = my + (rng() - 0.5) * d * self.amp
            do_draw(self, x1, y1, mx, my, d * 0.5, thicc)
            do_draw(self, x2, y2, mx, my, d * 0.5, thicc)
        end
    end

    local function f(thicc, c)
        love.math.setRandomSeed(seed)
        gfx.setLineWidth(thicc * s)
        do_draw(self, x1, y1, x2, y2, 125, thicc)
        gfx.circle("fill", x1, y1, c * s, 10)
        gfx.circle("fill", x2, y2, c * s, 10)
    end

    local function draw_all()
        gfx.setLineStyle("smooth")
        gfx.stencil(function()
            f(self.thicc, 10)
        end, "replace", 1)
        gfx.stencil(function()
            f(self.thicc* 0.2, 6)
        end, "replace", 2, true)



        gfx.push()
        gfx.origin()

        gfx.setStencilTest("equal", 1)
        gfx.setColor(self.color[1], self.color[2], self.color[3], self.opacity)
        gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())

        gfx.setStencilTest("equal", 2)
        gfx.setColor(1, 1, 1, self.opacity)
        gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())

        gfx.pop()

        gfx.setStencilTest()

        --gfx.setColor(255, 255, 255, self.opacity)
        --f(self.thicc * 0.2, 6)
    end
    gfx.setColor(255, 255, 255)
    self.blur.draw(draw_all)
    --draw_all()
end

return sfx
