local VerticalMenu = require "ui/vertical_menu"
local FSM = require "fsm"
local Event = require "event"
local Animation = require "animation/server"
local Moonshine = require "modules/moonshine"

local TargetMarker = {}

function TargetMarker.animate(convoke, context, spatial)
    context.canvas = gfx.newCanvas(200, 200)
    context.effect = Moonshine(Moonshine.effects.gaussianblur)
    context.effect.gaussianblur.sigma = 3.0
    context.effect2 = Moonshine(Moonshine.effects.gaussianblur)
    context.effect2.gaussianblur.sigma = 1.0
    context.position = spatial
        :move(0, -50)
        :set_size(5, 0)
    convoke:wait(
        convoke:tween(0.1, {[context.position] = {w = 15}})
    )
    convoke:wait(
        convoke:tween(0.1, {[context.position] = {w = 10}})
    )
    while true do
        convoke:wait(
            convoke:tween(1.0, {[context.position] = {w = 8}})
        )
        convoke:wait(
            convoke:tween(1.0, {[context.position] = {w = 10}})
        )
    end
end

function TargetMarker.draw(context)
    --gfx.setCanvas(context.canvas)
    gfx.setColor(255, 255, 255)
    local x, y = context.position:unpack()
    local function bloom_draw()
        --gfx.clear(0, 0, 0, 0)
        local s = 2
        gfx.setColor(20 * s, 30 * s, 70 * s)
        gfx.ellipse(
            "fill", x, y,
            context.position.w + 45, context.position.w  * 0.45
        )
        gfx.circle(
            "fill", x, y, context.position.w + 3
        )

    end
    local function draw2()
        gfx.setColor(200, 200, 255)
        gfx.circle(
            "fill", x, y, context.position.w * 0.5
        )
    end
    context.effect.draw(bloom_draw)
    context.effect2.draw(draw2)


    --bloom_draw()
    --gfx.setCanvas()
    --gfx.setStencilTest()
    --gfx.setShader()
    gfx.setColor(255, 255, 255)
    --gfx.setBlendMode("add")
    --gfx.draw(context.canvas, context.position.x - 100, context.position.y - 100)
    --gfx.setBlendMode("alpha")

end

local PickAction = {}
PickAction.__index = PickAction
setmetatable(PickAction, {__index = FSM})

PickAction.STATES = {
    base_menu = {},
    sub_menu = {},
    target_menu = {},
}

function PickAction.create(gamestate, visualstate, actor)
    local this = {
        gamestate = gamestate,
        visualstate = visualstate,
        on_select = Event.create(),
        anime_group = {},
        actor = actor,
        pos = visualstate.spatial[actor]:move(25, -250),
        menu = VerticalMenu.create()
            :set_items(List.create("Attack", "Magic", "Items", "Defend")),
    }
    return setmetatable(this, PickAction)
end

function PickAction.STATES.base_menu:begin()
    local function callback(value)
        if value == "Attack" or value == "Defend" then
            return self:set_state("target_menu")
        end
        local magics = List.create("Fire", "Ice", "Thunder")
        local items = List.create("Potion", "Antidote")
        local menu_item = value == "Magic" and magics or items
        return self:set_state("sub_menu", menu_item)
    end
    self.__workspace.listener = self.menu.on_select:listen(callback)
    self.submenu = nil
end

function PickAction.STATES.base_menu:keypressed(...)
    self.menu:keypressed(...)
end

function PickAction.STATES.base_menu:keyreleased(...)
    self.menu:keyreleased(...)
end

function PickAction.STATES.base_menu:exit()
    self.menu:halt()
    self.__workspace.listener:remove()
end


function PickAction.STATES.sub_menu:begin(items)
    local function on_select(action)
        return self:set_state("target_menu")
    end
    local function on_escape()
        return self:set_state("base_menu")
    end
    self.submenu = self.submenu or VerticalMenu.create():set_items(items)
    --TODO GATHER REFERNCES AND DISABLE ON EXIT
    self.__workspace.listener = {
        on_select = self.submenu.on_select:listen(on_select),
        on_escape = self.submenu.on_escape:listen(on_escape)
    }
    self.subpos = self.pos:move(50, 0)
end


function PickAction.STATES.sub_menu:keypressed(...)
    self.submenu:keypressed(...)
end

function PickAction.STATES.sub_menu:keyreleased(...)
    self.submenu:keyreleased(...)
end

function PickAction.STATES.sub_menu:exit()
    self.submenu:halt()
    for _, listener in pairs(self.__workspace.listener) do
        listener:remove()
    end
end

local function move_target_marker(self)
    self.anime_group = {}
    local target = self.__workspace.targets:head()
    local pos = self.visualstate.spatial[target]
    Animation.animate(TargetMarker, self.anime_group):run(pos)
end

function PickAction.STATES.target_menu:begin()
    local actor_faction = gamestate:get("faction/" .. self.actor)
    self.__workspace.targets = gamestate:get("faction/")
        :filter(function(id, f) return f ~= actor_faction end)
        :keys()
        :sort(function(a, b)
            return gamestate:get("place/" .. a) < gamestate:get("place/" .. b)
        end)
    move_target_marker(self)
end

function PickAction.STATES.target_menu:keypressed(key)
    if key == "lshift" then
        local state = self.submenu and "sub_menu" or "base_menu"
        self:set_state(state)
    elseif key == "space" then
        local menu = self.submenu or self.menu
        local action = menu:get_selection()
        local target = self.__workspace.targets:head()
        self.on_select(action, target)
    elseif key == "left" then
        self.__workspace.targets = self.__workspace.targets:cycle(1)
        move_target_marker(self)
    elseif key == "right" then
        self.__workspace.targets = self.__workspace.targets:cycle(-1)
        move_target_marker(self)
    end
end

function PickAction.STATES.target_menu:exit()
    self.anime_group = {}
end

for _, state in pairs(PickAction.STATES) do
    function state:draw(...)
        Animation.draw(self.anime_group)
        self.menu:draw(self.pos.x, self.pos.y)
        if self.submenu then
            self.submenu:draw(self.subpos.x, self.subpos.y)
        end
    end
    function state:update(dt)
        Animation.update(dt, self.anime_group)
        self.menu:update(dt)
        if self.submenu then self.submenu:update(dt) end
    end
end

return PickAction
