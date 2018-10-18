local server = {}

function server:create()
    self.__minions = {}
    self.__callbacks = {}
end

function server:set(id, type, ...)
    if self.__minions[id] then
        self.__minions[id]:destroy()

        local callbacks = self:__get_callbacks(id)
        for action, cb in pairs(callbacks) do
            cb:remove()
            callbacks[action] = nil
        end
    end
    if type then
        local m = self:child(type, self, id, ...)
        local index = nodes.position:get(id)
        local pos = nodes.position:get_world(id) or vec2(0, 0)
        if index then
            if index > 0 then
                pos = pos - vec2(50, 0)
            else
                pos = pos + vec2(50, 0)
            end
        end
        local o = visual.ui_offset[id] or 0
        m.__transform.pos = pos - vec2(0, 0)
        self.__minions[id] = m

        if m.entry then m:entry() end
    end
end

function server:__get_callbacks(id)
    self.__callbacks[id] = self.__callbacks[id] or dict()
    return self.__callbacks[id]
end

function server:on_turn_begin(id, action)
    local cb = self:__get_callbacks(id)

    local function callback(i, actor)
        if actor ~= id then return end

        nodes.animation:add(action, self.__minions[id], id)
    end

    cb[action] = nodes.round_planner.on_turn_begin:listen(callback)
end

function server:on_turn_end(id, action)
    local cb = self:__get_callbacks(id)

    local function callback(i, actor)
        if actor ~= id then return end

        nodes.animation:add(action, self.__minions[id], id)
    end

    cb.on_turn_end = nodes.round_planner.on_turn_end:listen(callback)
end

function server:on_round_begin(id, action)

end

function server:on_round_end(id, action)

end

return server
