local Node = {}
Node.__index = Node

function Node.__tostring(node)
    if node.__tag then
        return string.format("Node <%s>", node.__tag)
    else
        return "Node"
    end
end

function Node.create(init_state)
    local this = {
        init_state = init_state
    }
    return setmetatable(this, Node)
end

function Node:__map()
    return self.init_state, "root"
end

function Node:map(...)
    --print("map", self.__args)
    local prev_state = self.__prev and self.__prev:read() or {}
    self.__args = self.__args or List.create()
    local args = self.__args
        :map(
            function(v)
                if type(v) ~= "function" then
                    return v
                else
                    return v(self.__prev)
                end
            end
        )

    return self:__map(prev_state, unpack(args))
end

function Node:info()
    return self.__info
end

function Node:read()
    if not self.__state then
        self.__state, self.__info = self:map()
    end
    return self.__state
end

function Node:node(Type, ...)
    local next = Type.create()
    next.__prev = self
    next.__args = List.create(...)
    return next
end

function Node:clear()
    self.__state = nil
    return self
end

function Node:tag(tag)
    self.__tag = name
    return self
end

function Node:find(tag)
    local function cmp(s)
        return s == tag
    end
    local f = type(name) == "function" and name or cmp
    local node = self.__prev
    while node and not f(node.__tag) do
        node = node.__prev
    end
    return node
end

function Node:link(dst)
    local node = self
    local graph = List.create()
    while node ~= dst and node.__prev do
        graph[#graph + 1] = node
        node = node.__prev
    end
    if not node.__prev then
        return
    else
        return graph:insert(dst):reverse()
    end
end

function Node:compile()
    local state = self:read()
    return Node.create()
end

return Node
