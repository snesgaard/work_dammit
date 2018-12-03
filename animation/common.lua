local common = {}

function common.cast(handle, id, timeout)
    timeout = timeout or 10
    local sa = visual.sprite[id]

    sa:set_animation("chant")
    handle:wait(0.75)
    sa:set_animation("cast")

    local function wait_for_cast_hb(time_left)
        local start = love.timer.getTime()
        local eargs = handle:wait(sa.on_hitbox, time_left)
        local stop = love.timer.getTime()
        local hb = unpack(eargs)

        if eargs.event ~= sa.on_hitbox then
            log.warn("Cast hitbox did not appear after %3.3f", timeout)
            return spatial(0, 0, 0, 0)
        elseif hb.cast then
            local pos = nodes.position:get_world(id)
            return hb.cast:move(pos.x, pos.y)
        else
            return wait_for_cast_hb(time_left - stop + start)
        end
    end

    return wait_for_cast_hb(timeout), sa
end

return common
