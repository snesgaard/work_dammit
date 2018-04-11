local Convoke = require "convoke"

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
    if self.__convoke then
        self.__convoke:update(...)
    end
    return self
end

function FiniteStateMachine:keypressed(...)
    if self.state and self.state.keypressed then
        self.state.keypressed(self, ...)
    end
    return self
end

function FiniteStateMachine:keyreleased(...)
    if self.state and self.state.keyreleased then
        self.state.keyreleased(self, ...)
    end
    return self
end

function FiniteStateMachine:draw(...)
    if self.state and self.state.draw then
        self.state.draw(self, ...)
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
    if self.__convoke then
        self.__convoke:terminate()
        self.__convoke = nil
    end
    self.__workspace = {}
    self.state_key = key
    self.state = NextState
    if self.state.begin then
        self.state.begin(self, ...)
    end
    if self.state.convoke then
        self.__convoke = Convoke(self.state.convoke)
        self.__convoke(self, ...)
    end
    return self
end


return FiniteStateMachine
