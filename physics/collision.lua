local collision = {}

function collision.miss_box(b1, b2)
    local function get_corners(b)
        return b:corner("left", "top"), b:corner("right", "bottom")
    end

    local tl1, br1 = get_corners(b1)
    local tl2, br2 = get_corners(b2)

    local miss_x = tl1.x > br2.x or tl2.x > br1.x
    local miss_y = tl1.y > br2.y or tl2.y > br1.y

    return miss_x, miss_y
end

function collision.detect(boxes)
    boxes = boxes:sort(function(b1, b2)
        return b1.x < b2.x
    end)

    local size = boxes:size()
    local collision_map = dict()

    local function handle_detection(b1, b2)
        local miss_x, miss_y = collision.miss_box(b1, b2)

        if not miss_x and not miss_y then
            local l1 = collision_map[b1] or list()
            collision_map[b1] = l1:insert(b2)
            local l2 = collision_map[b2] or list()
            collision_map[b2] = l2:insert(b1)
        end

        return miss_x
    end

    for i = 1, size do
        local b1 = boxes[i]
        for j = i + 1, size do
            local b2 = boxes[j]
            if handle_detection(b1, b2) then
                break
            end
        end
    end

    return collision_map
end

local once_registry = dict()

function collision.once(...)
    local co = coroutine.running()
    once_registry[co] = list(...)
    return coroutine.yield()
end

local box_registry = nil
local box2callback = dict()

function collision.add(box, callback)
    box2callback[box] = callback
    box_registry = nil
end

function collision.remove(box, callback)
    box2callback[box] = nil
    box_registry = nil
end

local _prev_boxes = list()

function collision.update()
    box_registry = box_registry or box2callback:keys()
    local boxes = list()

    for i, box in pairs(box_registry) do
        boxes[#boxes + 1] = box
    end

    for co, __boxes in pairs(once_registry) do
        for _, b in pairs(__boxes) do
            boxes[#boxes + 1] = b
        end
    end
    _prev_boxes = boxes
    local res = collision.detect(boxes)

    local reg = once_registry
    once_registry = dict()
    for co, __boxes in pairs(reg) do
        local __res = __boxes:map(function(b) return res[b] end)
        coroutine.resume(co, __res:unpack())
    end

    for box, cb in pairs(box2callback) do
        local __res = res[box] or {}
        for _, b in pairs(__res) do
            cb(b)
        end
    end
end

function collision.draw(x, y)
    for _, b in pairs(_prev_boxes) do
        local _x, _y, w, h = b:unpack()
        gfx.rectangle("fill", _x + x, _y + y, w, h)
    end
end

return collision
