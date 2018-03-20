local FiniteStateMachine = {}
FiniteStateMachine.__index = FiniteStateMachine

function FiniteStateMachine.__tostring(fsm)
    return string.format("FSM :: %s", sfm.state_key)
end

function FiniteStateMachine.create()
    return setmetatable({state_key = "none"}, FiniteStateMachine)
end

function FiniteStateMachine:register_state(key, State)
    if self.STATES[key] and State then
        log.warn('State [%s] was already registered', tostring(key))
    end
    self.STATES[key] = State
    return self
end

function FiniteStateMachine:update(...)
    if self.state and self.state.update then
        self.state.update(self, ...)
    end
    return self
end

function FiniteStateMachine:set_state(key, ...)
    local NextState = self.STATES[key]
    if not NextState then
        -- Log entry here
        return
    end
    if self.state and self.state.exit then
        self.state.exit(self)
    end
    self.__workspace = {}
    self.state_key = key
    self.state = NextState
    if self.state.begin then
        self.state.begin(self)
    end
    return self
end

return FiniteStateMachine
