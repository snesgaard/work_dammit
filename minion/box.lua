local sprite = require "animation/sprite"
local animation = {}

function animation.idle(sprite, dt)
    sprite:loop(dt, "bat")
end

local box = {}

function box:create(manager, id, damage, caster)
    self.sprite = sprite.create(get_atlas("art/props"), animation)
        :set_animation("idle")

    self.damage = damage or 0
    self.caster = caster

    manager:on_turn_end(id, self.on_turn_end)
end

function box.on_turn_end(handle, self, master)
    nodes.announcer:push("Bats")
    handle:wait(0.4)
    local info = nodes.game:true_damage(self, master, self.damage)
    if nodes.game:is_alive(self.caster) then
        nodes.game:true_heal(self, self.caster, info.damage)
    end
end

function box:__update(dt)
    self.sprite:update(dt)
end

function box:__draw(x, y)
    self.sprite:draw(x, y)
end

return box
