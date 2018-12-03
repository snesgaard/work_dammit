local index = {
    manager = {
        charge = require "sfx/charge_manager",
    }
}

local function create_joined_type(types)
    local type = {}

    function type:create()
        self.count = 0
        self.on_finish = event()

        local function callback()
            self.count = self.count + 1
            if self.count >= #types then
                self:destroy()
                self.on_finish()
            end
        end

        for _, t in pairs(types) do
            local c = self:child(require(t))
            c.on_finish:listen(callback)
        end
    end

    return type
end

function index:__call(...)
    local args = list(...)
        :map(function(p) return 'sfx.' .. p end)

    if #args == 1 then
        return require(args:head())
    else
        return create_joined_type(args)
    end
end

return setmetatable(index, index)
