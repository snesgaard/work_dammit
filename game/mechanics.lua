local Node = require "game/node"

local rng = love.math.random

local Attack = {}
--Attack.__index = Attack
--

function Attack.create()
    local this = {
        crit_roll = rng()
    }
    return setmetatable(this, Attack)
end

function Attack:__map(state, src, dst, damage)
    local info = {
        damage = damage,
        crit = self.crit_roll < 0.2
    }
    if info.crit then
        info.damage = info.damage * 2
    end

    local hp = state:get("health/" .. dst)
    return state:set("health/" .. dst, math.max(hp - info.damage, 0)), info
end

local Heal = {}

function Heal:__map(state, src, dst, heal)
    local info = {heal = heal}
    local hp = state:get("health/" .. dst)
    return state:set("health/" .. dst, hp + heal), info
end


local mechanics = {
    Attack = Attack,
    Heal = Heal
}

for key, val in pairs(mechanics) do
    val.__index = val
    val.create = val.create or function()
        return setmetatable({}, val)
    end
    mechanics[key] = setmetatable(val, {__index = Node})

end

return mechanics
