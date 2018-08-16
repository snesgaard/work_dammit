local font = require "ui/fonts"

local stat_up = {}

function stat_up:test()
    local im = gfx.newImage("art/armor.png")
    self:set_im(im)
        :set_value(5)
end


local function draw_up_arrow(x,  y)
    gfx.rectangle("fill", x, y + 11, 4, 25)
    local tx = x + 2
    gfx.polygon(
        "fill",
        tx - 7, y + 16,
        tx + 7, y + 16,
        tx, y
    )
end

local function draw_down_arrow(x, y)
    gfx.rectangle("fill", x, y, 4, 25)
    local tx = x + 2
    ty = y + 25
    gfx.polygon(
        "fill",
        tx - 7, ty,
        tx + 7, ty,
        tx, ty + 16
    )
end

function stat_up:create(buff)
    self.origin = vec2(0, 0)
    self.color = {
        im = {0, 0, 0, 0},
        arrow = {0, 0, 0, 0},
    }
    if buff then
        self.end_color = {1, 0.5, 0.2, 1}
        self.pos = vec2(0, 0)
        self.end_pos = vec2(0, -150)
        self.arrow_draw = draw_up_arrow
    else
        self.end_color = {0.5, 0.2, 1, 1}
        self.pos = vec2(0, -150)
        self.end_pos = vec2(0, 0)
        self.arrow_draw = draw_down_arrow
    end
    self.font = font(20)
    self.value = nil
    self:fork(self.life)
end

function stat_up:life()
    local ts = 0.8
    local color_tween = Timer.tween(
        0.3 * ts,
        {
            [self.color.im] = self.end_color
        }
    )
    local motion_tween = Timer.tween(
        1.0 * ts,
        {
            [self.pos] = self.end_pos
        }
    )
    self:wait(color_tween)
    self:wait(0.4 * ts)
    local color_tween = Timer.tween(
        0.3 * ts,
        {
            [self.color.im] = {0, 0, 0, 0}
        }
    )
    self:wait(color_tween)
    self:destroy()
end

function stat_up:set_im(im)
    self.im = im
    return self
end

function stat_up:set_origin(p)
    self.origin = p
    return self
end

function stat_up:set_value(value)
    self.value = value
    return self
end

function stat_up:__draw(x, y)
    x = (x or 0) + self.origin.x + self.pos.x
    y = (y or 0) + self.origin.y + self.pos.y
    gfx.setColor(unpack(self.color.im))
    if self.im then
        gfx.draw(self.im, x + 15, y - 3, 0, 1.5, 1.5)
    end
    self.arrow_draw(x - 5, y - 6)

    if self.value then
        gfx.setFont(self.font)
        gfx.print(self.value, x - 30, y - 4)
    end
end

return stat_up
