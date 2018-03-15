local List = require "list"

local Listener = {}
Listener.__index = Listener

function Listener.create(event, callback)
    return setmetatable({event = event, callback = callback}, Listener)
end

function Listener:__call(...)
    return self.callback(...)
end

function Listener:remove()
    self.event:remove(self)
end

local Event = {}
Event.__index = Event

function Event.create()
    return setmetatable({listeners = {}}, Event)
end

function Event:__call(...)
    for cb, _ in pairs(self.listeners) do
        cb(...)
    end
end

function Event:listen(callback)
    local listener = Listener.create(self, callback)
    self.listeners[listener] = true
    return listener
end

function Event:remove(listener)
    self.listeners[listener] = nil
end

return Event
