local function sprite_mipmap(name, size, count)
    local icon_name = "ResourcesScanner-" .. name
    return {
        type = "sprite",
        name = icon_name,
        filename = "__ResourcesScanner__/graphics/icons/" .. name .. ".png",
        size = size,
        mipmap_count = count,
        flags = { "gui-icon" }
    }
end

local mipmaps = require("prototypes.sprites_builded")

local spite_icons = {}

for icon_row, icon in pairs(mipmaps) do
    table.insert(spite_icons, sprite_mipmap(icon.name, icon.size, icon.count))
end
data:extend(spite_icons)
