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

---@param area BoundingBox
---@return MapPosition
Area.get_center = function(area)
    local x = (area.left_top.x + area.right_bottom.x) / 2
    local y = (area.left_top.y + area.right_bottom.y) / 2
    return {x,y}
end

return Area