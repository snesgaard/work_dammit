local actor = {
    fencer = require "actor/fencer",
    box = require "actor/box",
    healbox = require "actor/healbox",
    alchemist = require "actor/alchemist"
}

function actor:__call(name)
    return require("actor/" .. name)
end

return setmetatable(actor, actor)
