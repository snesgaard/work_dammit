local Vec2 = require "vec2"
local dict = require "dictionary"
local Event      = require "event"
local Spatial    = require "spatial"

local rng = love.math.random

local Sprite = {}
Sprite.__index = Sprite

function Sprite.__tostring()
    return "Sprite"
end

function Sprite:draw(x, y, r, sx, sy)
    if not self.__draw_frame then return end
    gfx.setColor(unpack(self.color))
    local amp = self.shake_data.amp
    local phase = self.shake_data.phase
    x = x + self.spatial.x + math.sin(phase) * amp
    y = y + self.spatial.y
    sx = sx or 1
    sy = sy or 1
    sx = sx * self.scale * self.__mirror
    sy = sy * self.scale
    self.atlas:draw(self.__draw_frame, self.origin, x, y, r, sx, sy)
end

function Sprite.__on_frame_progress() end

function Sprite.__on_frame_motion() end

--function Sprite.__on_hitbox()
--
--end

function Sprite:__get_motion(frames, frame_index, origin, mirror, scale)
    origin = origin or self.origin
    mirror = mirror or self.mirror
    scale = scale or self.scale

    local prev_frame = frames[frame_index - 1]
    local next_frame = frames[frame_index]

    if not prev_frame or not next_frame then
        return vec2(0, 0)
    end

    local prev_pos = prev_frame.hitbox[origin]
    local next_pos = next_frame.hitbox[origin]

    local function get_center(pos)
        if not pos then
            return vec2(0, 0)
        else
            return vec2(pos.x + pos.w * 0.5, pos.y + pos.h * 0.5)
        end
    end

    local motion = get_center(next_pos) - get_center(prev_pos)

    return motion * mirror * scale
end

function Sprite:play(dt, frame_key)
    local frames = self.atlas:get_animation(frame_key)
    for i = 1, frames:size() do
        local f = frames[i]
        self.__draw_frame = f
        self.time = self.time + f.time

        local hitboxes = self:get_hitboxes()
        self.on_hitbox(hitboxes)
        self.__on_frame_progress(self, i, f, hitboxes)

        local motion = self:__get_motion(
            frames, i, self.origin, self.__mirror
        )
        self.__on_frame_motion(self, motion)

        while self.time > 0 do
            _, dt = coroutine.yield()
            self.time = self.time - dt
        end

    end
    self.on_loop()

    return dt
end


function Sprite:hide()
    Timer.tween(
        0.4,
        {
            [self.color] = {[4] = 0}
        }
    )
end

function Sprite:show()
    Timer.tween(
        0.4,
        {
            [self.color] = {[4] = 1}
        }
    )
end

function Sprite:get_hitboxes(x, y)
    if not self.__draw_frame then return end

    x = (x or 0) + self.spatial.x
    y = (y or 0) + self.spatial.y

    local frame = self.__draw_frame

    local function get_center()
        local origin = frame.hitbox[self.origin]
        if origin then
            return origin.cx, origin.cy
        else
            return 0, 0
        end
    end

    local cx, cy = get_center()

    local ret = dict.create()

    for key, box in pairs(frame.hitbox) do
        ret[key] = spatial(box.x, box.y, box.w, box.h)
            :move(-cx, -cy)
            :scale(self.scale, self.scale)
            :map(function(s)
                if self.__mirror < 0 then
                    return s:hmirror(0, 0)
                else
                    return s
                end
            end)
            :move(x, y)
    end

    return ret
end

function Sprite:shake(strong)
    if self.shake_data.tween then
        self.shake_data.tween:remove()
    end
    local s = rng() > 0.5 and 1 or -1
    self.shake_data.amp = strong and 15 or 5
    self.shake_data.phase = s * math.pi * 8
    self.shake_data.tween = Timer.tween(
        0.4,
        {
            [self.shake_data] = {amp = 0, phase = 0},
        }
    )
end

function Sprite:loop(dt, frame_key)
    while true do
        dt = self:play(dt, frame_key)
    end
end

function Sprite:register(key, animation)
    self.__states[key] = animation
end

function Sprite:set_animation(a, ...)
    local s = self.__states[a]
    if s then
        self.time = 0
        local prev_state = self.state
        self.state = s
        self.active = coroutine.wrap(
            function(sprite, dt)
                s(sprite, dt, prev_state)
                self.active = nil
            end
        )
        return self
    elseif a then
        log.warn("Animation %s was not found", a)
        return self:set_animation(...)
    else
        return self
    end
end

function Sprite:set_origin(origin)
    self.origin = origin
end

function Sprite:update(dt)
    if self.active then
        self.active(self, dt)
    end
    return self
end

function Sprite:attack_offset()
    return 0
end

function Sprite:set_color(r, g, b, a)
    self.color = {r or 1, g or 1, b or 1, a or 1}
    return self
end

function Sprite:set_mirror(val)
    local prev_mirror = self.__mirror

    if not val then
        self.__mirror = -self.__mirror
    else
        self.__mirror = val
    end

    if prev_mirror ~= self.__mirror then
        local hitboxes = self:get_hitboxes()
        self.__on_hitbox(hitboxes)
    end
end

function Sprite.create(atlas, animes)
    local this = {
        time = 0,
        atlas = atlas,
        __states = {},
        active = nil,
        origin = 'origin',
        __mirror = 1,
        spatial = Spatial.create(),
        color = {1, 1, 1, 1},
        scale = 2,
        on_user = Event.create(),
        on_loop = Event.create(),
        on_hitbox = Event.create(),
        shake_data = {amp = 0, phase = 0},
        __hitbox_cache = {}
    }
    this = setmetatable(this, Sprite)
    animes = animes or {}

    for k, v in pairs(animes) do
        this:register(k, v)
    end

    return this
end

return Sprite
