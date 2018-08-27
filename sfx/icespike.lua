local sprite = require "animation/sprite"

local SHARDS = 15

local ice = {}

function ice:test(settings)
    settings.origin = true
    local pos = vec2(gfx.getWidth() * 0.5, 450)
    self:fly(pos, "left")
    self:wait(self.on_impact)
    --self.__transform.pos = pos
    --self:shatter()
end

function ice:create()
    self.sprite = self:__create_sprite()
    self.shards = self:__create_shatter()
    self.shards:stop()

    self.on_impact = event()
    self.on_shattered = event()

    self.__sprite_angle = 0
end

function ice:__create_sprite()
    local atlas = get_atlas("art/props")

    local anime = {}
    function anime.spike(sprite, dt)
        sprite:loop(dt, "ice_spike/spike")
    end

    return sprite.create(atlas, anime):set_animation("spike")
end

function ice:__create_shatter()
    local particle = require "sfx/particles"
    local atlas = get_atlas("art/props")

    return particle{
        image = atlas.sheet,
        quad = atlas:get_animation("ice_spike/shard"):head().quad,
        buffer = SHARDS,
        lifetime = 0.75,
        rate = 1.0,
        spread = math.pi * 0.5,
        size = 2,
        speed = {600, 1000},
        dir = -math.pi * 0.75,
        acceleration = {0, 2000},
        color = {
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 0,
        },
        area = {"uniform", 10, 20}
    }
end

function ice:fly(pos, dir)
    self.__hide_sprite = false
    local get_dir = {}

    function get_dir.left()
        local offset = 100
        local dy = pos.x + offset
        return vec2(-offset - pos.y + dy, -offset), -math.pi * 0.25, -math.pi * 0.75
    end

    function get_dir.right()
        local w = gfx.getWidth()
        local offset = 100
        local dy = w - pos.x + offset
        return vec2(w + offset, pos.y - dy), -math.pi * 0.75, -math.pi * 0.25
    end

    function get_dir.generic()
        local w = gfx.getWidth()
        if pos.x > w * 0.5 then
            return get_dir.right()
        else
            return get_dir.left()
        end
    end

    local function do_fly()
        local start_pos = get_dir[dir] or get_dir.generic
        local speed = 3000
        local start_pos, dir, angle = start_pos()
        self.__sprite_angle = angle
        local time = (pos - start_pos):length() / speed
        self.__transform.pos = start_pos
        local tween = Timer.tween(
            time,
            {
                [self.__transform] = {pos = pos}
            }
        )
        self:wait(tween)
        self.on_impact()
        return self:shatter(dir)
    end

    self:fork(do_fly)
end

function ice:shatter(dir)
    self.__hide_sprite = true
    self.shards:start()
    self.shards:setDirection(dir)
    self.shards:emit(SHARDS)
    self.shards:stop()

    local function life()
        while self.shards:getCount() > 0 do
            self:wait_update()
        end
        self.on_shattered()
    end

    self:fork(life)
end

function ice:__update(dt)
    self.sprite:update(dt)
    self.shards:update(dt)
end


function ice:__draw()
    if not self.__hide_sprite then
        self.sprite:draw(0, 0, self.__sprite_angle)
    end
    gfx.setColor(1, 1, 1)
    gfx.draw(self.shards, 30, 0)
end

return ice
