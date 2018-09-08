local ability = require "ability"
local _, BoxSprite = require "actor/box"
local target = require "ability/target"

local function submit_ability(id, a)
    local targets = target.candidates(a.target, id)

    return a, targets.primary:random()
end

local function ai(id)
    local function is_full()
        return get_stat("health/current", id) == get_stat("health/max", id)
    end

    if is_full() then
        return submit_ability(id, ability("attack"))
    else
        return submit_ability(id, ability("explode"))
    end
end


local actor = {}

actor.__index = actor
actor = setmetatable(actor, actor)

function actor.init_visual(state, id)
    local function create_sprite()
        local function draw(self, x, y, r, sx, sy)
            local r, g, b, a = unpack(self.color)
            gfx.setColor(0.7 * r, 0.2 * g, 0.1 * b, a)
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

        local create_sprite = require "animation/box"
        local sprite = create_sprite()
        sprite.draw = draw
        return sprite
    end

    state.sprite[id] = create_sprite()
end

function actor.init_state(state, id)
    state.health.max[id] = 5
    state.power[id] = 0
    state.agility[id] = 0
    state.armor[id] = 0
    state.script[id] = ai
    state.name[id] = "Living Bomb"
end

return actor
