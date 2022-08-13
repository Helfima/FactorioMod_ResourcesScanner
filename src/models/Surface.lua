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
---@param force_id uint
---@param surface_id uint
---@return CacheResources
Surface.load = function (force_id, surface_id)
    local cache_surfaces = Cache.getData(Surface.classname, "surfaces")
    if cache_surfaces == nil then cache_surfaces = Cache.setData(Surface.classname, "surfaces", {}) end
    if cache_surfaces[surface_id] == nil then cache_surfaces[surface_id] = {} end
    local cache_forces = cache_surfaces[surface_id]
    if cache_forces[force_id] == nil then cache_forces[force_id] = {} end
    cache_surface = cache_forces[force_id]
    return cache_surface
end

---Get ressosurces
---@return { [string]: ResourceData }
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

---Get Patchs
---@return { [uint]: PatchData }
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

---Get markers
---@return { [uint]: boolean }
Surface.get_markers = function()
    if cache_surface.markers == nil then cache_surface.markers = {} end
    return cache_surface.markers
end

---Get marker from cache
---@param tag_number uint
---@return boolean
Surface.get_marker = function (tag_number)
    local markers = Surface.get_markers();
    return markers[tag_number]
end

---Add a marker into cache
---@param tag_number uint
Surface.add_marker = function (tag_number)
    local markers = Surface.get_markers();
    markers[tag_number] = true
end

---Remove a marker from cache
---@param tag_number uint
Surface.remove_marker = function (tag_number)
    local markers = Surface.get_markers();
    markers[tag_number] = nil
end

---Get settings
---@return {[string] : {limit:uint, show:boolean}}
Surface.get_settings = function()
    if cache_surface.settings == nil then cache_surface.settings = {} end
    return cache_surface.settings
end

---Get setting
---@param resource_name string
---@return {limit:uint, show:boolean}
Surface.get_setting = function (resource_name)
    local settings = Surface.get_settings();
    if settings[resource_name] == nil then
        settings[resource_name] = {
            limit=10*1000,
            show=false
        }
    end
    return settings[resource_name]
end

---Set setting
---@param resource_name string
---@param limit uint
---@param show boolean
---@return {limit:uint, show:boolean}
Surface.set_setting = function (resource_name, limit, show)
    local settings = Surface.get_settings();
    local setting = {limit=limit, show=show}
    settings[resource_name] = setting
    return setting
end

---update tag
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
Surface.update_patch_tag = function(force, surface, patch)
    local header = Format.floorNumberKilo(patch.amount, 0)
    local position = Area.get_center(patch.area)
    --header = string.format("%s=>%s", patch.id, header)
    if patch.tag_number then
        local area = patch.area
        local force_tags = force.find_chart_tags(surface, area)
        if force_tags == nil then
            patch.tag_number = nil
        else
            local found = false
            for _, tag in pairs(force_tags) do
                if tag.tag_number == patch.tag_number then
                    found = true
                    tag.position.x = position.x
                    tag.position.y = position.y
                    tag.text = header
                    break
                end
            end
            if found == false then
                patch.tag_number = nil
            end
        end
    end
    if patch.tag_number == nil then
        local icon = patch.icon
        local tag = Surface.add_patch_tag(force, surface, position, header, icon)
        if tag ~= nil then
            patch.tag_number = tag.tag_number
        end
    end
end

Surface.clean_patch_tags = function(force, surface)
    local force_tags = force.find_chart_tags(surface)
    for key, tag in pairs(force_tags) do
        if Surface.get_marker(tag.tag_number) then
            Surface.remove_marker(tag.tag_number)
            tag.destroy()
        end
    end
end

Surface.add_patch_tag = function (force, surface, position, header, icon )
    local tag = {
        position = position,
		text = header,
		icon = icon,
    }
    local new_tag = force.add_chart_tag(surface, tag)
    if new_tag ~= nil then
        Surface.add_marker(new_tag.tag_number)
    end
    return new_tag
end

---remove tag
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
Surface.remove_patch_tag = function(force, surface, patch)
    if patch.tag_number == nil then return end
    local area = patch.area
    local force_tags = force.find_chart_tags(surface, area)
    for _, tag in pairs(force_tags) do
        if tag.tag_number == patch.tag_number then
            patch.tag_number = nil
            Surface.remove_marker(tag.tag_number)
            tag.destroy()
            break
        end
    end
end

---@param force LuaForce
---@param surface LuaSurface
Surface.update_markers = function(force, surface)
    local patchs = Surface.get_patchs()
    for _, patch in pairs(patchs) do
        local setting = Surface.get_setting(patch.name)
        if setting.show == true and patch.amount >= setting.limit then
            Surface.update_patch_tag(force, surface, patch)
        else
            Surface.remove_patch_tag(force, surface, patch)
        end
    end
end
return Surface