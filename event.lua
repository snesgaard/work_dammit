local math = require "math"
local List = require "list"

local Listener = {}
Listener.__index = Listener

function Listener.create(event, callback)
    local this = {
        event = event, callback = callback, count = 0, limit = math.huge
    }
    return setmetatable(this, Listener)
end

function Listener:take(limit)
    self.limit = limit
    return self
end

function Listener:__call(...)
    self.count = self.count + 1
    -- HACK ENSURE THAT OUTER CALLBACK LOOP DOES NOT SKIP DUE TO THIS REMOVAL
    if self.count >= self.limit then self:remove() end
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
