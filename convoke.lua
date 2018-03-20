local Convoke = {}
Convoke.__index = Convoke

function Convoke.create(f)
    local this = {
        group = {},
        alive = true,
    }
    local function process(...)
        f(...)
        this.alive = true
    end
    this.process = coroutine.create(process)
    return setmetatable(this, Convoke)
end

for _, key in pairs({"after", "every", "prior", "tween"}) do
    Convoke[key] = function(self, ...)
        local f = Timer[key]
        return f(...):group(self.group)
    end
end

function Convoke:wait(arg)
    if type(arg) == "number" then
        return self:__wait_time(arg)
    elseif arg.finish then
        return self:__wait_tween(arg)
    elseif arg.listen then
        return self:__wait_event(arg)
    end
end

function Convoke:__wait_time(time)
    self:after(time, function()
        self:__resume()
    end)
    return coroutine.yield()
end

function Convoke:__wait_tween(tween)
    tween:finish(function() self:__resume() end)
    return coroutine.yield()
end

function Convoke:__wait_event(event)
    local listener = event:listen(function(...) self:__resume(...) end)
    local args = {coroutine.yield()}
    listener:remove()
    return unpack(args)
end

function Convoke:terminate()
    if not self.alive then return end
    self.alive = false
    Timer.clear(self.group)
end

function Convoke:__resume(...)
    if not self.alive then return end
    local status, msg = coroutine.resume(self.process, ...)
    if not status then
        log.error(msg)
    end
end

function Convoke:__call(...)
    return self:__resume(self, ...)
end

function Convoke:update(dt)
    if not self.alive then return end
    Timer.update(dt, self.group)
end

return function(...)
    return Convoke.create(...)
end
