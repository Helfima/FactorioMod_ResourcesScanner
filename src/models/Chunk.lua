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

---Get chunk data
---@param chunk ChunkPosition
---@return ChunkData
Chunk.get_chunk_data = function (chunk)
    local size = 32
    local area = {
        left_top = {
            x = chunk.x,
            y = chunk.y
        }, 
        right_bottom = {
            x = chunk.x + size,
            y = chunk.y + size
        }
    }
    local chunk_data = {
        x=chunk.x,
        y=chunk.y,
        area=area
    }
    return chunk_data
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

---Scan a chunk
---@param chunk ChunkData
---@param surface LuaSurface
---@return {[uint]:PatchData}
Chunk.get_chunk_patchs = function(chunk, surface)
    local patchs = {}
    local area_extended = Chunk.get_area_extended(chunk, 1)
    -- recherche les ressources dans la zone du chunk + delta
    -- si une ressource hors de la zone est déjà dans un patch
    -- l'affectation des patchs à proximité sera automatique
    local resources = surface.find_entities_filtered({area = area_extended, type = "resource"})
    if #resources > 0 then
        for key, resource in pairs(resources) do
            local resource_visited = Surface.get_resource(resource)
            if resource_visited == nil then
                -- ressource non visité
                if Chunk.is_resource_in_area(chunk, resource) == true then
                    -- ne prend pas en compte les ressources hors du chunk
                    local resource_patchs = nil
                    local marging = 1
                    local type = Resource.get_product_type(resource)
                    if type == "fluid" then
                        marging = 20
                    end
                    for _, patch in pairs(patchs) do
                        if Patch.is_in_patch(patch, resource, marging) then
                            -- ajoute le patch si la resource est son area
                            if resource_patchs == nil then resource_patchs = {} end
                            table.insert(resource_patchs, patch)
                        end
                    end
                    -- creation de la ressource
                    local new_resource = Resource.create(resource)
                    if resource_patchs == nil then
                        -- creation d'un patch
                        local new_patch = Patch.create(resource)
                        Patch.add_in_patch(new_patch, new_resource)
                        patchs[new_patch.id] = new_patch
                    else
                        -- au moins un patch trouvé
                        if #resource_patchs == 1 then
                            -- patch unique
                            local patch = resource_patchs[1]
                            Patch.add_in_patch(patch, new_resource)
                        else
                            -- plusieurs patch, il faut merger les patchs
                            ---@type PatchData
                            local merged_patch = nil
                            for _, resource_patch in pairs(resource_patchs) do
                                local patch = patchs[resource_patch.id]
                                if merged_patch == nil then
                                    merged_patch = patch
                                else
                                    Patch.merge_patch(merged_patch, patch)
                                    patchs[resource_patch.id] = nil
                                    Surface.remove_patch(patch)
                                end
                            end
                            Patch.add_in_patch(merged_patch, new_resource)
                        end
                    end
                end
            else
                -- ressource visité
                local patch = Surface.get_patch(resource_visited.patch_id)
                if patchs[patch.id] == nil then
                    patchs[patch.id] = patch
                end
            end
        end
    end
    return patchs
end

return Chunk