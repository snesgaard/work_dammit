local mechanics = {}

function mechanics.map_stat(f)
    return function(v)
        return math.clamp(f(v or 0), -9, 9)
    end
end

function mechanics.add_stat(a)
    a = a or 0
    return mechanics.map_stat(function(v) return a + v end)
end

function mechanics.unlock_ability(...)
    local ability = require "ability"
    local l1 = list(...)
        :map(function(p) return ability(p) end)
    return function(l2)
        l2 = l2 or list()
        return l2:concat(l1)
    end
end

return mechanics
