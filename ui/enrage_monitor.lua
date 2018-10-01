local mark = {}

function mark:create(im)
    self.im = im
    self.color = {1, 0.3, 0.2, 0}
    self.pos = vec2(0, 50)
    self:fork(self.__life)
end

function mark:__life()
    local tween = Timer.tween(
        0.10,
        {
            [self.pos] = {x = 0, y = 0},
            [self.color] = {[4] = 1}
        }
    )
    self:wait(tween)
    self:wait(0.75)
    for i = 1, 4 do
        self.color[4] = 1
        self:wait(0.1)
        self.color[4] = 0
        self:wait(0.1)
    end
end

function mark:__draw(x, y)
    gfx.setColor(unpack(self.color))
    gfx.draw(self.im, x + self.pos.x, y + self.pos.y, 0, 2, 2)
end


local server = {}

function server:create()
    self.im = gfx.newImage("art/mark.png")
end

function server:enrage(id)
    local pos = nodes.position:get_world(id) or vec2(0, 0)

    local n = self:child(mark, self.im)
    local o = visual.ui_offset[id] or 0
    n.__transform.pos = pos - vec2(100, 225 + o)
    return self
end

function server:test()
    self:enrage("foo")
end

return server
