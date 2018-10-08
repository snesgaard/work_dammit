local server = {}

function server:priority(id)
    self.__priority = id
    self.__draw_order = self:get_draw_order()
    return self
end

function server:get_draw_order()
    local sprites = visual.sprite

    local ids = list()

    for id, _ in pairs(sprites) do
        ids[#ids + 1] = id
    end

    return ids:sort(function(a, b)
        if a == self.__priority then
            return false
        elseif b == self.__priority then
            return true
        else
            local xa = nodes.position:get_world(a).x
            local xb = nodes.position:get_world(b).x
            return xa < xb
        end
    end)
end

function server:__draw()
    if self.__draw_order then
        for _, id in ipairs(self.__draw_order) do
            local s = visual.sprite[id]
            local pos = nodes.position:get_world(id)
            s:draw(pos:unpack())
        end
    else
        for id, s in pairs(visual.sprite) do
            local pos = nodes.position:get_world(id)
            s:draw(pos:unpack())
        end
    end
end

return server
