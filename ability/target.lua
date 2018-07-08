local marker = {}
marker.__index = marker

function marker:create()
    self.pos = vec2(0, 0)
end


function marker:draw(x, y)
    local w, h = 10, 10
    local x, y = self.pos.x, self.pos.y
    gfx.setColor(0, 0, 255)
    gfx.rectangle("fill", x - w / 2, y - h / 2, w, h)
end

local target = {}

function target.remove_self(user)
    return function(index, id)
        return user ~= id
    end
end

function target.same_side(user)
    local side = nodes.position:get(user)
    return function(index, id)
        return index * side > 0
    end
end

function target.opposite_side(user)
    local side = nodes.position:get(user)
    return function(index, id)
        return index * side < 0
    end
end

function target.is_alive()
    return function(index, id)
        return nodes.game:is_alive(id)
    end
end

function target.is_dead()
    return function(index, id)
        return not nodes.game:is_alive(id)
    end
end


target.single = {}

function target.single.create(self, targets)
    kwargs = kwargs or {}
    self.user = user
    -- The fitler statement below both serves to potentially filter the user
    -- and create a copy of the placement dictionary
    self.targets = targets

    self.marker = process.create(marker)

    self.on_select = Event.create()
    self.on_abort = Event.create()

    self:set_target(1)

    self:fork(self.control)
end

function target.single.control(self)
    local key = self:wait(nodes.root.keypressed)

    if key == "left" then
        self:set_target(self.current - 1)
    elseif key == "right" then
        self:set_target(self.current + 1)
    elseif key == "space" then
        self.on_select(self.targets[self.current])
    elseif key == "backspace" then
        self.on_abort()
    end

    if self.alive then
        return target.single.control(self)
    end
end

function target.single.set_target(self, index)
    self.current = math.cycle(index, 1, self.targets:size())
    local pos = nodes.position:get_world(self.targets[self.current])
    self.marker.pos = pos - vec2(0, 75)
end


function target:draw()
    self.marker:draw()
end

target.single.draw = target.draw

return target
