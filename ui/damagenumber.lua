local Label = require "ui/label"
local Fonts = require "ui/fonts"
local Spatial = require "spatial"

local DamageNumber = {}
DamageNumber.__index = DamageNumber

function DamageNumber.create(number, master, type)
    local color = type == "heal" and {50, 255, 120, 0} or {255, 120, 50, 0}
    local this = {
        label = Label.create()
            :set_text(tostring(number))
            :set_color(unpack(color))
            :set_font(Fonts(25))
            :set_align("center")
            :set_valign("center"),
        scale = 5,
        animation = Convoke(DamageNumber.animate),
        master = master,
    }
    this.label.spatial = Spatial.create(0, 0, 0, 0)
        :expand(200, 50)
    this = setmetatable(this, DamageNumber)
    this.animation(this)
    return this
end

function DamageNumber.animate(handle, self)
    local tween = handle:tween(0.15, {
        [self.label.color] = {[4] = 255},
        [self] = {scale = 1}
    })
    handle:wait(tween)
    handle:wait(1)
    local spatial = self.label.spatial
    tween = handle:tween(0.25, {
        [self.label.color] = {[4] = 0},
        [self.label.spatial] = spatial:move(0, -50)
    })
    handle:wait(tween)
    self:remove()
end

function DamageNumber:update(dt)
    self.animation:update(dt)
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

function DamageNumberServer.create()
    local this = {
        numbers = {},
        x = {},
        y = {},
        time = {},
        draworder = {}
    }
    return setmetatable(this, DamageNumberServer)
end

function DamageNumberServer:number(number, x, y, type)
    number = DamageNumber.create(number, self, type)
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

function DamageNumberServer:update(dt)
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
