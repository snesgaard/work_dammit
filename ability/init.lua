local modules = {
    "attack", "heal", "sap", "shield", "thunder", "potion", "acid",
    "thawing_blast", "hailstorm"
}

local loaded = {}

for _, key in pairs(modules) do
    loaded[key] = require("ability/" .. key)
end

function loaded.get(name)
    return require("ability/" .. name)
end

function loaded:__call(...)
    return loaded.get(...)
end

return setmetatable(loaded, loaded)
