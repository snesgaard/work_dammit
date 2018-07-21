local charge_sfx = require "sfx/charge"
local shield_sfx = require "sfx/shield"

local manager = {}

function manager:create_callback(sfx)
    local cache = {}
    return function(id, value)
        if value > 0 and not cache[id] then
            local n = self:child(sfx)
            n.id = id
            cache[id] = n
        elseif value == 0 and cache[id] then
            local n = cache[id]
            n:halt()
            cache[id] = nil
        end
    end
end

local function order_func(a, b)
    local va = istype(a, charge_sfx) and 0 or 1
    local vb = istype(b, charge_sfx) and 0 or 1
    return va < vb
end

function manager:create()
    nodes.game:monitor_stat("charge", self:create_callback(charge_sfx))
    nodes.game:monitor_stat("shield", self:create_callback(shield_sfx))
end

function manager:draw()
    for _, node in pairs(self.__node_order) do
        local pos = vec2(0, 0)
        if node.id then
            pos = nodes.position:get_world(node.id)
        end
        local s = visual.sprite[node.id]
        if s then
            pos.x = pos.x + s.spatial.x
            pos.y = pos.y + s.spatial.y
        end
        node:draw(pos.x, pos.y)
    end
end

return manager
