-------------------------------------------------------------------------------
---Description of the module.
---@class Patch
local Patch = {
  ---single-line comment
  classname = "HMPatch"
}

Patch.create_id = function ()
    local current_id = Cache.getData(Patch.classname, "current_id")
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
        resources = {}
    }
    Surface.add_patch(patch)
    return patch
end

---Add resource in patch
---@param patch PatchData
---@param resource ResourceData
Patch.add_in_patch = function(patch, resource)
    local resource_key = Resource.get_key(resource)
    if patch.resources[resource_key] ~= nil then return end
    patch.resources[resource_key] = resource
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
    for _, resource in pairs(patch2.resources) do
        Patch.add_in_patch(patch1, resource)
    end
end


return Patch