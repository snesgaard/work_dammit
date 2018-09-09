local frame = require "ui/frame"
local label = require "ui/label"
local fonts = require "ui/fonts"
local spatial = require "spatial"

local button = {}

function button:test()
    self:set_spatial(spatial.create(0, 0, 150, 30))
    self:set_text("Button")
    self:set_state(self.selected)
end

button.selected = {}
button.normal = {}

local THEME = {
    white = {1, 1, 1},
    blue = {0.8, 0.9, 1.0}
}

function button:create(text, theme)
    theme = theme or "white"
    self.theme = THEME[theme]
    if not self.theme then
        self.theme = theme.white
        log.warn("Theme %s not found", theme)
    end
    self.frame = frame.create():set_color(unpack(self.theme))
    self.label = label.create()
        :set_text(text or "")
        :set_font(fonts(14))
end

function button:get_theme()
    return {unpack(self.theme)}
end

function button:draw(x, y, ...)
    self.frame:draw(x, y, ...)
    gfx.setColor(0, 0, 0)
    self.label:draw(x, y, ...)
    if self.theme == THEME.blue then
        gfx.setColor(0.2, 0.4, 0.8)
        local fx, fy, w, h = self.frame.spatial:unpack()
        gfx.setLineWidth(2)
        gfx.rectangle("line", x + fx, y + fy, w, h, self.frame.corner)
    end
end

function button:set_text(text)
    self.label:set_text(text)
    return self
end

function button:set_spatial(spatial)
    self.frame:set_spatial(spatial)
    self.label:set_spatial(spatial)
    self.spatial = Spatial.create(spatial:unpack())
    return self
end

function button:get_spatial()
    return self.spatial
end

function button.selected.enter(self)
    self.frame.color = self:get_theme()
    self.frame:set_spatial(self.spatial:copy())
    if not self.animation then
         self.animation = self:fork(self.selected.animate)
    end
end

function button.selected.animate(self)
    local spatial = Spatial.create(self.spatial:unpack())
    local tween = Timer.tween(0.1, {
        [self.frame.spatial] = spatial:expand(5, 5),
        [self.frame.color] = {1, 1, 0}
    })
    self:wait(tween)
    tween = Timer.tween(0.1, {
        [self.frame.spatial] = spatial,
        [self.frame.color] = {1, 1, 0.45}
    })
    self:wait(tween)
    while true do
        tween = Timer.tween(0.5, {[self.frame.color] = {1, 1, 0.2}})
        self:wait(tween)
        tween = Timer.tween(0.5, {[self.frame.color] = {1, 1, 0.45}})
        self:wait(tween)
        self:wait(0.5)
    end
end


function button.normal.enter(self)
    if self.animation then
        self:join{self.animation}
        self.animation = nil
    end

    self.frame.color = self:get_theme()
    self.frame:set_spatial(self.spatial:copy())
end

return button
