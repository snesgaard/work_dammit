local Atlas = require "atlas"

local fencer = {}

local animation_aliases = {
    idle = "fencer_idle",
    attack = "fencer_attack",
    cast = "fencer_cast",
    dash = "fencer_dash",
    evade = "fencer_bdash",
}

function fencer.init_visual(state, id)
    local atlas_path = "res/sprites/misc"
    local atlas = state.atlas[atlas_path] or Atlas.create(atlas_path)
    local sprite = atlas:sprite(animation_aliases)
    local icon_path = "res/sprites/icon"
    local icon_atlas = state.atlas[icon_path] or Atlas.create(icon_path)

    state.atlas[atlas_path] = atlas
    state.atlas[icon_path] = icon_atlas
    state.sprite[id] = sprite
    --state.icon.color[id] = icon_atlas:icon("fencer_large")
    --state.icon.bw[id] = icon_atlas:icon("fencer_bw")
end

function fencer.init_state(state, id)
    return state
        :set("max_health/" .. id, 10)
        :set("agility/" .. id, 3)
        :set("power/" .. id, 4)
        :set("name/" .. id, "Fencer")
end

return fencer
