local dict = Dictionary.create
local rng = love.math.random

local function create_actor_state()
    return dict{
        health = dict{
            max = dict{}, current = dict{}
        },
        ability = dict{},
        power = dict{},
        defense = dict{},
        agility = dict{},
        script = dict{}
    }
end


local function create_events()
    return dict{
        on_damage = Event.create(),
        on_heal = Event.create(),
    }
end


local State = {}
State.__index = State


function State:create()
    self.actor = create_actor_state()
    self.event = create_events()
end

function State:is_alive(id)
    local hp = self.actor.health.current[id]
    return hp and hp > 0
end

function State:damage(attacker, defender, damage)
    local power = self.actor.power[attacker]
    damage = math.max(0, damage + power)
    local hp = self.actor.health.current[defender]
    local next_hp = math.max(0, hp - damage)

    self.actor.health.current[defender] = next_hp

    local effective_damage = hp - next_hp

    local info = dict{
        attacker = attacker,
        defender = defender,
        damage = effective_damage
    }

    self.event.on_damage(info)

    return info
end

function State:heal(caster, target, heal)
    local power = self.actor.power[caster] or 0
    heal = math.max(0, heal + power)
    local hp = self.actor.health.current[target]
    local max_hp = self.actor.health.max[target]
    local next_hp = math.clamp(hp + heal, 0, max_hp)

    self.actor.health.current[target] = next_hp

    local effective_heal = next_hp - hp

    local info = dict{
        caster = caster,
        target = target,
        heal = effective_heal
    }

    self.event.on_heal(info)

    return info
end

return State
