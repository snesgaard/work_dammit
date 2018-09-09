local ease = require "ease"
local Moonshine = require "modules/moonshine"

local entry_particle = {}

local THEME = {
    blue = {
        low = {0.2, 0.2, 1},
        mid = {0.5, 0.5, 1},
        high = {0.8, 0.8, 1},
    },
    red = {
        low = {1, 0.2, 0.2},
        mid = {1, 0.5, 0.5},
        high = {1, 0.8, 0.8},
    }
}

function entry_particle:create(theme)
    self.radius = 300
    self.angle = -math.pi * 0.5
    self.theme = theme or THEME.red

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
    local t = self.theme.low
    gfx.setColor(t[1], t[2], t[3], 0.7)
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

function pulse:create(theme)
    self.time = 0
    self.radius = 5
    self.theme = theme or THEME.red
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
        local t = self.theme.low
        gfx.setColor(t[1], t[2], t[3], 0.5)
        gfx.circle("fill", x, y, r + 30)
        local t = self.theme.mid
        gfx.setColor(t[1], t[2], t[3], 0.5)
        gfx.circle("fill", x, y, r)
        local t = self.theme.high
        gfx.setColor(t[1], t[2], t[3], 0.5)
        gfx.circle("fill", x, y, r - 30)
    end
    self.blur(__draw)
end

local cast = {}

function cast:create(id, theme)
    theme = theme or "red"
    self.theme = THEME[theme]
    if not theme then
        log.error("Theme %s not defined", theme)
        return
    end
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
    self.entry = self:child(entry_particle, self.theme)
    self:wait(self.entry.on_finish)
    self.pulse = self:child(pulse, self.theme)
    self:wait(self.pulse.on_finish)
    self.on_finish()
    self:destroy()
end

return cast
