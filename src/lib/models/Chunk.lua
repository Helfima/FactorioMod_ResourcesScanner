-------------------------------------------------------------------------------
---Description of the module.
---@class Chunk
local Chunk = {
    ---single-line comment
    classname = "LibChunk"
}

---get chunk key
---@param chunk ChunkPositionAndArea
---@return string
Chunk.get_key = function(chunk)
    return string.format("%s,%s", chunk.x, chunk.y)
end

---Get chunk data
---@param chunk ChunkPosition
---@return ChunkPositionAndArea
Chunk.get_chunk_data = function(chunk)
    local size = 32
    local rx = math.ceil(chunk.x / size)
    local ry = math.ceil(chunk.y / size)
    local area = {
        left_top = {
            x = rx * size,
            y = ry * size
        },
        right_bottom = {
            x = rx * size + size,
            y = ry * size + size
        }
    }
    local chunk_data = {
        x = rx,
        y = ry,
        area = area
    }
    return chunk_data
end

---Get chunk data
---@param chunk ChunkPositionAndArea
---@return MapPosition
Chunk.get_map_position = function(chunk)
    local size = 32
    local position = {
        x = chunk.x * size,
        y = chunk.y * size
    }
    return position
end

---Get chunk data
---@param resource LuaEntity|ResourceData
---@return ChunkPositionAndArea
Chunk.get_chunk_from_resource = function(resource)
    local size = 32
    local rx = math.floor(resource.position.x / size)
    local ry = math.floor(resource.position.y / size)
    local area = {
        left_top = {
            x = rx * size,
            y = ry * size
        },
        right_bottom = {
            x = rx * size + size,
            y = ry * size + size
        }
    }
    local chunk_data = {
        x = rx,
        y = ry,
        area = area
    }
    return chunk_data
end

---@param chunk ChunkPositionAndArea
---@param delta double
---@return BoundingBox
Chunk.get_area_extended = function(chunk, delta)
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

---@param chunk ChunkPositionAndArea
---@param resource LuaEntity|ResourceData
---@return boolean
Chunk.is_resource_in_area = function(chunk, resource)
    return Area.is_in_area(chunk.area, resource.position, 0)
end

---Return chunk list of nearby chunk of resource, if resource is not in border return nil
---@param chunk ChunkPositionAndArea
---@param resource ResourceData
---@return {[uint] : ChunkPositionAndArea}|nil
Chunk.get_nearby_chunks = function(chunk, resource)
    local chunks = {}
    local cardinal = Area.get_cardinal_border(chunk.area, resource.position)
    if cardinal == defines.mod.cardinal.unknown then return nil end
    if bit32.band(cardinal, defines.mod.cardinal.north) then
        local chunk_position = { x = chunk.x, y = chunk.y - 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.north) and bit32.band(cardinal, defines.mod.cardinal.east) then
        local chunk_position = { x = chunk.x + 1, y = chunk.y - 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.east) then
        local chunk_position = { x = chunk.x + 1, y = chunk.y }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.east) and bit32.band(cardinal, defines.mod.cardinal.south) then
        local chunk_position = { x = chunk.x + 1, y = chunk.y + 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.south) then
        local chunk_position = { x = chunk.x, y = chunk.y + 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.south) and bit32.band(cardinal, defines.mod.cardinal.west) then
        local chunk_position = { x = chunk.x - 1, y = chunk.y + 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.west) then
        local chunk_position = { x = chunk.x - 1, y = chunk.y }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    if bit32.band(cardinal, defines.mod.cardinal.west) and bit32.band(cardinal, defines.mod.cardinal.north) then
        local chunk_position = { x = chunk.x - 1, y = chunk.y - 1 }
        local nearby_chunk = Chunk.get_chunk_data(chunk_position)
        table.insert(chunks, nearby_chunk)
    end
    return chunks
end

---get list of adjacent chunk
---@param chunk ChunkPositionAndArea
---@return table
Chunk.get_adjacent_keys = function(chunk)
    local keys = {}
    local deltas = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 } }
    for _, delta in pairs(deltas) do
        local key = string.format("%s,%s", chunk.x + delta[1], chunk.y + delta[2])
        table.insert(keys, key)
    end
    return keys
end

return Chunk
