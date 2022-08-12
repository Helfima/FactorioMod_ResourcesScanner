-------------------------------------------------------------------------------
---Description of the module.
---@class Chunk
local Chunk = {
  ---single-line comment
  classname = "HMChunk"
}

---get chunk key
---@param chunk ChunkData
---@return string
Chunk.get_key = function (chunk)
    return string.format("%s,%s", chunk.x, chunk.y)
end

---@param chunk ChunkData
---@param delta double
---@return BoundingBox
Chunk.get_area_extended = function (chunk, delta)
    local area = {
        left_top = {
            x = chunk.area.left_top.x - delta,
            y = chunk.area.left_top.y - delta
        }, 
        right_bottom = {
            x = chunk.area.right_bottom.x + delta,
            y = chunk.area.right_bottom.y + delta
        }
    }
    return area
end

---@param chunk ChunkData
---@param resource LuaEntity|ResourceData
---@return boolean
Chunk.is_resource_in_area = function (chunk, resource)
    return Area.is_in_area(chunk.area, resource.position, 0)
end

---get list of adjacent chunk
---@param chunk ChunkData
---@return table
Chunk.get_adjacent_keys = function(chunk)
    local keys = {}
    local deltas = {{-1,-1},{0,-1}, {1,-1}, {-1,0}, {1,0}, {-1,1},{0,1}, {1,1}}
    for _, delta in pairs(deltas) do
        local key = string.format("%s,%s", chunk.x + delta[1], chunk.y + delta[2])
        table.insert(keys, key)
    end
    return keys
end

return Chunk