game = require "game"
sti = require "modules.sti"
sprite = require "animation/sprite"

function love.load(arg)
    gfx.setBackgroundColor(0.5, 0.5, 0.5, 1.0)
    game.setup.init_battle()
    nodes.holder = process.create()
    local path = arg:head():gsub('.lua', '')
    nodes.minion:set("dummy", require(path))

    local n = nodes.minion.__minions["dummy"]
    if n.test then
        n:fork(n.test)
    end
end

function love.update(dt)
    Timer.update(dt)
    for _, n in pairs(nodes) do
        n:update(dt)
    end
end


function love.draw()
    gfx.setColor(1, 1, 1)

    nodes.minion:draw(gfx.getWidth() / 2, gfx.getHeight() / 2)

    nodes.announcer:draw(gfx.getWidth() / 2, 0)
end
