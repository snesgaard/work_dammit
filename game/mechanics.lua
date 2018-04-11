local Node = require "game/node"

local rng = love.math.random

local Attack = {}

function Attack.create()
    return {crit_roll = rng()}
end

function Attack:__tostring()
    return "Attack"
end

function Attack:map(state, src, dst, damage)
    local info = {
        src = src,
        dst = dst,
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

function Heal:__tostring()
    return "Heal"
end

function Heal:map(state, src, dst, heal)
    local info = {
        src = src,
        dst = dst,
        heal = heal
    }
    local hp = state:get("health/" .. dst)
    local maxhp = state:get("max_health/" .. dst)
    info.heal = math.min(maxhp - hp, info.heal)
    return state:set("health/" .. dst, hp + info.heal), info
end

local TurnOrder = {}

function TurnOrder:__tostring()
    return "TurnOrder"
end

function TurnOrder:map(state)
    local agility = state:get("agility")
    self.__rng = {}
    for id, _ in pairs(agility) do
        self.__rng[id] = rng()
    end
    local order = agility:keys():sort(function(a, b)
        local va = agility[a] + self.__rng[a]
        local vb = agility[b] + self.__rng[b]
        return va < vb
    end)
    return state:set("turn/order", order)
end

local NewTurn = {}

function NewTurn:map(state)
    return state
        :set("turn/order", List.create())
        :set("turn/actions", List.create())
        :set("turn/targets", List.create())
end

local AddAction = {}

function AddAction:map(state, action, target)
    local actions = state:get("turn/actions")
    local targets = state:get("turn/targets")
    return state
        :set("turn/actions", actions:insert(action))
        :set("turn/targets", targets:insert(target))
end

local ActionExecuted = {}

function ActionExecuted:map(state)
    return state
        :set("turn/actions", state:get("turn/actions"):erase())
        :set("turn/targets", state:get("turn/targets"):erase())
        :set("turn/order", state:get("turn/order"):erase())
end

return {
    Attack = Attack,
    Heal = Heal,
    TurnOrder = TurnOrder,
    NewTurn = NewTurn,
    AddAction = AddAction,
    ActionExecuted = ActionExecuted
}
