local sfx = {}

function sfx:create()

    self.count = 0

    local function callback()
        self.count = self.count + 1
        if self.count >= 2 then
            self:destroy()
        end
    end

    self.sparks = self:child(require "sfx/sparks")
    self.sparks.on_finish:listen(callback)
    self.impact = self:child(require "sfx/impact")
    self.impact.on_finish:listen(callback)
end

return sfx
