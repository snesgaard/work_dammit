local modules = {
    "attack", "heal", "sap", "shield", "thunder", "potion", "acid"
}

local loaded = {}

for _, key in pairs(modules) do
    loaded[key] = require("ability/" .. key)
end

return loaded
