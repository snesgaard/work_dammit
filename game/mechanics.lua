local mechanics = {}

function mechanics.map_stat(f)
    return function(v)
        return math.clamp(f(v), -9, 9)
    end
end

return mechanics
