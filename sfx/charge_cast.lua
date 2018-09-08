local ease = require "ease"
local Moonshine = require "modules/moonshine"

local entry_particle = {}

function entry_particle:create()
    self.radius = 300
    self.angle = -math.pi * 0.5

    self:fork(self.life)
    self.on_finish = event()
end

function entry_particle:life()
    local tween = Timer.tween(
        0.6,
        {
            [self] = {
                radius = 0,
                angle = math.pi * 4
            }
        }
    ):ease(ease.inQuad)
    self:wait(tween)
    self.on_finish()
    return self:destroy()
end

function entry_particle:__draw(x, y)
    x = x or 0
    y = y or 0
    gfx.setColor(1, 0.2, 0.2, 0.7)
    gfx.circle(
        "fill",
        x + math.cos(self.angle) * self.radius,
        y + math.sin(self.angle) * self.radius,
        5
    )
    gfx.circle(
        "fill",
        x + math.cos(self.angle - math.pi) * self.radius,
        y + math.sin(self.angle - math.pi) * self.radius,
        5
    )
end

local pulse = {}

function pulse:create()
    self.time = 0
    self.radius = 5
    self.blur = Moonshine(Moonshine.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 8.5
    self.on_finish = event()
    self:fork(self.life)
end

function pulse:__update(dt)
    self.time = self.time + dt
end

function pulse:life()
    local tween = Timer.tween(
        0.1,
        {
            [self] = {radius = 90}
        }
    )
    self:wait(tween)
    self:wait(0.25)
    local tween = Timer.tween(
        0.1,
        {
            [self] = {radius = 0}
        }
    )
    self:wait(tween)
    self:destroy()
    self.on_finish()
end

function pulse:__draw(x, y)
    x = x or 0
    y = y or 0
    local function __draw()
        local r = self.radius + math.sin(self.time * 75) * 5
        gfx.setColor(1, 0.2, 0.2, 0.5)
        gfx.circle("fill", x, y, r + 30)
        gfx.setColor(1, 0.5, 0.5, 0.5)
        gfx.circle("fill", x, y, r)
        gfx.setColor(1, 0.8, 0.8, 0.5)
        gfx.circle("fill", x, y, r - 30)
    end
    self.blur(__draw)
end

local cast = {}

function cast:create(id)
    self.pos = id and nodes.position:get_world(id) or vec2()
    self.on_finish = event()
    self:fork(self.life)
end

function cast:draw(x, y)
    x = (x or 0) + self.pos.x
    y = (y or 0) + self.pos.y - 75
    if self.entry then
        self.entry:draw(x, y)
    end
    gfx.setColor(1, 1, 1)
    if self.pulse then
        self.pulse:draw(x, y)
    end
end

function cast:life()
    self.entry = self:child(entry_particle)
    self:wait(self.entry.on_finish)
    self.pulse = self:child(pulse)
    self:wait(self.pulse.on_finish)
    self.on_finish()
    self:destroy()
end

return cast
