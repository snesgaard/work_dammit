local particles = require "sfx.particles"
local moon = require "modules.moonshine"
local ease = require "ease"
local sfx = {}

function sfx:create(arg)
    arg = arg or {}
    local circles = gfx.prerender(300, 300, function(w, h)
        gfx.stencil(function()
            gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.47, h * 0.6)
            gfx.rectangle("fill", 0, 0, w * 0.5, h)
        end, "replace", 1)
        gfx.setStencilTest("equal", 0)
        gfx.setColor(1, 1, 1)
        gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
        gfx.setStencilTest()
    end)

    local function create_particle(size)
        return particles{
            image=circles,
            buffer=40,
            rate=5,
            lifetime=1.0,
            rotation={0, math.pi*2},
            color = {
                0.5, 0.7, 1.0, 0.0,
                0.5, 0.7, 1.0, 0.6,
                0.5, 0.7, 1.0, 0.0,
            },
            size={size},
            spin={ math.pi * 2}
        }
    end

    self.blur = moon(moon.effects.gaussianblur)
    self.blur.gaussianblur.sigma = arg.blur or 5.5

    self.particles = {}

    for i = 1,10 do
        self.particles[i] = create_particle(i * 0.03 + 0.5)
    end

    self.scale = 1

    self:fork(self.life)
end

function sfx:life()
    self:wait(1.5)
    self:wait(
        Timer.tween(
            0.3,
            {
                [self] = {scale=1.2}
            }
        )
    )
    local tween = Timer.tween(
        0.1,
        {
            [self] = {scale=0}
        }
    )
    self:wait(tween)
end


function sfx:__update(dt)
    for _, p in ipairs(self.particles) do
        p:update(dt)
    end
end

function sfx:__draw(x, y)
    gfx.setBlendMode("alpha")
    self.blur.draw(function()
        for _, p in ipairs(self.particles) do
            gfx.draw(p, x, y, 0, self.scale, self.scale)
        end
    end)
    gfx.setBlendMode("add")
    gfx.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        gfx.draw(p, x, y, 0, self.scale, self.scale)
    end
    gfx.setBlendMode("alpha")
end

return sfx
