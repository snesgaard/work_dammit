local particles = require "sfx.particles"
local sfx = {}

function sfx:create()
    local circles = gfx.prerender(26, 40, function(w, h)
        gfx.setColor(1, 1, 1)
        gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
    end)

    self.particles = {
        particles{
            image=circles,
            buffer=20,
            rate=10,
            lifetime={0.5},
            color=List.concat(
                gfx.hex2color("a6fcdbdf"),
                gfx.hex2color("249fdebf"),
                gfx.hex2color("285cc400")
            ),
            size = {1, 8}
        }
    }
end

function sfx:stop()
    for _, p in pairs(self.particles) do
        p:stop()
    end

    self:fork(self.monitor_halt)
end

function sfx:monitor_halt()
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
