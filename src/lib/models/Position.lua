-------------------------------------------------------------------------------
---Description of the module.
---@class Position
local Position = {
    ---single-line comment
    classname = "LibPosition"
}

---Return gps string
---@param position MapPosition
function Position.get_gps_string(position)
    local gps = string.format("[gps=%s,%s]", position.x, position.y)
    return gps
end

---Distance between 2 positions
---@param origin MapPosition
---@param target MapPosition
---@return double
function Position.distance(origin, target)
    local dx = target.x - origin.x
    local dy = target.y - origin.y
    local distance = (dx * dx + dy * dy) ^ 0.5
    return distance
end

return Position