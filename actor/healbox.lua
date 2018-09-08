local sprite = require "animation/sprite"
local _, BoxSprite = require "actor/box"
local heal = require "ability/heal"
local target = require "ability/target"
local shield = require "ability/shield"

local rng = love.math.random

local function attack_animation(self)
    self.on_user("attack")
    self.on_user("done")
end

local function draw(self, x, y, r, sx, sy)
    local r, g, b, a = unpack(self.color)
    gfx.setColor(0.2 * r, 1 * g, 0.6 * b, a)
    local amp = self.shake_data.amp
    local phase = self.shake_data.phase
    x = x + self.spatial.x + math.sin(phase) * amp
    y = y + self.spatial.y
    sx = sx or 1
    sy = sy or 1
    sx = sx * self.scale
    sy = sy * self.scale

    local w, h = 30 * sx, 75 * sy
    gfx.rectangle("fill", x - w * 0.5, y, w, -h)
end

local function create_sprite()
    local sprite = sprite.create()
    sprite.draw = draw
    sprite:register("attack", attack_animation)
    return sprite
end

local function ai(id)
    local c = target.candidates(heal.target, id)
    local t = c.primary
        :filter(function(a)
            local hc = get_stat("health/current", a)
            local hm = get_stat("health/max", a)
            return hc < hm
        end)
        :sort(function(a, b)
            local ha = get_stat("health/current", a)
            local hb = get_stat("health/current", b)
            return ha < hb
        end)
        :head()

    if not t then
        return
    else
        return heal, t
    end
end

local healbox = {}
healbox.__index = box
healbox = setmetatable(healbox, healbox)

function healbox.__tostring()
    return "HealBox"
end

function healbox.init_visual(state, id)
    state.sprite[id] = create_sprite()
end

function healbox.init_state(state, id)
    state.health.max[id] = 8
    state.health.current[id] = 8
    state.power[id] = 0
    state.agility[id] = 2
    state.armor[id] = 2
    state.script[id] = ai
    state.name[id] = "Healer Box"
    visual.icon[id] = function(x, y, w, h)
        gfx.setColor(0.2, 1, 0.6)
        local margin = vec2(15, 5)
        gfx.rectangle("fill", x + 5, y + margin.y, w - margin.x, h - margin.y)
    end
end

return healbox
