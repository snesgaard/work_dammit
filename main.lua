gfx = love.graphics
log   = require "modules.log"
log.outfile = '/tmp/game.log'

local Atlas = require "atlas"
local Label = require "ui/label"
local Bar   = require "ui/bar"
local Spatial = require "spatial"
local CharacterBar = require "ui/character_bar"
Timer = require "modules.knife.timer"
local VMenu  = require "ui/vertical_menu"
Convoke = require "convoke"
Event = require "event"
List = require "list"
Dictionary = require "dictionary"
DamageNumberServer = require "ui/damagenumber"
GameState = require "game/gamestate"
Node = require "game/node"
Mechanics = require "game/mechanics"
FactionBar = require "ui/faction_bar"
Icon = require "ui/icon"
Battle = require "game/battle"
Animation = require "animation/server"
Graph = require "game/graph"
VisualState = require "ui/visualstate"
TurnBar = require "ui/turnbar"

local TestAnimation = {}

function TestAnimation.animate(convoke, context)
    context.pos = Spatial.create(0, 600)
    local tween = convoke:tween(2.0, {
        [context.pos] = context.pos:move(1000, 0)
    })
    convoke:wait(tween)
    log.info("done")
end

function TestAnimation.draw(context)
    local pos = context.pos
    gfx.setColor(255, 255, 255)
    gfx.circle("fill", pos.x, pos.y, 10, 20)
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

local __get_spatial = {}
function __get_spatial.heroes(place)
    local w = gfx.getWidth()
    return Spatial.create(w / 2 - place * 150 - 100, 550)
end

function __get_spatial.villians(place)
    local w = gfx.getWidth()
    return Spatial.create(w / 2 + place * 150 + 100, 550)
end

function love.load()
    log.info("Game is start")
    --love.keyboard.setKeyRepeat(true)
    gfx.setBackgroundColor(0, 0, 0, 0)
    gfx.setDefaultFilter("nearest", "nearest")
    local atlas = Atlas.create('res/sprites/misc')

    gamestate = GameState.create()
        :set("type/fencerA", "actor/fencer")
        :set("faction/fencerA", "heroes")
        :set("place/fencerA", 1)
        :set("type/fencerB", "actor/fencer")
        :set("faction/fencerB", "heroes")
        :set("place/fencerB", 2)
        :set("type/boxA", "actor/box")
        :set("faction/boxA", "villians")
        :set("place/boxA", 1)
        :set("type/boxB", "actor/box")
        :set("faction/boxB", "villians")
        :set("place/boxB", 2)
        :initialize("init_state")
    for id, max_hp in pairs(gamestate:get("max_health")) do
        gamestate = gamestate:set("health/" .. id, max_hp)
    end

    visualstate = VisualState.create()

    visualstate.ui.numbers = DamageNumberServer.create()
    visualstate.ui.turnbar = TurnBar.create()
    for id, type in pairs(gamestate:get("type/")) do
        local place = gamestate:get("place/" .. id)
        local faction = gamestate:get("faction/" .. id)
        visualstate.spatial[id] = __get_spatial[faction](place)
        visualstate.face[id] = faction == "heroes" and 1 or -1
        visualstate:init(id, type)
    end
    --visualstate = visualstate:initialize("init_visual")
    for _, sprite in pairs(visualstate.sprite) do
        sprite
            :set_animation("idle")
            :set_origin("origin")
    end
    heroesbar = FactionBar.create():setup(gamestate)

    spa1 = Spatial.create(50, 50, 100, 75)
    spa2 = Spatial.create(0, 0, 50, 40)
    spa2 = spa2
        :xalign(spa1, "left", "left", 3)
        :yalign(spa1, "top", "bottom", 3)
    spa3 = spa2
        :yalign(spa2, "top", "bottom", 3)
    --log.info("Visualstate = %s", tostring(visualstate))
    battle = Battle.create(gamestate, visualstate)

    battle.graph:on_progess(Mechanics.Attack, function(state, info)
        local dst, dmg = info.dst, info.damage
        local pos = visualstate.spatial[dst]:move(0, -75)
        visualstate.ui.numbers:number(dmg, pos:unpack())
        heroesbar:on_damage(state, info)
    end)
    battle.graph:on_progess(Mechanics.Heal, function(state, info)
        local dst, heal = info.dst, info.heal
        local pos = visualstate.spatial[dst]:move(0, -75)
        visualstate.ui.numbers:number(heal, pos.x, pos.y, "heal")
        heroesbar:on_damage(state, info)
    end)
    battle.graph:on_progess(Mechanics.NewTurn, function(state, info)
        visualstate.ui.turnbar:clear()
    end)
    battle.graph:on_progess(Mechanics.TurnOrder, function(state, info)
        for _, id in ipairs(state:get("turn/order")) do
            visualstate.ui.turnbar:actor(visualstate, id)
        end
    end)
    battle.graph:on_progess(Mechanics.AddAction, function(state, info)
        visualstate.ui.turnbar:action()
    end)
    battle.graph:on_progess(Mechanics.ActionExecuted, function(state, info)
        visualstate.ui.turnbar:pop()
    end)

    battle:set_state("battle_begin")

    Animation.animate(TestAnimation):run()

end

function love.update(dt)
    Timer.update(dt)
    for id, sprite in pairs(visualstate.sprite) do
        if sprite.update then sprite:update(dt) end
    end
    battle:update(dt)
    Animation.update(dt)
    visualstate.ui.numbers:update(dt)
    visualstate.ui.turnbar:update(dt)
end

function love.draw()
    local w, h = gfx.getWidth(), gfx.getHeight()
    for id, sprite in pairs(visualstate.sprite) do
        local spatial = visualstate.spatial[id]
        local face = visualstate.face[id]
        sprite:draw(spatial.x, spatial.y, 0, 2 * face, 2)
    end
    heroesbar:draw(25, h - 25)
    gfx.setColor(255, 0, 0, 100)
    for _, s in ipairs({spa1, spa2, spa3}) do
        --gfx.rectangle("fill", s:unpack())
    end
    battle:draw(0, 0)
    visualstate.ui.numbers:draw(0, 0)
    visualstate.ui.turnbar:draw(20, 20)
    Animation.draw()
end

local keyrepeaters = {}

local function keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    battle:keypressed(key, scancode, isrepeat)
    if key == "a" then
        turnbar:action()
    elseif key == "d" then
        turnbar:pop()
    end
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
