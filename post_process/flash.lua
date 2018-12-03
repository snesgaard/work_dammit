
local ease = require "ease"
local post = {}

function post:create(duration)
    self.duration = duration or 0.1
    self.color = {1, 1, 1, 1}

    self:fork(self.life)
end

function post:life()
    local tween = Timer.tween(
        self.duration,
        {
            [self.color] = {[4] = 0}
        }
    ):ease(ease.inOutSine)
    self:wait(tween)
    self:destroy()
end

function post:draw(buffer, x, y)
    gfx.draw(buffer, x, y)
    gfx.setColor(unpack(self.color))
    gfx.rectangle("fill", x, y, gfx.getWidth(), gfx.getHeight())
end

return post
