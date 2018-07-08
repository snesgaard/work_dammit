local Label = require "ui/label"
local Fonts = require "ui/fonts"
local Spatial = require "spatial"

local DamageNumber = {}
DamageNumber.__index = DamageNumber

function DamageNumber:create(number, master, type)
    local color = type == "heal" and {50, 255, 120, 0} or {255, 120, 50, 0}
    for i, c in ipairs(color) do
        color[i] = c / 255
    end
    self.label = Label.create()
        :set_text(tostring(number))
        :set_color(unpack(color))
        :set_font(Fonts(25))
        :set_align("center")
        :set_valign("center")
    self.scale = 5
    self.master = master

    self.label.spatial = Spatial.create(0, 0, 0, 0)
        :expand(200, 50)
    self:fork(DamageNumber.animate)
end

function DamageNumber.animate(self)
    local tween = Timer.tween(0.15, {
        [self.label.color] = {[4] = 255},
        [self] = {scale = 1}
    })
    self:wait(tween)
    self:wait(1)
    local spatial = self.label.spatial
    tween = Timer.tween(0.25, {
        [self.label.color] = {[4] = 0},
        [self.label.spatial] = spatial:move(0, -50)
    })
    self:wait(tween)
    self:remove()
end

function DamageNumber:remove()
    --self.animation:terminate()
    self.master:remove(self)
end

function DamageNumber:draw(x, y, r)
    self.label:draw(x, y, r, self.scale, self.scale)
end

local DamageNumberServer = {}
DamageNumberServer.__index = DamageNumberServer

function DamageNumberServer:create()
    self.numbers = {}
    self.x = {}
    self.y = {}
    self.time = {}
    self.draworder = {}

    nodes.game.event.on_damage:listen(function(info)
        local id = info.defender
        local dmg = info.damage

        local pos = nodes.position:get_world(id) - vec2(0, 100)

        self:number(dmg, pos.x, pos.y)
    end)


    nodes.game.event.on_heal:listen(function(info)
        local pos = nodes.position:get_world(info.target) - vec2(0, 150)
        self:number(info.heal, pos.x, pos.y, "heal")
    end)
end

function DamageNumberServer:number(number, x, y, type)
    number = process.create(DamageNumber, number, self, type)
    --number = DamageNumber.create(number, self, type)
    self.numbers[number] = true
    self.time[number] = love.timer.getTime()
    self.x[number] = x + love.math.random(-10, 10)
    self.y[number] = y + love.math.random(-10, 10)
    self.draworder = self:get_draworder()
    return self
end

function DamageNumberServer:remove(number)
    self.numbers[number] = nil
    self.time[number] = nil
    self.x[number] = nil
    self.y[number] = nil
    self.draworder = self:get_draworder()
    return self
end

function DamageNumberServer:__update(dt)
    for number, _ in pairs(self.numbers) do
        number:update(dt)
    end
end

function DamageNumberServer:get_draworder()
    local order = List.create()
    for number, _ in pairs(self.numbers) do
        order[#order + 1] = number
    end
    local function sort(a, b)
        return self.time[a] < self.time[b]
    end
    table.sort(order, sort)
    return order
end

function DamageNumberServer:draw(x, y, r)
    x = x or 0
    y = y or 0
    for _, number in ipairs(self.draworder) do
        number:draw(self.x[number] + x, self.y[number] + y, r)
    end
end

return DamageNumberServer
