local ripple = {}

function ripple:create(lifetime, width, sfunction)
    self.lifetime = lifetime or 1
    self.sfunction = sfunction or 2
    self.width = width or 100
    self.time = 0
end

function ripple:__update(dt)
    self.time = self.time + dt

    if self.time > self.lifetime then
        self:destroy()
    end
end

local function load_shaders()
    local path = "post_process/ripple.glsl"
    local s = love.filesystem.read(path)
    if not s then
        log.warn("No shader file <%s>", path)
        return
    end
    local circle = "#define CIRCLE\n" .. s
    local displace = s
    return dict{
        displace = gfx.newShader(displace),
        circle = gfx.newShader(circle),
    }
end

local manager = {}

function manager:create()
    self.blank = gfx.newCanvas(1000,1000)
    self.displace = gfx.newCanvas(gfx.getWidth(), gfx.getHeight())
    self.shaders = load_shaders()

    nodes.root.mousepressed:listen(function(x, y)
        self:ripple(x, y)
    end)
end

function manager:ripple(x, y, lifetime, width, sfunction)
    local child = self:child(
        ripple, lifetime or 500, width or 50, sfunction or 0.16
    )
    child.__transform.pos.x = x
    child.__transform.pos.y = y
    return child
end

function manager:draw(canvas, x, y)
    gfx.setShader(self.shaders.circle)
    local prev_canvas = gfx.getCanvas()
    gfx.setCanvas(self.displace)
    gfx.clear()
    for _, node in ipairs(self.__node_order) do
        local shader = self.shaders.circle
        shader:send("time", node.time * 1000) -- sends time to shader
        shader:send("sfunction", node.sfunction) -- sends time to shader
        shader:send("swidth", node.width) -- sends some variables to shader
        shader:send("fall", 1 - ((node.time * 1000 + node.width) / 500) ^ 6)
        gfx.setBlendMode("screen", "premultiplied") --Some blend mode
        local pos = node.__transform.pos
        gfx.draw(self.blank, pos.x, pos.y, 0, 1, 1, 500, 500) --the actual drawing
        gfx.setBlendMode("alpha")
    end
    gfx.setCanvas(prev_canvas)

    gfx.setShader(self.shaders.displace) -- seting displacement shader
	self.shaders.displace:send("canvas", self.displace)
    gfx.draw(canvas, x, y)
end

return manager
