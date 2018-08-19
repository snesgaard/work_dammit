lume = require "modules/lume"
local lurker = require "modules/lurker"
game = require "game"
Sprite = require "animation/sprite"
common = require "designer/common"

function reload(p)
    package.loaded[p] = nil
    return require(p)
end

function love.load(arg)
    local path, anime = arg:unpack()

    game.setup.init_battle()

    local p = path:gsub('.lua', '')

    local atlas = Atlas.create(p)

    visual.sprite.design = Sprite.create(atlas)

    spriter_updater = coroutine.wrap(function(dt)
        visual.sprite.design:loop(dt, anime)
    end)
end

function love.update(dt)
    gfx.setColor(1, 1, 1)
    spriter_updater(dt)
end


function love.draw()
    local w, h = gfx.getWidth(), gfx.getHeight()
    local x, y = w / 2, h / 2
    common.draw_grid(w, h)
    visual.sprite.design:draw(x, y)
    local boxes = visual.sprite.design:collision(x, y)

    for id, b in pairs(boxes) do
        gfx.rectangle("line", b.x, b.y, b.w, b.h)
    end
end
