local Event = require "event"

local Graph = {}
Graph.__index = Graph

function Graph.create()
    local this = {
        __on_progress = Dictionary.create(),
        __on_regress  = Dictionary.create(),
        __graph = List.create()
    }
    return setmetatable(this, Graph)
end

function Graph:present()
    return self.__graph:tail()
end

function Graph:past()
    return self.__graph:head()
end

function Graph:on_progess(type, callback)
    local event = self.__on_progress[type]
    if not event then
        event = Event.create()
        self.__on_progress[type] = event
    end
    return event:listen(callback)
end

function Graph:__publish_progress(node)
    local type = node:type()
    local event = self.__on_progress[type]
    if not event then return end
    event(node:read(), node:info())
end

function Graph:progress(node)
    local tail = self.__graph:tail()
    local subgraph = node:link(tail)
    if not subgraph then
        log.warn("Unable to find path to main graph")
        return self
    end
    if tail then
        subgraph = subgraph:body()
    end
    for _, n in ipairs(subgraph) do
        self:__publish_progress(n)
    end
    self.__graph = List.concat(self.__graph, subgraph)
    return self
end

function Graph:on_regress(type, callback)
    local event = self.__on_regress[type]
    if not event then
        event = Event.create()
        self.__on_regress[type] = event
    end
    return event:listen(callback)
end

function Graph:__publish_regress(node)
    local type = node:type()
    local event = self.__on_regress[type]
    if not event then return end
    event(node:read(), node:info())
end

function Graph:regress(node)
    local subgraph = self.__graph:tail():link(node)
    if not subgraph then
        log.warn("Unable to find path in main graph")
        return self
    end
    subgraph = subgraph:reverse():body()
    for _, n in ipairs(subgraph) do
        self:__publish_regress(n)
    end

    self.__graph = node:link(self.__graph:head())
    return self
end

return Graph
