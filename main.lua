gfx = love.graphics
log   = require "modules.log"
log.outfile = '/tmp/game.log'

Atlas = require "atlas"
local Spatial = require "spatial"
Timer = require "modules.knife.timer"
Event = require "event"
List = require "list"
Dictionary = require "dictionary"
Node = require "node"
thread = require "thread"
id_gen = require "id_gen"
__gamestate = require "game/gamestate"
--Sprite = require "animation/sprite"

function istype(Type, object)
    if type(Type) == type(object) then
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

function root_node(self)
    self.keypressed = Event.create()
end

function love.load()
    gfx.setDefaultFilter("nearest", "nearest")
    nodes = {}

    nodes.root = Node.create(root_node)

    gamestate = __gamestate.create()

    visual = {
        sprite = {},
        atlas = {},
    }

    local fencer = require "actor/fencer"
    fen_id = id_gen.register(fencer)
    fencer.init_visual(visual, fen_id)
    gamestate = fencer.init_state(gamestate, fen_id)
    print(gamestate)
    visual.sprite[fen_id]:set_animation("idle")
end

function love.update(dt)
    Timer.update(dt)
    for _, n in pairs(nodes) do
        n:update(dt)
    end

    for _, s in pairs(visual.sprite) do
        s:update(dt)
    end
end

function love.draw()
    local w, h = gfx.getWidth(), gfx.getHeight()

    for _, n in pairs(nodes) do
        if n.draw then n:draw() end
    end

    visual.sprite[fen_id]:draw(100, 100)
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
