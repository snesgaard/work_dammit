local GameState = {}
GameState.__index = GameState

function GameState.__tostring(gs)
    return tostring(gs.__root)
end

function GameState.create()
    local this = {
        __root = Dictionary.create()
    }
    return setmetatable(this, GameState)
end

function GameState:set(path, value)
    local next_state = GameState.create()
    local path_parts = string.split(path, '/')
    local function __lookup(parent, key)
        return parent[key] or Dictionary.create()
    end
    local function __insert(value, dict_key)
        local dict, key = unpack(dict_key)
        return dict:set(key, value)
    end
    next_state.__root = path_parts:scan(__lookup, self.__root)
        :insert(self.__root, 1)
        :zip(path_parts)
        :reverse()
        :reduce(__insert, value)

    return next_state
end

--function GameState:set(path, f)
--    local val = self:get(path)
--    return self:set(path, f(val))
--end

function GameState:get(path)
    local path_parts = string.split(path, '/')
    local function __lookup(dict, key)
        if not dict then return end
        return dict[key]
    end
    return path_parts:reduce(__lookup, self.__root)
end

function GameState:write(path)
end

function GameState.read(path)

end

function GameState:initialize(init_name)
    if not init_name then
        log.error("Please supply initialization function name")
        return
    end
    local types = self:get("type")
    local function __do_load_type(state, id, type_path)
        local type_script = require(type_path)
        local init = type_script[init_name]
        return init(state, id)
    end
    local state = self
    for id, type_path in pairs(types) do
        local status, msg = pcall(__do_load_type, state, id, type_path)
        if status and msg then
            state = msg
        elseif not status then
            log.warn(
                "Loading of <%s, %s> failed:  %s", id, type_path,
                msg
            )
        else
            log.warn(
                "Loading of <%s, %s> did not return a valid state", id,
                type_path
            )
        end
    end

    return state
end

function GameState:mirror(key)
    return self
end

return GameState
