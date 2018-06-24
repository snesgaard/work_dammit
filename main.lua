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

BoxNode = {}

function BoxNode:create()
    self.spatial = Spatial.create(100, 100, 50, 50)
    self.color = {255, 255, 255}
    self:fork(BoxNode.animate)
    self:fork(BoxNode.listen_for_kill)
    self:fork(BoxNode.listen_for_dead)
end

function BoxNode:animate()
    while true do
        self:wait(
            Timer.tween(1, {[self.color] = {0, 0, 0}})
        )
        self:wait(
            Timer.tween(1, {[self.color] = {255, 255, 255}})
        )
    end
end

function BoxNode:listen_for_kill()
    while "q" ~= self:wait(nodes.root.keypressed) do end
    self:join(self.animation)
end

function BoxNode:listen_for_dead()
    while "t" ~= self:wait(nodes.root.keypressed) do end
    self:destroy()
end

function BoxNode:draw()
    gfx.setColor(unpack(self.color))
    gfx.rectangle("fill", self.spatial:unpack())
end

local Menu = {}

function Menu:create(x, y, parent)
    self.spatial = Spatial.create(x, y, 100, 150)
    self.color = List.create(255, 255, 255)
    self.parent = parent
    self:go_active()
end

function Menu:draw()
    gfx.setColor(unpack(self.color))
    gfx.rectangle("fill", self.spatial:unpack())
    gfx.setColor(self.color:map(function(r) return r / 2 end):unpack())
    gfx.rectangle("line", self.spatial:unpack())
    if self.child then
        self.child:draw()
    end
end

function Menu:listen_for_spawn()
    while "e" ~= self:wait(nodes.root.keypressed) do end
    self:go_passive()
    self:spawn_child()
end

function Menu:listen_for_despawn()
    if not self.parent then return end
    while "q" ~= self:wait(nodes.root.keypressed) do end
    self:despawn()
end

function Menu:animate()
    self:wait(1)
    self.color = List.create(0, 0, 255)
    self:wait(1)
    self.color = List.create(255, 255, 255)

    return self:animate()
end

function Menu:despawn()
    self.parent.child = nil
    self:destroy()
    self.parent:go_active()
end

function Menu:go_passive()
    self:destroy()
    self.color = List.create(255, 255, 0)
end

function Menu:go_active()
    self:destroy()
    self.color = List.create(255, 255, 255)
    self:fork(Menu.listen_for_spawn)
    self:fork(Menu.listen_for_despawn)
    self:fork(Menu.animate)
end

function Menu:spawn_child()
    local x, y = self.spatial:unpack()
    self.child = Node.create(Menu, x + 50, y, self)
end

function root_node(self)
    self.keypressed = Event.create()
end

function love.load()
    nodes = {}

    nodes.root = Node.create(root_node)
    nodes.box = Node.create(Menu, 100, 100)

end

function love.update(dt)
    Timer.update(dt)
    for _, n in pairs(nodes) do
        n:update(dt)
    end
end

function love.draw()
    local w, h = gfx.getWidth(), gfx.getHeight()

    for _, n in pairs(nodes) do
        if n.draw then n:draw() end
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
