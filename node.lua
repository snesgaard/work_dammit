local default_group = {}
local Node = {}

local Handle = {}
Handle.__index = Handle

function Handle.create()
    local this = {}
    return setmetatable(this, Handle)
end

function Handle:set_co(co, group)
    self.co = co
    self.group = group
end

function Handle:remove()
    Node:remove(self, group)
end

function Node.remove(handle, group)
    group = group or default_group
    group[handle] = nil
end

function Node.run(arg)
    -- Obtain the function
    local f = arg[1]
    -- Reformat numeric args to by unpackable
    for i = 1, #arg do
        arg[i] = arg[i + 1]
    end
    local group = arg.group or default_group
    local handle = Handle.create()
    -- Create process that autocleans at the end
    local function process()
        f(unpack(arg))
        handle:remove()
    end
    local co = coroutine.create(process)
    handle:set_co(co, group)
    group[handle] = true
    coroutine.resume(co)
    return handle
end
