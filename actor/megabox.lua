local ability = require "ability"
local _, BoxSprite = require "actor/box"
local target = require "ability/target"

local function submit_ability(id, a)
    local targets = target.candidates(a.target, id)

    return coroutine.yield(a, targets.primary:random())
end

local HEALTH = 80

local function ai(id)
    local l = list(
        ability("attack"),
        ability("attack"),
        function()
            local a = ability("stoneskin_oil")
            coroutine.yield(a, id)
        end
    )
    while get_stat("health/current", id) > HEALTH / 2 do
        local a = l:head()
        l = l:cycle(1)
        if type(a) == "function" then
            a()
        else
            submit_ability(id, a)
        end
    end

    while true do
        submit_ability(id, ability("thawing_blast"))
        submit_ability(id, ability("attack"))
        submit_ability(id, ability("hailstorm"))
    end

    return ai(id, blast_done)
end


local actor = {}

actor.__index = actor
actor = setmetatable(actor, actor)

function actor.init_visual(state, id)
    local function create_sprite()
        local function draw(self, x, y, r, sx, sy)
            local r, g, b, a = unpack(self.color)
            gfx.setColor(0.7 * r, 0.7 * g, 0.1 * b, a)
            local amp = self.shake_data.amp
            local phase = self.shake_data.phase
            x = x + self.spatial.x + math.sin(phase) * amp
            y = y + self.spatial.y
            sx = sx or 1
            sy = sy or 1
            sx = sx * self.scale
            sy = sy * self.scale

            local w, h = 40 * sx, 100 * sy
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
    state.health.max[id] = HEALTH
    state.power[id] = 0
    state.agility[id] = 0
    state.armor[id] = 0
    state.script[id] = coroutine.wrap(ai)
    state.name[id] = "Mega Boxer"
end

return actor
