local battle_planner = {}
battle_planner.__index = battle_planner

function battle_planner.create(self)

end

function battle_planner.begin(self)
    self:fork(self.control)
end

local function is_alive(faction)
    local s = faction == "party" and 1 or -1
    return nodes.position.placements
        :filter(function(index, id)
            return s * index > 0
        end)
        :values()
        :map(function(id)
            return nodes.game:is_alive(id)
        end)
        :reduce(function(a, b) return a or b end)
end

function battle_planner.control(self)
    local actors = nodes.position.placements:values()
    nodes.round_planner:submit(actors)
    local battle_active = self:wait(nodes.round_planner.on_round_end)
    print("was done?", battle_active)

    local party_alive = is_alive("party")

    local enemy_alive = is_alive("enemy")

    if battle_active then
        return battle_planner.control(self)
    elseif nodes.round_planner:party_alive() then
        self.victory = "Victory"
    else
        self.victory = "Fail"
    end
end

function battle_planner.is_finished(self)
    local party_alive = is_alive("party")

    local enemy_alive = is_alive("enemy")

    return party_alive and enemy_alive
end

function battle_planner:__draw()
    local font = require "ui/fonts"
    gfx.setFont(font(60))
    if self.victory then
        if self.victory == "Fail" then
            gfx.setColor(1.0, 0.5, 0.2)
        else
            gfx.setColor(0.7, 0.9, 1.0)
        end
        gfx.printf(self.victory, gfx.getWidth() / 2 - 500, 50, 1000, "center")
    end
end

return battle_planner
