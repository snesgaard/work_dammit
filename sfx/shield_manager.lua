local shield_sfx = require "sfx/shield"

local manager = {}

function manager:create()
    self.id2child = dict{}
    nodes.game:monitor_stat("shield", function(id, value)
        self.id2child[id] = self:child(shield_sfx)
    end)
end

function manager:draw()
    for id, node in pairs(self.id2child) do
        local pos = nodes.position:get_world(id)
        node:draw(pos.x, pos.y)
    end
end

return manager
