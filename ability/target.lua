local marker_sfx = require "sfx/marker"

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

function target.remove_self(index, id, user)
    return user ~= id
end

function target.is_user(index, id, user)
    return id == user
end

function target.same_side(index, id, side)
    return index * side > 0
end

function target.opposite_side(index, id, side)
    return index * side < 0
end

function target.is_alive(id)
    return nodes.game:is_alive(id)
end

function target.is_dead(id)
    return not nodes.game:is_alive(id)
end

local function apply_condition(data, user)
    local condition = data.condition or function() return true end
    return function(index, id)
        return condition(index, id, user)
    end
end

function target.self(placement, data, user)
    return dict{
        primary = list(user)
    }
end

function target.single(placement, data, user)
    local user_side = nodes.position:get(user)

    return dict{
        primary = placement
            :filter(function(index, id)
                return data.primary(index, id, user_side)
            end)
            :filter(apply_condition(data, user))
            :values(),
        secondary = placement
            :filter(function(index, id)
                return not data.primary(index, id, user_side)
            end)
            :filter(apply_condition(data, user))
            :values(),
    }
end

function target.multiple(placement, data, user)
    local targets = target.single(placement, data, user)
    return dict{
        primary = list(targets.primary),
        secondary = list(targets.secondary),
    }
end

function target.all(placement, data, user)
    return dict{
        primary = list(
            placement
                :filter(apply_condition(data, user))
                :values()
        )
    }
end

function target.candidates(data, user)
    local placement = nodes.position.placements

    local method = target[data.type]

    if not method then
        log.warn("Target type %s not defined", data.type)
        return
    end

    return method(placement, data, user)
end

target.generic = {}
function target.generic.create(self, candidates)
    local function sort_by_pos(a, b)
        local p = nodes.position
        return p:get(a) > p:get(b)
    end

    self.__target_batches = {
        candidates.primary:sort(sort_by_pos),
        candidates.secondary and candidates.secondary:sort(sort_by_pos)
    }
    self.marker = process.create(marker_sfx)

    self.on_select = Event.create()
    self.on_abort = Event.create()
    self.on_change = Event.create()

    self:set_batch(1)

    self:fork(self.control)
end

function target.generic.__update(self, dt)
    self.marker:update(dt)
end

function target.generic.set_batch(self, batch)
    self.__batch = math.cycle(batch, 1, #self.__target_batches)
    self:set_target(1)
    return self
end

function target.generic.get_batch(self)
    return self.__target_batches[self.__batch]
end

function target.generic.set_target(self, target)
    local batch = self:get_batch()
    if target < 1 then
        self:set_batch(self.__batch + 1)
        return self:set_target(#self:get_batch())
    elseif target > #batch then
        return self:set_batch(self.__batch - 1)
    else
        self.__target = math.cycle(target, 1, #batch)
        self.on_change(self:get_target())
        self.marker:selection()
        return self
    end
end

function target.generic.get_target(self)
    local batch = self:get_batch()
    return batch[self.__target]
end

function target.generic.control(self)
    local key = self:wait(nodes.root.keypressed)

    if key == "left" then
        self:set_target(self.__target - 1)
    elseif key == "right" then
        self:set_target(self.__target + 1)
    elseif key == "tab" then
        self:set_batch(self.__batch + 1)
    elseif key == "space" then
        self.on_select(self:get_target())
    elseif key == "backspace" then
        self.on_abort()
    end

    if self.alive then
        return target.generic.control(self)
    end
end

function target.generic.__draw(self)
    local target = self:get_target()

    target = type(target) == "table" and target or {target}

    local function get_pos(id)
        return nodes.position:get_world(id) - vec2(0, 75)
    end

    local pos = {}

    for _, id in pairs(target) do
        local p = get_pos(id)
        pos[#pos + 1] = p.x
        pos[#pos + 1] = p.y
    end

    self.marker:mass_draw(unpack(pos))
end

return target
