gfx = love.graphics
log   = require "modules.log"
log.outfile = '/tmp/game.log'

__server = require "animation/server"
ease = require "ease"
ui = require "ui"
mutator = require "mutator"
game = require "game"
actor = require "actor"
attack = require "ability/attack"
heal = require "ability/heal"
target = require "ability/target"
__position = require "game/position"
particles = require "sfx/particles"
--Sprite = require "animation/sprite"

function math.cycle(value, min, max)
    if value < min then
        return math.cycle(value + max - min + 1, min, max)
    elseif value > max then
        return math.cycle(value - max + min - 1, min, max)
    else
        return value
    end
end

function math.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function istype(Type, object)
    if type(Type) == type(object) and type(Type) ~= "table" then
        return true
    elseif type(Type) == "table" and type(object) == "table" then
        return Type.__index == object.__index
    else
        return false
    end
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t=List.create() ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end



local sfx_sparkles = {}

function sfx_sparkles.create(self)
    self.particles = particles{
        image = "art/part.png",
        buffer = 100,
        move = {600, 600},
        lifetime = 1,
        rate = 50,
        spread = {"uniform", 50, 100},
        size = 0.5,
        speed = 75,
        dir = -math.pi * 0.5,
        damp = {0.5, 0.5},
        color = {
            50, 255, 50, 0,
            50, 255, 50, 255,
            50, 255, 50, 255,
            0, 0, 0, 0
        }
    }
    --self.particles:setLinearAcceleration(0, -1)
    self.on_finish = event.create()
    self:fork(self.life)
end

function sfx_sparkles:__draw()
    gfx.draw(self.particles)
end

function sfx_sparkles:__update(dt)
    self.particles:update(dt)
    if self.particles:getCount() == 0 and self.terminate then
        self:destroy()
    end
end

function sfx_sparkles:life()
    self:wait(1.0)
    self.particles:stop()
    self.terminate = true
end

function sfx_sparkles:foo()
    while true do

    end
end

function love.load()
    gfx.setDefaultFilter("nearest", "nearest")
    --nodes = {}

    --nodes.root = process.create(root_node)
    nodes.position = process.create(__position)
    nodes.animation = process.create(__server)
    --nodes.planner = process.create(planner)
    nodes.round_planner = process.create(game.planner.round)
    nodes.battle_planner = process.create(game.planner.battle)

    nodes.game = process.create(game.state)
    nodes.damage_number = process.create(ui.damage_number)
    nodes.sfx = process.create()
    nodes.sfx:child(sfx_sparkles)


    visual = {
        sprite = {},
        ui = {},
        atlas = {},
    }

    local party_types = List.create(actor.fencer, nil, actor.fencer)
    local enemy_types = List.create(actor.box, nil, actor.box, actor.box)

    local function create_actor(index, type)
        if not type then return end
        local id = id_gen.register(type)
        type.init_state(nodes.game.actor, id)
        type.init_visual(visual, id)
        nodes.position:set(id, index)
        visual.ui[id] = process.create(ui.stat_bar, id)
        return id
    end


    for index, type in pairs(party_types) do
        create_actor(index, type)
    end

    for index, type in pairs(enemy_types) do
        create_actor(-index, type)
    end


    nodes.root.keypressed:listen(function(key)
        if key == "a" then
            local attacker = nodes.position:get(1)
            local defender = nodes.position:get(-1)
            nodes.game:damage(attacker, defender, 3)
        end
    end)

    --nodes.target = process.create(
    --    target.single, nodes.position:get(1), "opposite"
    --)


    for _, s in pairs(visual.sprite) do
        s:set_animation("idle")
    end

    --nodes.planner:set_state(planner.selection, nodes.position:get(1))
    --nodes.round_planner:submit(nodes.position.placements:values())

    nodes.animation:add(heal.run, nodes.position:get(1),  nodes.position:get(3))
--    nodes.animation:add(attack.run, nodes.position:get(1),  nodes.position:get(-1))
    --nodes.animation:add(animate_jump, fen_id)
    --nodes.animation:add(animate_swap, fen_id, box_id2)
    --nodes.animation:add(animate_attack, fen_id, box_id)
    --nodes.animation:add(animate_swap, fen_id, box_id2)

    nodes.battle_planner:begin()
end

function love.update(dt)
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
    local w, h = gfx.getWidth(), gfx.getHeight()

    for _, n in pairs(nodes) do
        --if n.draw then n:draw() end
    end

    for id, s in pairs(visual.sprite) do
        local pos = nodes.position:get_world(id)
        s:draw(pos:unpack())
    end

    local function draw_place(i)
        local p1 = nodes.position:get_world(i)
        gfx.setColor(255, 255, 255, 100)
        local s = Spatial.create(-50, 0, 100, 20)
            :move(p1:unpack())
        gfx.rectangle("fill", s:unpack())
    end

    for i = 1, 4 do
        draw_place(i)
        draw_place(-i)
    end

    nodes.sfx:draw()

    nodes.round_planner:draw()

    --nodes.target:draw()
    nodes.damage_number:draw()

    for id, ui in pairs(visual.ui) do
        local pos = nodes.position:get_world(id) - vec2(0, 225)
        ui:draw(pos:unpack())
    end

end

local keyrepeaters = {}

local function keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
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
