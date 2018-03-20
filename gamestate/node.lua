local Node = {}
Node.__index = Node

function Node.__tostring(node)
    return string.format("Base Node")
end

-- Should be overwritten by specific nodes
function Node:transform(state)
    return state
end

function Node:read()
    if not self.__state then
        self.__state = self:transform(self.__prev:read())
    end
    return self.__state
end

function Node:node(Type, ...)
    local next = Type(...)
    next.__prev = self
    next.__tags = self.__tags
    return next
end

function Node:clear()
    self.__state = nil
    return self
end

function Node:tag(name)
    if not self.__tags[name] then
        self.__tags[name] = self
    else
        log.warn("Tag <%s> already exists in graph", name)
    end
    return self
end

function Node:find(name)
    local node = self.__tags[name]
    if not node then
        log.warn("Tag <%s> does not exist in graph", name)
    end
    return node
end

return Node
