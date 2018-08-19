local common = {}

function common.draw_grid(w, h)
    gfx.setColor(255, 255, 255, 255)
    gfx.setLineWidth(2)
    gfx.line(0, h * 0.5, w, h * 0.5)
    gfx.line(w * 0.5, 0, w * 0.5, h)
end

return common
