local position = {}
position.__index = position


function position.create(this, center)
    this.actors = Dictionary.create()
    this.placements = Dictionary.create()
    this.center = center or vec2(800, 704)
    return setmetatable(this, position)
end


function position:get(id)
    if type(id) == "number" then
        return self.placements[id]
    else
        return self.actors[id]
    end
end


function position:pairget(arg)
    if type(arg) == "number" then
        return self.placements[arg], arg
    else
        return arg, self.actors[arg]
    end
end


function position:set(id, place)
    if self.placements[place] then
        log.warn("Place %i was already taken", place)
    end

    local prev_place = self.actors[id]
    if prev_place then
        self.placements[prev_place] = nil
    end

    self.placements[place] = id
    self.actors[id] = place
end


function position:remove(arg)
    local id, place = self:pairget(arg)

    if id and place then
        self.placements[place] = nil
        self.actors[id] = nil
    end
end


function position:swap(arg1, arg2)
    local id1, place1 = self:pairget(arg1)
    local id2, place2 = self:pairget(arg2)

    if not id1 or not place1 or not id2 or not place2 then
        log.warn("Unknown pair %s %s", tostring(arg1), tostring(arg2))
        log.warn(
            "Details %s/%s  %s/%s", tostring(id1), tostring(place1),
            tostring(id2), tostring(place2)
        )
        return false
    end

    self:remove(id1)
    self:remove(id2)
    self:set(id1, place2)
    self:set(id2, place1)
    return true
end

function position:get_world(arg)
    local _, place = self:pairget(arg)
    if not place then return end
    local offset = vec2(-150 * place, 0)
    return self.center + offset
end

return position
