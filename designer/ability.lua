local game = require "game"

local friend_type = require "actor/fencer"
local target_type = require "actor/box"
lume = require "modules/lume"
local lurker = require "modules/lurker"

function love.load(arg)
    gfx.setBackgroundColor(0, 0, 0, 0)
    function reload_scene()
        love.load(arg)
    end

    log.info("Initializing battle nodes")
    game.setup.init_battle()

    -- Start by initializing all actors

    local typemap = {}
    for i = 1, 4 do
        local id = game.setup.actor.state(i, friend_type)
        typemap[id] = friend_type
    end

    for i = 1, 4 do
        local id = game.setup.actor.state(-i, target_type)
        typemap[id] = target_type
    end

    local ability = arg[1]
    if not ability then
        log.warn("No ability given")
        return
    end
    ability = ability:gsub('.lua', '')
    log.info("Executing %s", ability)

    local ability = reload(ability)

    local user = nodes.position:get(1)

    local target_candidates = ability.target.candidates(
        nodes.position.placements, user
    )
    local target = target_candidates:values():tail()

    if ability.test_setup then
        ability.test_setup(user, target)
    end

    game.setup.actor.visual(user, friend_type)

    target_all = type(target) == "string" and list(target) or target

    for _, id in pairs(target_all) do
        if id ~= user then
            local t = typemap[id]
            game.setup.actor.visual(id, t)
        end
    end

    for _, s in pairs(visual.sprite) do
        s:set_animation("idle")
    end

    nodes.animation:add(ability.run, user, target)

    function lurker.postswap(f)
        reload_scene()
    end
end

function love.update(dt)
    lurker:update()
    Timer.update(dt)
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
    for id, s in pairs(visual.sprite) do
        local pos = nodes.position:get_world(id)
        s:draw(pos:unpack())
    end

    nodes.sfx:draw()
    nodes.damage_number:draw()

    for id, ui in pairs(visual.ui) do
        local pos = nodes.position:get_world(id) - vec2(0, 225)
        ui:draw(pos:unpack())
    end
end


nodes.root.keypressed:listen(function(key)
    if key == "tab" then
        reload_scene()
    end
end)
