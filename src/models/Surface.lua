-------------------------------------------------------------------------------
---Description of the module.
---@class Surface
local Surface = {
  ---single-line comment
  classname = "HMSurface"
}

---@type CacheResources
local cache_surface = nil

---load
---@param parameters ParametersData
---@return CacheResources
Surface.load = function (parameters)
    local force_id = parameters.force_id
    local surface_id = parameters.surface_id
    local cache_surfaces = Cache.getData(Surface.classname, "surfaces")
    if cache_surfaces == nil then cache_surfaces = Cache.setData(Surface.classname, "surfaces", {}) end
    if cache_surfaces[surface_id] == nil then cache_surfaces[surface_id] = {} end
    local cache_forces = cache_surfaces[surface_id]
    if cache_forces[force_id] == nil then cache_forces[force_id] = {} end
    cache_surface = cache_forces[force_id]
    return cache_surface
end

Surface.get_resources = function()
    if cache_surface.resources == nil then cache_surface.resources = {} end
    return cache_surface.resources
end

---Get resource from cache
---@param resource LuaEntity
---@return ResourceData
Surface.get_resource = function (resource)
    local resources = Surface.get_resources();
    local key = Resource.get_key(resource)
    return resources[key]
end

---Add a resource into cache
---@param resource ResourceData
Surface.add_resource = function (resource)
    local resources = Surface.get_resources();
    local key = Resource.get_key(resource)
    resources[key] = resource
end

Surface.get_patchs = function()
    if cache_surface.patchs == nil then cache_surface.patchs = {} end
    return cache_surface.patchs
end

---Get patch form cache
---@param patch_id uint
---@return PatchData
Surface.get_patch = function(patch_id)
    local patchs = Surface.get_patchs()
    return patchs[patch_id]
end

---Create a patch id
---@return uint
Surface.create_patch_id = function ()
    if cache_surface.patch_id == nil then cache_surface.patch_id = 0 end
    cache_surface.patch_id = cache_surface.patch_id + 1
    return cache_surface.patch_id
end

---Add a patch into cache
---@param patch PatchData
Surface.add_patch = function (patch)
    local patchs = Surface.get_patchs()
    patchs[patch.id] = patch
end

---Remove a patch from cache
---@param patch PatchData
Surface.remove_patch = function (patch)
    local patchs = Surface.get_patchs()
    patchs[patch.id] = nil
end

return Surface