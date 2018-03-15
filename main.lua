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

function love.load()
    log.info("Game is start")
    local atlas = Atlas.create('res/sprites/misc')
    sprite = atlas:sprite()
    charbar = CharacterBar.create()
    menu = VMenu.create()
end

function love.update(dt)
    Timer.update(dt)
    menu:update(dt)
end

function love.draw()
--    sprite:draw(100, 100)
    charbar:draw(50, 50)
    menu:draw(150, 150)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
end
