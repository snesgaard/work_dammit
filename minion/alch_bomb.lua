local sprite = require "animation/sprite"
local particles = require "sfx/particles"
local transform = require "transform"
local explosion = require "sfx/explode"
local ease = require "ease"
local animation = {}

local COUNT = 3

function animation.bomb(sprite, dt)
    sprite:loop(dt, "alch_bomb/normal")
end

function animation.explode(sprite, dt)
    sprite:play(dt, "alch_bomb/explode")
    if sprite.on_explode then sprite.on_explode() end
end

function animation.fuse3(sprite, dt)
    sprite:loop(dt, "fuse/stage3")
end

function animation.fuse2(sprite, dt)
    sprite:loop(dt, "fuse/stage2")
end

function animation.fuse1(sprite, dt)
    sprite:loop(dt, "fuse/stage1")
end

local bomb = {}

function bomb:test()
    self:wait(1.0)
    self.on_round_end(nil, self, nil)
    self:wait(1.0)
    self.on_round_end(nil, self, nil)
    self:wait(1.0)
    self.on_round_end(nil, self, nil)
end

function bomb:entry()
    local y = self.__transform.pos.y
    self.__transform.pos.y = -100
    local tween = Timer.tween(
        0.35,
        {
            [self.__transform.pos] = {y = y}
        }
    ):ease(ease.inQuad)
end

function bomb:create(manager, id, on_explosion)
    self.master = id
    self.manager = manager
    self.on_explosion = on_explosion
    self.sprites = {
        bomb = sprite.create(get_atlas("art/props"), animation)
                :set_animation("bomb"),
        fuse = sprite.create(get_atlas("art/props"), animation)
                :set_animation("fuse1"),
    }
    self.transform = transform()
    self.count = 1
    self.sparks = particles{
        image = "art/part2.png",
        buffer = 50,
        rate = 30,
        dir = -math.pi * 0.5,
        lifetime = 0.5,
        acceleration = {0, 500},
        size = 0.25,
        speed = 750,
        area = {"uniform", 5, 0, math.pi},
        color = {
            1.0, 0.8, 0.6, 1,
            1.0, 0.8, 0.6, 1,
            1.0, 0.8, 0.6, 1,
            1.0, 1.0, 0.6, 0
        },
        spread = math.pi,
        relative_rotation = true,
        rotation = math.pi * 0.5
    }

    self.offset = vec2(0, 0)
    self.sparks_pos = vec2(0, 0)

    self.sprites.bomb.on_hitbox:listen(function(boxes)
        self.transform:set("rope", boxes.rope:center():unpack())
    end)
    self.sprites.fuse.on_hitbox:listen(function(boxes)
        self.transform:set("fuse", boxes.spark:center():unpack())
    end)

    manager:on_round_end(id, self.on_round_end)
end

function bomb.activate(handle, self, master)

end

function bomb:spawn_explosion()
    return self:child(explosion)
end

function bomb.on_round_end(handle, self, master, active)
    if self.count >= 3 then
        return self:do_explosion(handle, master)
    else
        self.count = self.count + 1
        local anime = "fuse" .. self.count
        self.sprites.fuse:set_animation(anime)
    end
end

function bomb:do_explosion(handle, master)
    nodes.announcer:push("Unstable Bomb")
    self.sparks:stop()
    self.sprites.bomb.on_explode = event()
    self.sprites.bomb:set_animation("explode")

    self:wait(self.sprites.bomb.on_explode)

    self.on_explosion(handle, master)

    local tween = Timer.tween(
        0.25,
        {
            [self.sprites.bomb.color] = {1.0, 0, 0, 0},
            [self.sprites.fuse.color] = {1.0, 0, 0, 0}
        }
    )
    local explode = self:spawn_explosion()
    self:wait(tween)
    explode.on_done:listen(function()
        self.manager:set(master)
    end)
end

function bomb:__update(dt)
    for _, s in pairs(self.sprites) do
        s:update(dt)
    end
    self.sparks:update(dt)
end

function bomb:__draw(x, y)
    self.transform:draw("rope", function()
        self.sprites.fuse:draw(x, y)
    end)
    self.transform:draw("rope/fuse", function()
        gfx.draw(self.sparks)
    end)

    self.sprites.bomb:draw(x, y)
end


return bomb
