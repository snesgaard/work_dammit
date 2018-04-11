local List       = require "list"
local Dictionary = require "dictionary"
local Event      = require "event"
local Spatial    = require "spatial"

local Frame = {}
Frame.__index = Frame

function Frame.create(arg, t)
    local quad, ox, oy = unpack(arg)
    return setmetatable({quad = quad, ox = ox, oy = oy, time = t}, Frame)
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
    self.atlas:draw(self.frames[self.f], x, y, r, sx, sy)
end

local Atlas = {}
Atlas.__index = Atlas

function Atlas:__tostring()
    return string.format("Atlas <%s>", self.path)
end

function Atlas.create(path)
    local sheet = gfx.newImage(path .. "/sheet.png")
    local status, normal = pcall(function()
        return gfx.newImage(path .. "/normal.png")
    end)
    local hitboxes = require (path .. "/hitbox")
    local info = require (path   .. "/info")

    local this = {
        frames = Dictionary.create(),
        sheet  = sheet,
        normal = normal,
        path = path,
    }

    local function calculate_border(lx, ux) return lx + ux end

    local function create_quad(y, h, sheet)
        return function(arg)
            local x, w = unpack(arg)
            return gfx.newQuad(x + 0.5, y + 0.5, w, h, sheet:getDimensions())
        end
    end

    for name, positional in pairs(info) do
        local hitbox = hitboxes[name]
        local widths = List.create(unpack(hitbox.frame_size))
        local frames = #widths
        local borders = widths
            :scan(calculate_border, positional.x)
            :insert(positional.x, 1)
            :sub(1, -1)
        local x = positional.x
        local y = positional.y
        local h = positional.h
        local frames = List.zip(borders, widths)
            :map(create_quad(y, h, sheet))
            :zip(hitbox.offset_x, hitbox.offset_y)
            :map(function(arg) return Frame.create(arg, hitbox.time) end)
        this.frames[name] = frames
    end

    return setmetatable(this, Atlas)
end

function Atlas:get_animation(name)
    return self.frames[name]
end

function Atlas:sprite(aliases)
    return Sprite.create(self, aliases)
end

function Atlas:draw(frame, x, y, r, sx, sy)
    gfx.draw(self.sheet, frame.quad, x,  y, r, sx, sy, frame.ox, frame.oy)
end

return Atlas
