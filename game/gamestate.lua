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

return GameState
