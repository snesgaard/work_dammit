local Executor = {}
Executor.__index = Executor

function Executor.create()
    local this = {__group = {}}
    return setmetatable(this, Executor)
end

function Executor:__run(graph, action, actor, args, skip)
    skip = skip or false
    -- If args is a function, execute it to obtain actual args
    if type(args) == "function" then
        args = {args(graph, actor)}
    end
    -- Get the initiali noce
    local init_node = graph:present()
    -- Calcuate the end node
    local end_node = action.map(init_node, actor, unpack(args))
    if not skip then
        -- Run the animation
        local anime = Animation.animate(action, Executor.__group)
        anime:run(self.visualstate, self.graph, end_graph)
        -- Wait for either a skip event or the naimation to finish
        local arg = event.wait(anime.on_finish, self.on_skip)
        -- return true if the animation was skipped
        skip = arg.event == self.on_skip
    end
    if skip then
        graph:progress(end_node)
    end
    return skip
end

function Executor:run(graph, actions, actors, args)
    if istype(List, actions) then
        local skip = false
        for _, a in pairs(List.zip(actions, actors, args)) do
            local action, actor, arg = unpack(a)
            skip = self:__run(graph, action, actor, arg, skip)
        end
    else
        self:__run(graph, actions, actors, args)
    end
end

function Executor:update(dt)
    Animation.update(dt, self.__group)
end

function Executor:draw()
    Animation.draw(self.__group)
end

return Executor
