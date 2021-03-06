local ease = require "ease"
local slash = require "sfx/slash"
local sfx = require "sfx"

return function(handle, attacker, target, on_strike, stay, impact_sfx)
    stay = stay or false
    impact_sfx = impact_sfx or sfx('slash')
    local pa = nodes.position:get_world(attacker)
    local pt = nodes.position:get_world(target)

    local sa = visual.sprite[attacker]
    local st = visual.sprite[target]
    local s = pa.x > pt.x and -1 or 1
    local so = vec2(sa.spatial.x, sa.spatial.y)
    local offset = pt - pa - s * vec2(sa:attack_offset(), 0)


    local speed = 1200.0
    local in_time = (0.75 * (offset - so):length() + 100) / speed
    local out_time = (0.75 * (offset):length() + 100) / speed
    sa:set_animation("dash")

    handle:wait(
        Timer.tween(
            in_time,
            {
                [sa.spatial] = {x = offset.x, y = offset.y}
            }
        )
        :ease(ease.sigmoid)
    )

    sa:set_animation("attack")

    local function wait_for_user_event(tag)
        local timeout = 0.7
        local event_args = handle:wait(sa.on_user, timeout)
        if event_args.event == "timeout" then
            log.warn("Animation waiting timed out")
            return
        elseif event_args[1] ~= tag then
            return wait_for_user_event(tag)
        end
    end

    wait_for_user_event("attack")
    --nodes.game:damage(attacker, target, DAMAGE)
    on_strike(handle, attacker, target)
    local pos = nodes.position:get_world(target) - vec2(0, 100)
    local sfx_node = nodes.sfx:child(impact_sfx)
    sfx_node.__transform.pos = pos
    wait_for_user_event("done")

    if not stay then
        sa:set_animation("evade")
        handle:wait(
            Timer.tween(
                out_time,
                {
                    [sa.spatial] = {x = 0, y = 0}
                }
            )
            :ease(ease.sigmoid)
        )
        sa:set_animation("idle")
    end
end
