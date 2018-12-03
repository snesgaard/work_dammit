local sfx = {}

function sfx:create()
    self.pos = vec2(0, 0)
    self.scale = 0.2
    self.size = vec2(20, 100)
    self.color = list(0.8, 0.8, 1, 1)
    self.width = 5

    self.on_finish = event()

    self:fork(self.life)
end

function sfx:life()
    local tween = Timer.tween(
        0.35,
        {
            [self] = {scale = 2, pos = vec2(200, 0)},
            [self.color] = {[4] = 0}
        }
    )
    self:wait(tween)
    self.on_finish()
end

function sfx:__draw()
    gfx.setColor(unpack(self.color))
    gfx.setLineWidth(self.width)
    gfx.ellipse(
        "line", self.pos.x, self.pos.y, self.size.x * self.scale,
        self.size.y * self.scale
    )
end

return sfx
