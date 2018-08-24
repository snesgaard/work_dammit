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

    context = {pos = vec2(0, 0)}

    function visual.sprite.design.__on_hitbox(hitbox)
        context.hitbox = hitbox
    end

    function visual.sprite.design.__on_frame_motion(self, dx)
        context.pos = context.pos + dx
    end

    spriter_updater = coroutine.wrap(function(dt)
        visual.sprite.design:loop(dt, anime)
    end)

    nodes.root.keypressed:listen(function(key)
        local sprite = visual.sprite.design
        if key == "left" then
            sprite:set_mirror(-1)
        elseif key == "right" then
            sprite:set_mirror(1)
        end
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
    visual.sprite.design:draw(context.pos.x + x, y)

    gfx.setColor(1, 1, 1, 0.25)
    for key, box in pairs(context.hitbox or {}) do
        gfx.rectangle("line", box:move(x + context.pos.x, y):unpack())
    end
end
