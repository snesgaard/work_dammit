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

return mechanics
