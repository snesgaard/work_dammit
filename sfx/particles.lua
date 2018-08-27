local argmap = dict{
    move = "moveTo",
    lifetime = "setParticleLifetime",
    rate = "setEmissionRate",
    area = "setEmissionArea",
    spread = "setSpread",
    size = "setSizes",
    speed = "setSpeed",
    dir = "setDirection",
    damp = "setLinearDamping",
    color = "setColors",
    acceleration = "setLinearAcceleration",
    relative_rotation = "setRelativeRotation",
    rotation = "setRotation",
    quad = "setQuads",
    spin = "setSpin"
}

local function apply_api(particle, key, value)
    api = argmap[key]

    if not api then
        log.warn("Key %s not present in map", key)
        return
    end

    local f = particle[api]
    if not f then
        log.warn("Key is %s not a member", key)
        return
    end

    if type(value) == "table" then
        f(particle, unpack(value))
    else
        f(particle, value)
    end
end

return function(arg)
    local im = arg.image
    local buffer = arg.buffer

    if type(im) == "string" then
        im = gfx.newImage(im)
    end

    local p = gfx.newParticleSystem(im, buffer)

    for key, value in pairs(arg) do
        if key ~= "image" and key ~= "buffer" then
            apply_api(p, key, value)
        end
    end

    return p
end
