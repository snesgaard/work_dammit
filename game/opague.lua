local Opague = {}
Opague.__index = Opague

setmetatable(VItem, {__index = require "gamestate/node"})

function Opague.__tostring(node)
    return string.format("Opague Node")
end

function Opague.create(state)
    return setmetatable({state = state}, Opague)
end

function Opague:transform()
    return self.__state
end

return Opague
