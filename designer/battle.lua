game = require "game"
sti = require "modules.sti"
sprite = require "animation/sprite"

function love.load(arg)
    gfx.setBackgroundColor(0.0, 0.0, 0.0, 0)
    game.setup.init_battle()
    nodes.holder = process.create()

    -- only pick the first scene
    local scene = arg:head()
    if scene then
        local p = scene:gsub('.lua', '')
        local t = reload(p)
        nodes.holder:child(t)
        nodes.battle_planner:begin()
    end

    bg = sti("art/maps/build/lab.lua")

    local old_draw = bg.layers.background.draw

    function bg.layers.background.draw(...)
        gfx.setColor(0.2, 0.2, 0.5)
        old_draw(...)
    end


    bg.layers.bg_obj.sprites = {}

    local animations = {}

    for _, obj in pairs(bg.layers.bg_obj.objects) do
        local s = obj.properties.sprite
        if not animations[s] then
            animations[s] = function(sprite, dt)
                sprite:loop(dt, s)
            end
        end
    end

    local sprites = bg.layers.bg_obj.sprites
    local atlas = get_atlas("art/props")
    for _, obj in pairs(bg.layers.bg_obj.objects) do
        local key = obj.properties.sprite
        local s = sprite.create(atlas, animations)
        s:set_animation(key)
        s:set_origin('origin')
        s.scale = 1
        s.color = nil
        local t = spatial(obj.x, obj.y, obj.width, obj.height)
        s.spatial = t:yalign(t, "top", "bottom")
        sprites[#sprites + 1] = s
    end

    function bg.layers.bg_obj.update(self, dt)
        for _, s in pairs(self.sprites) do
            s:update(dt)
        end
    end

    function bg.layers.bg_obj.draw(self, ...)
        gfx.setColor(0.6, 0.6, 0.8)
        for _, s in pairs(self.sprites) do
            s:draw(...)
        end
    end

    local old_draw_window = bg.layers.windows.draw
    function bg.layers.windows.draw(...)
        gfx.setColor(0.5, 0.5, 0.8)
        old_draw_window(...)
    end
end


function love.update(dt)
    Timer.update(dt)
    bg:update(dt)
    for _, n in pairs(nodes) do
        n:update(dt)
    end

    for _, s in pairs(visual.sprite) do
        s:update(dt)
    end

    for _, u in pairs(visual.ui) do
        u:update(dt)
    end
end

function love.draw()
    gfx.setColor(1, 1, 1)
    bg:draw(0, 0, 2, 2)

    for id, s in pairs(visual.sprite) do
        local pos = nodes.position:get_world(id)
        s:draw(pos:unpack())
    end

    nodes.sfx:draw()
    nodes.charge:draw()
    nodes.damage_number:draw()
    nodes.enrage_monitor:draw()

    for id, ui in pairs(visual.ui) do
        local offset = visual.ui_offset[id] or 0
        local pos = nodes.position:get_world(id) - vec2(0, 225 + offset)
        ui:draw(pos:unpack())
    end

    nodes.battle_planner:draw()
    nodes.round_planner:draw()
    nodes.turn:draw()
end

local keyrepeaters = {}

local function keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    if key == "p" then
        for _, s in pairs(visual.sprite) do
            s:shake()
        end
    end
    nodes.root.keypressed(key, scancode, isrepeat)
end

function love.keypressed(key, scancode, isrepeat)
    local function callback()
        keypressed(key, scancode, isrepeat)
    end
    local interval = 0.35
    keyrepeaters[key] = Timer.every(interval, callback)
    callback()
end

local function keyreleased(key, scancode)

end

function love.keyreleased(key, scancode)
    keyreleased(key, scancode)
    local timer = keyrepeaters[key]
    keyrepeaters[key] = nil
    timer:remove()
end
