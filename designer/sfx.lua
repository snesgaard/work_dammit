lume = require "modules/lume"
local lurker = require "modules/lurker"
game = require "game"

function reload(p)
    package.loaded[p] = nil
    return require(p)
end

function love.load(arg)
    gfx.setBackgroundColor(0, 0, 0, 0)
    if not nodes.holder then
        --love.window.setMode(500, 800)
    end
    game.setup.init_battle()
    nodes.holder = process.create()

    settings = {origin = false}

    local function creation(path)
        local p = path:gsub('.lua', '')
        local t = reload(p)
        if p:find("post_process") then
            return nodes.post_process:child(t)
        else
            return nodes.holder:child(t)
        end
    end

    for _, path in ipairs(arg) do
        local n = creation(path)
        if n.test then
            n:fork(n.test, settings)
        end
    end

    function reload_scene()
        love.load(arg)
    end

    function lurker.preswap(f)
        f = f:gsub('.lua', '')
        package.loaded[f] = nil
    end
    function lurker.postswap(f)
        reload_scene()
    end
end

local do_update = true

function love.update(dt)
    lurker:update()
    if do_update then
        Timer.update(dt)
        for _, n in pairs(nodes) do
            n:update(dt)
        end
    end
end

local function draw_pause(x, y, w, h)
    gfx.setColor(1, 1, 1)
    if do_update then
        gfx.polygon("fill", x, y, x + w, y + h * 0.5, x, y + h)
    else
        gfx.setLineWidth(10)
        local c = x + w * 0.5
        gfx.line(c - 12, y, c - 12, y + h)
        gfx.line(c + 12, y, c + 12, y + h)
    end
end

function love.draw()
    gfx.setCanvas({nodes.post_process:front(), stencil=true})
    gfx.clear(0, 0, 0, 0)

    gfx.setColor(1, 1, 1)
    local w, h = gfx.getWidth(), gfx.getHeight()
    gfx.setColor(0, 0, 0, 1)
    gfx.rectangle("fill", 0, 0, w, h)
    gfx.setColor(255, 255, 255, 255)
    gfx.setLineWidth(2)
    gfx.line(0, h * 0.5, w, h * 0.5)
    gfx.line(w * 0.5, 0, w * 0.5, h)
    --gfx.translate(w * 0.25, h * 0.5)
    gfx.setColor(255, 255, 255)
    if settings.origin then
        nodes.holder:draw(0, 0)
    else
        nodes.holder:draw(w * 0.5, h * 0.5)
    end

    gfx.setCanvas()

    nodes.post_process:draw()
    draw_pause(25, 25, 50, 40)
end

nodes.root.keypressed:listen(function(key)
    if key == "tab" then
        reload_scene()
    elseif key == "space" then
        do_update = not do_update
    end
end)
