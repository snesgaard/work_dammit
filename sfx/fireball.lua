local particles = require "sfx.particles"
local sfx = {}

function sfx:create()
    local circles = gfx.prerender(52, 52, function(w, h)
        gfx.setColor(1, 1, 1)
        gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
    end)

    self.particles = {
        particles{
            image=circles,
            buffer=20,
            emit=20,
            stop=true,
            lifetime=1.0,
            color=List.concat(
                gfx.hex2color("9d758d3f"),
                gfx.hex2color("6d758d00")
            ),
            speed={50, 100},
            spread=math.pi * 2,
            acceleration={0, -300}
        },
        particles{
            image=circles,
            buffer=40,
            emit=40,
            stop=true,
            rate=200,
            lifetime=0.5,
            color=List.concat(
                gfx.hex2color("ffd541cf"),
                gfx.hex2color("f9a31baf"),
                gfx.hex2color("fa6a0a4f"),
                gfx.hex2color("df3e2300")
            ),
            size=0.5,
            stop=true,
            speed={150, 300},
            damp = 0,
            spread=math.pi * 2,
            acceleration = {0, -200}
        },
        particles{
            image=circles,
            buffer=40,
            emit=40,
            stop=true,
            rate=200,
            lifetime={0.5, 1},
            color=List.concat(
                gfx.hex2color("ffd541cf"),
                gfx.hex2color("f9a31baf"),
                gfx.hex2color("fa6a0a0f"),
                gfx.hex2color("df3e2300")
            ),
            size=0.25,
            stop=true,
            speed={100, 400},
            damp = 1,
            spread=math.pi * 2,
            acceleration = {0, -500}
        },
        particles{
            image=circles,
            buffer=40,
            emit=40,
            stop=true,
            lifetime=1,
            color=List.concat(
                gfx.hex2color("df3e23cf"),
                gfx.hex2color("6d758d00")
            ),
            size=0.1,
            speed={100, 200},
            spread=math.pi * 2
        },
        particles{
            image=circles,
            buffer=1,
            emit=1,
            lifetime=0.25,
            color={1, 1, 1, 1, 1, 1, 1, 0},
            size=4,
            stop=true
        },
    }

    self:fork(self.life)
end

function sfx:life()
    local function is_done()
        for _, p in pairs(self.particles) do
            if p:getCount() ~= 0 then
                return false
            end
        end
        return true
    end

    while not is_done() do
        self:wait_update()
    end

    self:destroy()
end

function sfx:__update(dt)
    for _, p in ipairs(self.particles) do p:update(dt) end
end

function sfx:__draw(x, y)
    for _, p in ipairs(self.particles) do
        gfx.draw(p, x, y)
    end
end

return sfx
