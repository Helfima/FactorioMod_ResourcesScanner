ModGui = require "mod-gui"
require "core.defines"
require "core.tableExtends"
require "core.class"
require "core.util"

Area = require "models.Area"
Surface = require "models.Surface"
Chunk = require "models.Chunk"
Patch = require "models.Patch"
Resource = require "models.Resource"
Format = require "core.format"

local module = {}

module.on_init = function()
end

module.on_load = function()
end

module.on_configuration_changed = function()
end

module.add_commands= function()
    commands.add_command("rmm","Resources Map Manager commands", module.command_run)
end

module.command_run = function(event)
    if event ~= nil and event.player_index ~= nil then
        Player.load(event)
        module.execute(event)
    end
end

-------------------------------------------------------------------------------
---@param event CustomCommandData
---@return ParametersData
function module.get_parameter(event)
    local force = Player.getForce()
    local surface = Player.getSurface()
    local action, resource_name, resource_limit = string.match(event.parameter, "([^%s]+)[ ]?([^%s]*)[ ]?([^%s]*)")
    local parameters = {}
    parameters.player_index = event.player_index
    parameters.action = action
    parameters.resource_name = resource_name or "all"
    parameters.resource_limit = resource_limit
    parameters.event = event
    parameters.force_id = force.index
    parameters.surface_id = surface.index
    parameters.surface_name = surface.name
    return parameters
end

module.append_queue = function(parameters)
    if global.queue == nil then global.queue = {} end
    local queue = global.queue
    local force_id = parameters.force_id
    local surface_id = parameters.surface_id
    if queue[force_id] == nil then queue[force_id] = {} end
    if queue[force_id][surface_id] ~= nil then return false end
    queue[force_id][surface_id] = parameters
    return true
end
-------------------------------------------------------------------------------
---Callback function
---@param event CustomCommandData
function module.execute(event)
  local ok , err = pcall(function()
    if event.name == "rmm" then
        if event.parameter ~= nil then
            local parameters = module.get_parameter(event)
            local response = module.append_queue(parameters)
            if response then
                Player.printf("Added in queue! %s", parameters.surface_name)
            else
                Player.print("Already in queue!")
            end
        end
    end
  end)
  if not(ok) then
    Player.print(err)
    log(err)
  end
end


module.on_nth_tick={}
module.on_nth_tick[1] = function(event)
    local queue = global.queue
    if queue == nil then return end
    for force_id, surfaces in pairs(queue) do
        if surfaces ~= nil then
            if table.size(surfaces) > 0 then
                for surface_id, parameters in pairs(surfaces) do
                    module.run_on_tick(parameters)
                    if parameters.finished or parameters.error ~= nil then
                        surfaces[surface_id] = nil
                        break
                    end
                end
            else
                queue[force_id] = nil
                break
            end
        end
    end
    if #queue == 0 then
        global.queue = nil
    end
end

module.run_on_tick = function(parameters)
    local ok , err = pcall(function()
        if parameters == nil then return end
        Player.load(parameters)
        Surface.load(parameters)

        local action = parameters.action
        if action == "remove" then
            module.action_remove(parameters)
        elseif action == "scan" then
            module.action_scan(parameters)
        elseif action == "reset" then
            module.action_reset(parameters)
        else
            parameters.finished = true
            Player.printf("Action %s not found!", action)
        end
    end)
    if not(ok) then
        parameters.error = err
        Player.print(err)
        log(err)
    end
end

module.action_remove = function(parameters)
    module.clean_tags(parameters)
    parameters.finished = true
end

module.action_reset = function(parameters)
    module.clean_tags(parameters)
    global = {}
    parameters.finished = true
end

module.action_scan = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    if parameters.cleanup == nil then
        module.clean_tags(parameters)
        parameters.cleanup = true
        return
    end
    -- load chunks
    if parameters.chunks == nil then
        module.get_chunks(parameters)
        Player.print("Loaded chunks!")
        return
    end
    if parameters.index == nil then parameters.index = 1 end
    -- load resources
    if parameters.index <= #parameters.chunks then
        local step = 1
        module.get_chunks_patchs(parameters, step)
        if parameters.percent == nil then parameters.percent = 0 end
        local percent = 100 * parameters.index / #parameters.chunks
        if percent >= parameters.percent + 10 then
            parameters.percent = percent
            Player.printf("%s%s%%!", "Loaded resources:", percent)
        end
        -- incremente l'index
        parameters.index = parameters.index + step
        return
    else
        parameters.finished = true
        Player.print("Finished tags!")
    end
end

module.get_chunks = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    parameters.chunks = {}
    for chunk in surface.get_chunks() do
        -- chunk decouvert (non noir)
        local is_chunk_charted = force.is_chunk_charted(surface, chunk)
        if is_chunk_charted then
            table.insert(parameters.chunks, chunk)
        end
    end
end

module.get_chunks_patchs = function(parameters, step)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    local resource_name = parameters.resource_name
    local resource_limit = parameters.resource_limit

    local index_start = parameters.index
    local index_end = parameters.index + step
    for i = index_start, index_end, 1 do
        local chunk = parameters.chunks[i]
        if chunk == nil then break end -- loop finished
        local patchs = module.get_chunk_patchs(chunk, resource_name, surface, force)
        if patchs ~= nil then
            local limit = string.parse_number(resource_limit)
            for _, patch in pairs(patchs) do
                if patch.amount >= limit then
                    module.update_patch_tag(force, surface, patch)
                else
                    module.remove_patch_tag(force, surface, patch)
                end
            end 
        end
    end
end

---comment
---@param chunk ChunkData
---@param resource_name string
---@param surface LuaSurface
---@param force LuaForce
---@return {[uint]:PatchData}
module.get_chunk_patchs = function(chunk, resource_name, surface, force)
    local patchs = {}
    local area_extended = Chunk.get_area_extended(chunk, 1)
    -- recherche les ressources dans la zone du chunk + delta
    -- si une ressource hors de la zone est déjà dans un patch
    -- l'affectation des patchs à proximité sera automatique
    local resources = nil
    if resource_name == "all" then
        resources = surface.find_entities_filtered({area = area_extended, type = "resource"})
    else
        resources = surface.find_entities_filtered({area = area_extended, name = resource_name})
    end
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
                                    module.remove_patch_tag(force, surface, patch)
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

---remove tag
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
module.remove_patch_tag = function(force, surface, patch)
    if patch.tag_number == nil then return end
    local area = patch.area
    local force_tags = force.find_chart_tags(surface, area)
    for _, tag in pairs(force_tags) do
        if tag.tag_number == patch.tag_number then
            local resource_makups = global["resource_makups"]
            local force_markups = resource_makups[force.index]
            force_markups[tag.tag_number] = nil
            patch.tag_number = nil
            tag.destroy()
            break
        end
    end
end

---update tag
---@param force LuaForce
---@param surface LuaSurface
---@param patch PatchData
module.update_patch_tag = function(force, surface, patch)
    local header = Format.formatNumberKilo(patch.amount)
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
        local tag = module.add_tag_chart(force, surface, position, header, icon)
        if tag ~= nil then
            patch.tag_number = tag.tag_number
        end
    end
end
--- add resource tags
module.resource_patch_tags = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    local resources_map = parameters.resources_map
    for _, resource_map in pairs(resources_map) do
        for key, patch in pairs(resource_map) do
            local icon = {type=patch.type, name=patch.name}
            local header = Format.formatNumberKilo(patch.amount)
            local position = Area.get_center(patch.area)
            module.add_tag_chart(force, surface, position, header, icon)
        end
    end
end

module.clean_tags = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    local force_tags = force.find_chart_tags(surface)
    
    local resource_makups = global["resource_makups"]
    if resource_makups == nil then return end
    
    local force_markups = resource_makups[force.index]
    if force_markups == nil then return end
    
    for key, tag in pairs(force_tags) do
        if force_markups[tag.tag_number] then
            tag.destroy()
        end
    end
end

module.add_tag_chart = function (force, surface, position, header, icon )
    local tag = {
        position = position,
		text = header,
		icon = icon,
    }
    local new_tag = force.add_chart_tag(surface, tag)
    if new_tag ~= nil then
        global["resource_makups"] = global["resource_makups"] or {}
        global["resource_makups"][force.index] = global["resource_makups"][force.index] or {}
        global["resource_makups"][force.index][new_tag.tag_number] = true
    end
    return new_tag
end

module.on_lua_shortcut  = function(event)
    -- if event.player_index ~= nil then
    --     local lua_player = game.players[event.player_index]
    --     local passenger_schedule_enable = lua_player.is_shortcut_toggled(defines.events.on_passenger_schedule_enable)
    --     lua_player.set_shortcut_toggled(defines.events.on_passenger_schedule_enable, not(passenger_schedule_enable))
    -- end
end

---Called when a resource entity reaches 0 or its minimum yield for infinite resources.
---@param event EventData.on_resource_depleted
module.on_resource_depleted  = function(event)
end

---Called when an entity of type radar finishes scanning a sector. Can be filtered for the radar using LuaSectorScannedEventFilter.
---@param event EventData.on_sector_scanned
module.on_sector_scanned  = function(event)
    local radar = event.radar
    local surface = radar.surface
    local force = radar.force
    local player = radar.last_user
    
    local chunk = {
        x=event.chunk_position.x,
        y=event.chunk_position.y,
        area = event.area
    }

    local parameters = {}
    parameters.player_index = player.index
    parameters.action = "scan"
    parameters.resource_name = "all"
    parameters.resource_limit = "1k"
    parameters.event = event
    parameters.force_id = force.index
    parameters.surface_id = surface.index
    parameters.surface_name = surface.name
    parameters.chunks = {chunk}
    module.append_queue(parameters)
end

module.events =
{
    [defines.events.on_lua_shortcut] = module.on_lua_shortcut,
    [defines.events.on_console_command] = module.on_console_command,
    [defines.events.on_resource_depleted] = module.on_resource_depleted,
    --[defines.events.on_sector_scanned] = module.on_sector_scanned
}

return module