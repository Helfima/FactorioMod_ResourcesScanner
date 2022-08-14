-------------------------------------------------------------------------------
---Description of the module.
---@class Surface
local Surface = {
  ---single-line comment
  classname = "HMSurface"
}

---@type ResourceData
local cache_surface = nil

---load
---@param surface_id uint
---@return ResourceData
Surface.load = function (surface_id)
    local cache_surfaces = Cache.getData(Surface.classname, "surfaces")
    if cache_surfaces == nil then cache_surfaces = Cache.setData(Surface.classname, "surfaces", {}) end
    if cache_surfaces[surface_id] == nil then cache_surfaces[surface_id] = {} end
    cache_surface = cache_surfaces[surface_id]
    return cache_surface
end

---Get resource names from cache
---@return {[string] : boolean}
Surface.get_resource_names = function ()
    if cache_surface.resource_names == nil then cache_surface.resource_names = {} end
    return cache_surface.resource_names
end

---Add resource name into cache
---@param resource_name string
Surface.add_resource_name = function (resource_name)
    local resource_names = Surface.get_resource_names()
    resource_names[resource_name] = true
end

---Add resource name into cache
---@param resource_name string
---@return boolean
Surface.get_resource_name = function (resource_name)
    local resource_names = Surface.get_resource_names()
    return resource_names[resource_name]
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
    Surface.add_resource_name(resource.name)
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

---Get force data
---@return {[uint] : ForceData}
Surface.get_force_datas = function()
    if cache_surface.forces == nil then cache_surface.forces = {} end
    return cache_surface.forces
end

---Get force data
---@param force LuaForce
---@return ForceData
Surface.get_force_data = function(force)
    local force_datas = Surface.get_force_datas()
    if force_datas[force.index] == nil then force_datas[force.index] = {} end
    return force_datas[force.index]
end

---Get markers
---@param force LuaForce
---@return { [uint]: ForceMarkerData }
Surface.get_markers = function(force)
    local force_data = Surface.get_force_data(force)
    if force_data.markers == nil then force_data.markers = {} end
    return force_data.markers
end

---Get marker from cache
---@param force LuaForce
---@param tag_number uint
---@return ForceMarkerData
Surface.get_marker = function (force, tag_number)
    local markers = Surface.get_markers(force)
    return markers[tag_number]
end

---Add a marker into cache
---@param force LuaForce
---@param tag_number uint
---@param patch_id uint
Surface.add_marker = function (force, tag_number, patch_id)
    local markers = Surface.get_markers(force);
    markers[tag_number] = {tag_number=tag_number, patch_id=patch_id}
end

---Remove a marker from cache
---@param force LuaForce
---@param tag_number uint
Surface.remove_marker = function (force, tag_number)
    local markers = Surface.get_markers(force);
    markers[tag_number] = nil
end

---Get settings
---@param force LuaForce
---@return {[string] : ForceSettingData}
Surface.get_settings = function(force)
    local force_data = Surface.get_force_data(force)
    if force_data.settings == nil then force_data.settings = {} end
    return force_data.settings
end

---Get setting
---@param force LuaForce
---@param resource_name string
---@return ForceSettingData
Surface.get_setting = function (force, resource_name)
    local settings = Surface.get_settings(force);
    if settings[resource_name] == nil then
        settings[resource_name] = {
            limit=10*1000,
            show=false
        }
    end
    return settings[resource_name]
end

---Set setting
---@param force LuaForce
---@param resource_name string
---@param limit uint
---@param show boolean
---@return {limit:uint, show:boolean}
Surface.set_setting = function (force, resource_name, limit, show)
    local settings = Surface.get_settings(force);
    local setting = {limit=limit, show=show}
    settings[resource_name] = setting
    return setting
end

---update tag
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
Surface.update_patch_tag = function(force, surface, patch)
    local header = Format.floorNumberKilo(patch.amount, 1)
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
        local tag = Surface.add_patch_tag(force, surface, patch, position, header, icon)
        if tag ~= nil then
            patch.tag_number = tag.tag_number
        end
    end
end

---Remove all force tags
---@param force LuaForce
---@param surface LuaSurface
Surface.remove_patch_tags = function(force, surface)
    local force_tags = force.find_chart_tags(surface)
    for key, tag in pairs(force_tags) do
        if Surface.get_marker(force, tag.tag_number) then
            Surface.remove_marker(force, tag.tag_number)
            tag.destroy()
        end
    end
end

---Add patch tag on map
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
---@param position MapPosition
---@param header string
---@param icon {name:string, type:string}
---@return LuaCustomChartTag|nil
Surface.add_patch_tag = function (force, surface, patch, position, header, icon )
    local tag = {
        position = position,
		text = header,
		icon = icon,
    }
    local new_tag = force.add_chart_tag(surface, tag)
    if new_tag ~= nil then
        Surface.add_marker(force, new_tag.tag_number, patch.id)
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
            Surface.remove_marker(force, tag.tag_number)
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
        local setting = Surface.get_setting(force, patch.name)
        if setting.show == true and patch.amount >= setting.limit then
            Surface.update_patch_tag(force, surface, patch)
        else
            Surface.remove_patch_tag(force, surface, patch)
        end
    end
end

---Destroys tags and data
---@param force LuaForce
---@param surface LuaSurface
Surface.destroy = function(force, surface)
    Surface.remove_patch_tags(force, surface)
    local cache_surfaces = Cache.getData(Surface.classname, "surfaces")
    cache_surfaces[surface.index] = nil
end

return Surface