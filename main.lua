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
GameState = require "gamestate/gamestate"

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

function love.load()
    log.info("Game is start")
    --local atlas = Atlas.create('res/sprites/misc')
    --sprite = atlas:sprite()
    charbar = CharacterBar.create()
    menu = VMenu.create()
    menu:set_items(List.create("Attack", "Spells", "Items"))

    numserver = DamageNumberServer.create()

    gamestate = GameState.create()
    gamestate = gamestate
        --:set("foo/bar/spam", 22)
        :set("health/fencer", 10)
        :set("health/alchemist", 5)
        :set("agility/fencer", 3)
        :set("type/fencerA", "actors/fencer")
        :set("type/poisonA", "debuffs/poison")
        
    print(gamestate)
    print(gamestate:get("agility"))


    Timer.every(0.5, function() numserver:number(5, 300, 300) end)
end

function love.keypressed(...)
    log.info("yo", ...)

end

function love.update(dt)
    Timer.update(dt)
    menu:update(dt)
    numserver:update(dt)
end

function love.draw()
--    sprite:draw(100, 100)
    charbar:draw(50, 50)
    menu:draw(150, 150)
    --num:draw(300, 300)
    numserver:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    menu:keypressed(key)
end

function love.keyreleased(...)
    menu:keyreleased(...)
end
