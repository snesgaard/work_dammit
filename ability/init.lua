local modules = {
    "attack", "heal", "sap", "shield", "thunder", "potion", "acid",
    "thawing_blast", "hailstorm"
}

local loaded = {}

for _, key in pairs(modules) do
    loaded[key] = require("ability/" .. key)
end

return loaded
