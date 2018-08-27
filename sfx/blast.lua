local ease = require "ease"

local beam = {}

function beam:create()
    self.amp_width = 7
    self.base_width = -self.amp_width
    self.freq_width = 75
    self.time = 0
    self:set_color(1, 1, 1)
end

function beam:set_color(...)
    self.color = {...}
    return self
end

function beam:__update(dt)
    self.time = self.time + dt
end

function beam:appear()
    local function do_appear(self)
        local time = 0.35
        local tween = Timer.tween(
            time,
            {
                [self] = {base_width = 10}
            }
        )
        self:wait(tween)
    end

    self:fork(do_appear)
end

function beam:hide()
    local function do_hide(self)
        local tween = Timer.tween(
            0.25,
            {
                [self] = {base_width = self.base_width + 20}
            }
        ):ease(ease.inQuad)

        self:wait(tween)

        local tween = Timer.tween(
            0.15,
            {
                [self] = {base_width = -self.amp_width}
            }
        ):ease(ease.inBounce)
        self:wait(tween)

        --self.on_hidden()
    end

    self:fork(do_hide)
end

function beam:get_width()
    local a, f = self.amp_width, self.freq_width
    return math.max(0, self.base_width + math.sin(self.time * f) * a)
end

function beam:__draw(x, y)
    x = (x or 0)
    y = (y or 0) - 1000
    local w = self:get_width()
    local h = 1000
    local function do_draw(x, y, w, h)
        gfx.rectangle("fill", x - w * 0.5, y, w, h)
    end

    gfx.setColor(unpack(self.color))
    do_draw(x, y, w * 2, h)
    gfx.setColor(1, 1, 1)
    do_draw(x, y, w, h)
end

local dot = {}

function dot:create()
    self.amp_radius = 5
    self.dc_radius = -self.amp_radius
    self.freq_radius = 50
    self.time = 0

    self:set_color(1, 1, 1)

    self.on_appear = event()
    self.on_hidden = event()
end

function dot:__update(dt)
    self.time = self.time + dt
end

function dot:appear()
    local function do_appear()
        local time = 0.75
        local tween = Timer.tween(
            time,
            {
                [self] = {dc_radius = 25}
            }
        ):ease(ease.outQuad)
        self:wait(tween)
        self.on_appear()
    end

    self:fork(do_appear)
end

function dot:hide()
    local function do_hide()
        local etween = Timer.tween(
            0.25,
            {
                [self] = {dc_radius = self.dc_radius + 20}
            }
        ):ease(ease.inQuad)

        self:wait(etween)

        local itween = Timer.tween(
            0.15,
            {
                [self] = {dc_radius = -self.amp_radius}
            }
        ):ease(ease.inBounce)
        self:wait(itween)

        self.on_hidden()
    end

    self:fork(do_hide)
end

function dot:get_radius()
    local a, f = self.amp_radius, self.freq_radius
    return math.max(0, self.dc_radius + math.sin(self.time * f) * a)
end

function dot:set_color(...)
    self.color = {...}
    return self
end

function dot:__draw(x, y, inner)
    x = (x or 0)
    y = (y or 0)
    local r = self:get_radius()

    local function do_draw(r)
        gfx.circle("fill", x, y, r, 30)
    end

    if inner then
        gfx.setColor(1, 1, 1)
        do_draw(r)
    else
        gfx.setColor(unpack(self.color))
        do_draw(r * 2)
    end

end

local blast = {}

function blast:create(pos)
    local moon = require "modules/moonshine"
    self.blur = moon(moon.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 2.5

    self.beam = self:child(beam):set_color(1, 0.7, 0.2)
    self.beam:appear()

    self.dot = self:child(dot):set_color(1, 0.7, 0.2)
    self.dot:appear()

    self:fork(self.animation)

    self.on_blast = event()
    self.on_done = event()
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

        self.dot:draw(0, 0, 0, 1, 1, false)
        self.beam:draw()
        self.dot:draw(0, 0, 0, 1, 1, true)
    end
    gfx.setColor(1, 1, 1)
    self.blur(draw_fog)
end

function blast:__childdraw() end

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
    self:wait(self.dot.on_appear)
    self:wait(0.15)
    self.dot:hide()
    self.beam:hide()
    self:wait(self.dot.on_hidden)
    self.left_part = self.__create_fog_particles()
    self.right_part = self.__create_fog_particles()
    self.on_blast()
    self:fork(self.__monitor_particles, self.on_done)
    self:wait(self.on_done)
end

return blast
