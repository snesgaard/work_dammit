local Node = {}
Node.__index = Node


function Node.create(f, ...)
    local this = {
        __group = {
            tween = {},
            thread = {},
            event = {},
        },
        __cleaners = {}
    }
    if type(f) == "table" then
        setmetatable(f, {__index = Node})
        f.__index = f
        this = setmetatable(this, f)
        f.create(this, ...)
        --this.draw = f.draw
    else
        this = setmetatable(this, Node)
        f(this)
    end
    return this
end

function Node:destroy()
    for co, cleanup in pairs(self.__cleaners) do
        cleanup(true)
    end
    if self.on_destoyed then self.on_destoyed() end
end

function Node:update(dt)
    Timer.update(dt, self.__group.tween)
end

function Node:fork(f, ...)
    -- Insert a reference to self as first argument
    local co = coroutine.create(f)
    -- Maybe it is unnecessary to
    self.__group.thread[co] = true
    local status, msg = coroutine.resume(co, self, ...)
    if not status then
        log.error(msg)
    end
    return co
end

function Node:join(co)
    self.__group.thread[co] = nil
    cleanup = self.__cleaners[co]
    if cleanup then
        cleanup(true)
    end
end

function Node:set_state(state, ...)
    if not state then return self end

    if self.__state and self.__state.exit then
        self.__state.exit(self, state)
    end

    local prev_state = self.__state
    self.__state = state
    if state.enter then
        state.enter(self, prev_state, ...)
    end

    return self
end

function Node:wait(...)
    local events = {...}

    if #events == 0 then
        return
    end

    local co = coroutine.running()
    local listeners = {}

    -- Declare cleanup function, unsubs listeners and remove the cleanup
    local function cleanup(kill_tweens)
        self.__cleaners[co] = nil
        for e, l in pairs(listeners) do
            if istype(Event, e) or type(e) == "number" then
                l:remove()
            -- If it is a tween, simply remove the finish field
            else
                e.finishField = nil
                -- If this is called by threadjion, we want to stop the tween
                if kill_tweens then
                    e:remove()
                end
            end
        end
    end
    -- Cache cleanup in case we need to destory the node later
    self.__cleaners[co] = cleanup
    -- Declare continuation called
    local function continuation(e, ...)
        local args = {event = e, ...}
        cleanup()
        local status, msg
        if #events > 1 then
            status, msg = coroutine.resume(co, args)
        else
            status, msg = coroutine.resume(co, ...)
        end
        if not status then
            log.error(msg)
        end
    end

    for _, e in ipairs(events) do
        local function callback(...)
            continuation(e, ...)
        end
        -- If it is a number we assume a temporal wait in seconds
        if type(e) == "number" then
            local function timeout()
                continuation("timeout")
            end
            listeners[e] = Timer.after(e, timeout)
                :remove()
                :group(self.__group.tween)
        -- Determine whether is a an event
        elseif e.listen then
            listeners[e] = e:listen(callback)
        -- or a tween
        elseif e.finish then
            e:remove():group(self.__group.tween)
            listeners[e] = e:finish(callback)
        end
    end

    return coroutine.yield()

end

return Node
