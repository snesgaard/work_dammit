local textbox = require "ui/labelbox"
local font = require "ui/fonts"

local announcer = {}

function announcer:test()
    self:queue("Enraged!")
    self:queue("balls!")
end

function announcer:create()
    self.__queue = list()
    self.textbox = self:child(textbox)
        :set_width(gfx.getWidth() * 0.3, gfx.getWidth() * 1.0)
        :set_theme("white")
        :set_font(font(20))

    self.__awake = event()

    self:__center()

    self:fork(self.__control)
end

function announcer:queue(message)
    if not message then return self end

    self.__queue[#self.__queue + 1] = message

    self.__awake()

    return self
end

function announcer:__center()
    local anchor = spatial(0, -5)
    local s = self.textbox:get_spatial()
        :xalign(anchor, "center", "center")
        :yalign(anchor, "bottom", "bottom")
    self.textbox:set_spatial(s)
    return self
end

function announcer:__control()
    self:wait(self.__awake)

    local function animation(msg)
        self.textbox:set_text(msg)
        self:__center()
        local h = self.textbox:get_spatial().h
        local tween = Timer.tween(
            0.2,
            {
                [self.textbox.__transform.pos] = {y = h + 15}
            }
        )
        self:wait(tween)

        self:wait(2.0)

        local tween = Timer.tween(
            0.2,
            {
                [self.textbox.__transform.pos] = {y = 0}
            }
        )
        self:wait(tween)
        self:wait(0.2)
    end

    while #self.__queue > 0 do
        local msg = self.__queue:head()
        self.__queue = self.__queue:erase(1)
        animation(msg)
    end

    return self:__control()
end

return announcer
