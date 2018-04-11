local Convoke = require "convoke"
local Event = require "event"

local Animation = {}
Animation.__index = Animation

function Animation.create(target, removal)
    local this = {
        __draw = target.draw,
        __removal = removal,
        on_finish = Event.create(),
        on_terminate = Event.create()
    }
    this = setmetatable(this, Animation)
    this.__convoke = Convoke(
        function(...)
            if target.animate then target.animate(...) end
            this:remove()
        end
    )
    return this
end

function Animation:run(...)
    self.__convoke(self, ...)
end

function Animation:update(dt)
    self.__convoke:update(dt)
end

function Animation:draw(...)
    if self.__draw then self.__draw(self, ...) end
end

function Animation:remove()
    if self.__removal then
        self.__removal(self)
        return self.on_terminate()
    end
end

local Server = {__default_group = Dictionary.create()}
Server.__index = Server

function Server.animate(target, group)
    group = group or Server.__default_group
    local function removal(anime)
        Server.remove(anime, group)
    end
    local anime = Animation.create(target, removal)
    group[anime] = true
    return anime
end

function Server.update(dt, group)
    group = group or Server.__default_group
    for anime, _ in pairs(group) do
        anime:update(dt)
    end
    return self
end

function Server.remove(target, group)
    group = group or Server.__default_group
    group[target] = nil
end

function Server.draw(group)
    group = group or Server.__default_group
    for anime, _ in pairs(group) do
        anime:draw()
    end
end

return Server
