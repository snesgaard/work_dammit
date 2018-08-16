lume = require "modules/lume"
local lurker = require "modules/lurker"
game = require "game"

function love.load(arg)
    local path = arg:head()

    game.setup.init_battle()


end
