local attack = require "ability/attack"

local Sprite = require "animation/sprite"

local BoxSprite = {}
BoxSprite.__index = BoxSprite

function BoxSprite.__tostring()
    return "BoxSprite"
end

function BoxSprite.create()
    local this = {
    }
    return setmetatable(this, BoxSprite)
end

function BoxSprite:draw(x, y, r, sx, sy)
    gfx.setColor(unpack(self.color))
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

function BoxSprite:set_origin() return self end

function BoxSprite:set_animation()
    return self
end

function BoxSprite:attack_offset() return 0 end

function BoxSprite:update() end

function BoxSprite:set_color(r, g, b, a)
    self.color = {r, g, b, a or 1}
    return self
end

local function attack_animation(self)
    self.on_user("attack")
    self.on_user("done")
end

local function create_sprite()
    local sprite = Sprite.create()
    sprite.draw = BoxSprite.draw
    sprite:register("attack", attack_animation)
    return sprite
end

local function ai(id)
    local side = nodes.position:get(id)
    local target = nodes.position.placements
        :values()
        :filter(function(a)
            return nodes.position:get(a) * side < 0
        end)
        :shuffle()
        :head()
    return attack, target
end

local box = {}
box.__index = box
box = setmetatable(box, box)

function box.__tostring()
    return "Box"
end

function box.init_visual(state, id)
    state.sprite[id] = create_sprite()
end

function box.init_state(state, id)
    state.health.max[id] = 8
    state.health.current[id] = 8
    state.power[id] = 1
    state.agility[id] = 1
    state.armor[id] = 3
    state.script[id] = ai
    state.name[id] = "Normal Box"
    visual.icon[id] = function(x, y, w, h)
        gfx.setColor(1, 1, 1)
        local margin = vec2(15, 5)
        gfx.rectangle("fill", x + 5, y + margin.y, w - margin.x, h - margin.y)
    end
end

return box
