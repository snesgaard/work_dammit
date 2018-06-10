local List       = require "list"
local Dictionary = require "dictionary"
local Event      = require "event"
local Spatial    = require "spatial"
local json       = require "modules/json"

local Frame = {}
Frame.__index = Frame

function Frame.create(quad, ox, oy, t)
    local this = {quad = quad, ox = ox, oy = oy, time = t, hitbox = {}}
    return setmetatable(this, Frame)
end

local Sprite = {}
Sprite.__index = Sprite

function Sprite:__tostring()
    return string.format("Sprite <%s>", self.atlas.path)
end

function Sprite.create(atlas, aliases)
    local this = {
        aliases = aliases,
        atlas = atlas,
        animation = "none",
        frames = nil,
        time = 0,
        f = 1,
        color = {255, 255, 255, 255},
        loop = "repeat",
        spatial = Spatial.create(),
        on_completed = Event.create(),
        on_frame_changed = Event.create(),
        on_animation_changed = Event.create()
    }
    return setmetatable(this, Sprite)
end

function Sprite:set_animation(name)
    if self.aliases then
        name = self.aliases[name]
    end
    local frames = self.atlas:get_animation(name)
    if not frames then
        log.warn("Animation <%s> is not defined", name)
    end
    self.animation = name
    self.frames = frames
    self.time = frames:head().time
    self.f = 1
    self.on_animation_changed(name)
    return self
end

function Sprite:set_loop(loop)
    self.loop = loop
    return self
end

function Sprite.set_color(r, g, b, a)
    self.color = {r, g, b, a}
    return self
end

function Sprite:set_frame(f)
    self.f = f
    if self.frames:size() < self.f then
        -- Throw end of animation event
        self.on_completed()
        if self.loop == "once" then
            return
        elseif self.loop == "repeat" then
            self.f = 1
        end
    else
        self.on_frame_changed(self.f)
        -- Throw end of frame
    end
    -- Throw animation hitbox info here
    return self
end

function Sprite:next_frame()
    return self:set_frame(self.f + 1)
end

function Sprite:set_time(time)
    self.time = time
    return self
end

function Sprite:set_origin(origin)
    self.origin = origin
    return self
end

function Sprite:refresh_time()
    local frame = self.frames[self.f]
    return self:set_time(self.time + frame.time)
end

function Sprite:update(dt)
    self.time = self.time - dt
    if self.time < 0 then
        self:next_frame()
            :refresh_time()
        return self:update(0)
    end
    return self
end

function Sprite:draw(x, y, r, sx, sy)
    gfx.setColor(unpack(self.color))
    x = x + self.spatial.x
    y = y + self.spatial.y
    self.atlas:draw(self.frames[self.f], self.origin, x, y, r, sx, sy)
end

local Atlas = {}
Atlas.__index = Atlas

function Atlas:__tostring()
    return string.format("Atlas <%s>", self.path)
end

function Atlas.create(path)
    local sheet = gfx.newImage(path .. "/atlas.png")
    local index = require (path   .. "/index")

    local this = {
        frames = Dictionary.create(),
        tags   = Dictionary.create(),
        slices = Dictionary.create(),
        sheet  = sheet,
        normal = normal,
        path = path,
    }

    local function calculate_border(lx, ux) return lx + ux end

    local dim = {sheet:getDimensions()}
    for name, positional in pairs(index) do
        local data_path = path .. '/' .. positional.data
        local data = json.decode(love.filesystem.read( data_path ))
        local frames = List.create()
        for _, f in ipairs(data.frames) do
            local x = f.frame.x + positional.x + 1
            local y = f.frame.y + positional.y + 1
            local w, h = f.frame.w - 2, f.frame.h - 2
            local quad = gfx.newQuad(x + 0.5, y + 0.5, w, h, unpack(dim))
            local dt = f.duration / 1000.0
            local ox, oy = f.spriteSourceSize.x, f.spriteSourceSize.y
            frames[#frames + 1] = Frame.create(quad, ox, oy, dt)
        end
        for _, slice in pairs(data.meta.slices) do
            for _, k in ipairs(slice.keys) do
                k.bounds.cx = k.bounds.x + k.bounds.w * 0.5 - 0.5
                k.bounds.cy = k.bounds.y + k.bounds.h - 0.5
                frames[k.frame + 1].hitbox[slice.name] = k.bounds
            end
            local defaults = {}
            for _, f in ipairs(frames) do
                for key, val in pairs(defaults) do
                    f.hitbox[key] = f.hitbox[key] or val
                end
                for key, val in pairs(f.hitbox) do
                    defaults[key] = val
                end
            end
        end
        local tags = Dictionary.create()
        for _, tag in pairs(data.meta.frameTags) do
            tags[tag.name] = tag
        end
        this.frames[name] = frames
        this.tags[name] = tags
    end

    return setmetatable(this, Atlas)
end

function Atlas:get_animation(name)
    local name, tag_name = unpack(string.split(name, '/'))
    print(name, tag_name, self.tags[name][tag_name])
    local frames = self.frames[name]
    if not tag_name then return frames end
    local tag = self.tags[name][tag_name]
    if not tag then return frames end
    return frames:sub(tag.from + 1, tag.to + 1)
end

function Atlas:sprite(aliases)
    return Sprite.create(self, aliases)
end

function Atlas:draw(frame, origin, x, y, r, sx, sy)
    local cx, cy = 0, 0
    if origin and frame.hitbox[origin] then
        local center = frame.hitbox[origin]
        cx, cy = center.cx, center.cy
    end
    gfx.draw(
        self.sheet, frame.quad, x,  y, r, sx, sy, -frame.ox + cx, -frame.oy + cy
    )
end

return Atlas
