return coroutine.wrap(function(size)
    local fonts = {}
    while true do
        if not fonts[size] then
            --fonts[size] = gfx.newFont('res/font/Ubuntu-B.ttf', size)
            fonts[size] = gfx.newFont(size)
        end
        size = coroutine.yield(fonts[size])
    end
end)
