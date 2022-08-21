-------------------------------------------------------------------------------
---Description of the module.
---@class Area
local Area = {
    ---single-line comment
    classname = "LibArea"
}

---Check if position is in area
---@param area BoundingBox
---@param position MapPosition
---@param delta double
---@return boolean
Area.is_in_area = function(area, position, delta)
    local delta = delta or 0
    local rx = position.x
    local ry = position.y
    local xmin = area.left_top.x - delta
    local ymin = area.left_top.y - delta
    local xmax = area.right_bottom.x + delta
    local ymax = area.right_bottom.y + delta
    if rx < xmin or rx > xmax then return false end
    if ry < ymin or ry > ymax then return false end
    return true
end

---Get cardinal location, value defines.mod.cardinal.unknown is not in border
---@param area BoundingBox
---@param position MapPosition
---@param delta? double
---@return uint
Area.get_cardinal_border = function(area, position, delta)
    local delta = delta or 1
    local rx = position.x
    local ry = position.y
    local xmin = area.left_top.x
    local ymin = area.left_top.y
    local xmax = area.right_bottom.x
    local ymax = area.right_bottom.y
    local cardinal = defines.mod.cardinal.unknown
    if ry >= ymin or ry <= ymin + delta then cardinal = defines.mod.cardinal.north end
    if rx >= xmax - delta or rx <= xmax then cardinal = defines.mod.cardinal.east end
    if ry >= ymax - delta or ry <= ymax then cardinal = defines.mod.cardinal.south end
    if rx >= xmin or rx <= xmin + delta then cardinal = defines.mod.cardinal.west end
    return cardinal
end

---@param area BoundingBox
---@param position MapPosition
Area.extend_area = function(area, position)
    local rx = position.x
    local ry = position.y
    if rx < area.left_top.x then area.left_top.x = rx end
    if rx > area.right_bottom.x then area.right_bottom.x = rx end
    if ry < area.left_top.y then area.left_top.y = ry end
    if ry > area.right_bottom.y then area.right_bottom.y = ry end
end

---@param left_top BoundingBox
---@param right_bottom MapPosition
Area.get_area = function(left_top, right_bottom)
    local area = { left_top = left_top, right_bottom = right_bottom }
    return area
end

---@param area BoundingBox
---@return MapPosition
Area.get_center = function(area)
    local x = (area.left_top.x + area.right_bottom.x) / 2
    local y = (area.left_top.y + area.right_bottom.y) / 2
    return { x = x, y = y }
end

return Area
