-------------------------------------------------------------------------------
---Description of the module.
---@class Patch
local Patch = {
  ---single-line comment
  classname = "HMPatch"
}

Patch.create_id = function ()
    local current_id = Cache.get_data(Patch.classname, "current_id")
    if current_id == nil then current_id = 0 end
    current_id = current_id + 1
    Cache.setData(Patch.classname, "current_id", current_id)
    return current_id
end

---create patch
---@param resource LuaEntity
---@return PatchData
Patch.create = function(resource)
    local id = Surface.create_patch_id()
    local name = resource.name
    local position = resource.position
    local icon = Resource.get_icon(resource)
    local area = {
        left_top = {
            x = position.x - 1,
            y = position.y - 1
        }, 
        right_bottom = {
            x = position.x + 1,
            y = position.y + 1
        }
    }
    local patch = {
        id=id,
        name=name,
        icon=icon,
        amount=0,
        area=area,
        chunks = {}
    }
    Surface.add_patch(patch)
    return patch
end

---Add resource in patch
---@param patch PatchData
---@param resource ResourceData
Patch.add_in_patch = function(patch, resource)
    resource.patch_id = patch.id
    patch.amount = patch.amount + resource.amount
    Area.extend_area(patch.area, resource.position)
end

---Resource is in the patch area
---@param patch PatchData
---@param resource LuaEntity|ResourceData
---@param delta double
---@return boolean
Patch.is_in_patch = function(patch, resource, delta)
    if patch.name ~= resource.name then return false end
    return Area.is_in_area(patch.area, resource.position, delta)
end

---merge patchs
---@param patch1 PatchData
---@param patch2 PatchData
Patch.merge_patch = function(patch1, patch2)
    patch1.amount = patch1.amount + patch2.amount
    Area.extend_area(patch1.area, patch2.area.left_top)
    Area.extend_area(patch1.area, patch2.area.right_bottom)
    for chunk_key, _ in pairs(patch2.chunks) do
        local chunk = Surface.get_chunk_by_key(chunk_key)
        Patch.add_in_chunk(patch1, chunk)
        Surface.remove_patch(patch2)
    end
end

---merge patchs
---@param patch1 PatchData
---@param patch2 PatchData
---@return double
Patch.distance_patch = function(patch1, patch2)
    local center1 = Area.get_center(patch1.area)
    local center2 = Area.get_center(patch2.area)
    local dx = center2.x - center1.x
    local dy = center2.y - center1.y
    local distance = (dx * dx + dy * dy) ^ 0.5
    return distance
end

---Add patch into chunk
---@param patch PatchData
---@param chunk ChunkData
Patch.add_in_chunk = function(patch, chunk)
    if chunk.patchs == nil then chunk.patchs = {} end
    chunk.patchs[patch.id] = true
    local key = Chunk.get_key(chunk)
    patch.chunks[key] = true
end

---Rmove patch into chunk
---@param patch PatchData
---@param chunk ChunkData
Patch.remove_from_chunk = function(patch, chunk)
    if chunk.patchs == nil then chunk.patchs = {} end
    chunk.patchs[patch.id] = nil
    local key = Chunk.get_key(chunk)
    patch.chunks[key] = nil
end


return Patch