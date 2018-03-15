require "math"

local Vec2Master = {}
Vec2Master.__index = Vec2Master

local Vec2 = {}
Vec2.__index = Vec2

function Vec2.__tostring(v)
    return string.format("[%i, %i]", v[1], v[2])
end

function Vec2Master.create(x, y)
  return setmetatable({x, y}, Vec2)
end

function Vec2:__call(x, y)
    return Vec2Master.create(x, y)
end

function Vec2.add(v1, v2)
  return Vec2Master.create(v1[1] + v2[1], v1[2] + v2[2])
end

function Vec2.dot(v1, v2)
  if type(v2) == "number" then
    return Vec2Master.create(v2 * v1[1], v2 * v1[2])
  else
    return Vec2Master.create(v2[1] * v1[1], v2[2] * v1[2])
  end
end

function Vec2.rotate(v1, a)
    local cosa, sina = math.cos(a), math.sin(a)
    local x = cosa * v1[1] - sina * v1[2]
    local y = sina * v1[1] + cosa * v1[2]
    return Vec2Master.create(x, y)
end

function Vec2.sub(v1, v2)
  return v1:add(v2:dot(-1))
end

function Vec2.length(v1)
  return math.sqrt(v1[1] * v1[1] + v1[2] * v1[2])
end

function Vec2.normalize(v1)
  return Vec2.dot(v1, 1.0 / v1:length())
end

setmetatable(Vec2Master, Vec2Master)
return Vec2Master.create(0,0)
