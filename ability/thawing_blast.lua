local target = require "ability/target"

local blast = {}

sap.target = {
    type = "single",
    primary = target.same_side,
    condition = {target.is_alive}
}
function blast.run(handle, caster, targets)

end

return blast
