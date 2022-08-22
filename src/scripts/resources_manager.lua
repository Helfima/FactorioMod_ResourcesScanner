Patch = require "models.Patch"
Surface = require "models.Surface"

local module = {}

module.on_init = function()
end

module.on_load = function()
end

module.on_configuration_changed = function()
end

module.add_commands = function()
    commands.add_command(defines.mod.command.name, defines.mod.command.header, module.command_run)
end

module.command_run = function(event)
    if event ~= nil and event.player_index ~= nil then
        Player.load(event)
        module.execute(event)
    end
end

---@param event CustomCommandData
---@return {action:string, resource_names:table, resource_limit:double}
module.parse_parameter = function(event)
    local action, resource_name, resource_limit = string.match(event.parameter, "([^%s]+)[ ]?([^%s]*)[ ]?([^%s]*)")
    local resource_names = nil
    if resource_name ~= defines.mod.default.filter and resource_name ~= "" then
        local resources = Player.get_resource_entity_prototypes()
        for _, resource in pairs(resources) do
            local name = resource.name
            if string.find(name, resource_name, 1, true) then
                if resource_names == nil then resource_names = {} end
                table.insert(resource_names, name)
            end
        end
    end
    if resource_limit == "" then resource_limit = defines.mod.default.limit end
    return action, resource_names, resource_limit
end
-------------------------------------------------------------------------------
---@param event CustomCommandData
---@return ParametersData
module.get_parameter = function(event)
    local force = Player.get_force()
    local surface = Player.get_surface()
    local action, resource_names, resource_limit = module.parse_parameter(event)
    local limit = string.parse_number(resource_limit)
    local parameters = {}
    parameters.player_index = event.player_index
    parameters.action = action
    parameters.resource_names = resource_names
    parameters.resource_limit = limit
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
    local ok, err = pcall(function()
        if event.name == defines.mod.command.name then
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
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

module.on_nth_tick = {}
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

---@param parameters ParametersData
module.run_on_tick = function(parameters)
    local ok, err = pcall(function()
        if parameters == nil then return end
        Player.load(parameters)
        Surface.load(parameters.surface_id)

        local action = parameters.action
        if action == "remove" then
            module.action_remove(parameters)
        elseif action == "scan" then
            module.action_scan(parameters)
        elseif action == "show" then
            module.action_show(parameters)
        elseif action == "hide" then
            module.action_hide(parameters)
        elseif action == "reset" then
            module.action_reset(parameters)
        else
            parameters.finished = true
            Player.printf("Action %s not found!", action)
        end
    end)
    if not (ok) then
        parameters.error = err
        Player.print(err)
        log(err)
    end
end

---@param parameters ParametersData
module.action_remove = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    Surface.remove_patch_tags(force, surface)
    parameters.finished = true
end

---@param parameters ParametersData
module.action_reset = function(parameters)
    Surface.destroy()
    parameters.finished = true
end

---Check match resources names
---@param resource_names {[uint]:string}
---@param resource_name string
---@return boolean
module.match_resource_names = function(resource_names, resource_name)
    if resource_names == nil then return true end
    for _, name in pairs(resource_names) do
        if resource_name == name then return true end
    end
    return false
end

---@param parameters ParametersData
module.action_show = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    local resource_names = parameters.resource_names
    local resource_limit = parameters.resource_limit
    local patchs = Surface.get_patchs()
    for _, patch in pairs(patchs) do
        if module.match_resource_names(resource_names, patch.name)
            and (resource_limit == 0 or patch.amount >= resource_limit) then
            Surface.update_patch_tag(force, surface, patch)
        end
    end
    parameters.finished = true
end

---@param parameters ParametersData
module.action_hide = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    local resource_names = parameters.resource_names
    local resource_limit = parameters.resource_limit
    local patchs = Surface.get_patchs()
    for _, patch in pairs(patchs) do
        if module.match_resource_names(resource_names, patch.name)
            and (resource_limit == 0 or patch.amount <= resource_limit) then
            Surface.remove_patch_tag(force, surface, patch)
        end
    end
    parameters.finished = true
end

---@param parameters ParametersData
module.action_scan = function(parameters)
    local force_id = parameters.force_id
    local force = game.forces[force_id]
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)
    if parameters.cleanup == nil then
        Surface.remove_patch_tags(force, surface)
        parameters.cleanup = true
        Dispatcher:send(defines.mod.events.on_gui_update, nil, Dispatcher.classname)
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
        local ratio = parameters.index / #parameters.chunks
        local percent = 100 * parameters.index / #parameters.chunks
        if percent >= parameters.percent + 1 then
            parameters.percent = percent
            Dispatcher:send(defines.mod.events.on_gui_update, {percent = ratio}, MapOptionsView.classname)
            --Player.printf("%s%s%%!", "Loaded resources:", percent)
        end
        -- incremente l'index
        parameters.index = parameters.index + step
        return
    else
        parameters.finished = true
        Dispatcher:send(defines.mod.events.on_gui_update, nil, Dispatcher.classname)
        Player.print("Finished scan!")
    end
end

---@param parameters ParametersData
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

---Scan few chunks
---@param parameters ParametersData
---@param step uint
module.get_chunks_patchs = function(parameters, step)
    local surface_id = parameters.surface_id
    local surface = game.get_surface(surface_id)

    local index_start = parameters.index
    local index_end = parameters.index + step - 1
    for i = index_start, index_end, 1 do
        local chunk = parameters.chunks[i]
        if chunk == nil then break end -- loop finished
        --log(string.format("******* Loop tick=%s index=%s *******", game.tick, i))
        local patchs = module.get_chunk_patchs(chunk, surface)
    end
end

---Scan a chunk
---@param chunk ChunkData
---@param surface LuaSurface
---@return {[uint]:PatchData}
module.get_chunk_patchs = function(chunk, surface)
    --log(string.format("======== Analyse Chunk %s,%s ========", chunk.x, chunk.y))
    local patchs = {}
    local resources_visited = {}
    local patchs_resources = {}
    local resources = surface.find_entities_filtered({ area = chunk.area, type = "resource" })
    if #resources > 0 then
        -- memorise le chunk sinon ca ne fonctionnera pas
        Surface.add_chunk(chunk)

        for _, resource in pairs(resources) do
            local resource_key = Resource.get_key(resource)
            local resource_visited = resources_visited[resource_key]
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
                    resources_visited[resource_key] = new_resource
                    Surface.add_resource_name(resource.name)
                    if resource_patchs == nil then
                        -- creation d'un patch
                        local new_patch = Patch.create(resource)
                        Patch.add_in_patch(new_patch, new_resource)
                        patchs[new_patch.id] = new_patch
                        new_resource.path_id = new_patch.id
                        Patch.add_in_chunk(new_patch, chunk)
                        if patchs_resources[new_patch.id] == nil then patchs_resources[new_patch.id] = {} end
                        patchs_resources[new_patch.id][resource_key] = true
                    else
                        -- au moins un patch trouvé
                        if #resource_patchs == 1 then
                            -- patch unique
                            local patch = resource_patchs[1]
                            Patch.add_in_patch(patch, new_resource)
                            if patchs_resources[patch.id] == nil then patchs_resources[patch.id] = {} end
                            patchs_resources[patch.id][resource_key] = true
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
                                    for key, value in pairs(patchs_resources[patch.id]) do
                                        patchs_resources[merged_patch.id][key] = true
                                    end
                                    patchs_resources[patch.id] = nil
                                end
                            end
                            Patch.add_in_patch(merged_patch, new_resource)
                            patchs_resources[merged_patch.id][resource_key] = true
                        end
                    end
                end
            else
                -- ressource visité
                local patch = Surface.get_patch(resource_visited.patch_id)
                if patch == nil then
                    error("no patch!")
                end
                if patchs[patch.id] == nil then
                    patchs[patch.id] = patch
                end
            end
        end
    end
    module.try_merge_patchs(chunk)
    return patchs
end

---@param chunk ChunkData
module.try_merge_patchs = function(chunk)
    if chunk ~= nil and chunk.patchs ~= nil then
        -- try merge patchs
        --log("-------------------------------------------")
        local adj_keys = Chunk.get_adjacent_keys(chunk)
        for _, adj_key in pairs(adj_keys) do
            local adj_chunk = Surface.get_chunk_by_key(adj_key)
            if adj_chunk ~= nil and adj_chunk.patchs ~= nil then
                --log(string.format("-> Chunk %s,%s vs %s,%s", chunk.x, chunk.y, adj_chunk.x, adj_chunk.y))
                for patch_id1, _ in pairs(adj_chunk.patchs) do
                    local patch1 = Surface.get_patch(patch_id1)
                    if patch1 == nil then
                        error("missing patch!")
                    end
                    for patch_id2, _ in pairs(chunk.patchs) do
                        if patch_id1 ~= patch_id2 then
                            local patch2 = Surface.get_patch(patch_id2)
                            if patch1.name == patch2.name then
                                local distance = Patch.distance_patch(patch1, patch2)
                                if distance < 64 then
                                    Patch.merge_patch(patch1, patch2)
                                    --log(string.format("--> Merged Patchs %s(%s) => %s(%s) = %s", patch2.id, patch2.name, patch1.id, patch1.name, Format.floorNumberKilo(patch1.amount, 1)))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

---Chunk analyse
---@param chunk ChunkData
---@param surface LuaSurface
module.chunk_analyse = function(chunk, surface)
    local patchs = module.get_chunk_patchs(chunk, surface)

end

---Called when a resource entity reaches 0 or its minimum yield for infinite resources.
---@param event EventData.on_resource_depleted
module.on_resource_depleted = function(event)
    local ok, err = pcall(function()
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---Called when a chunk is generated.
---@param event EventData.on_chunk_generated
module.on_chunk_generated = function(event)
    local ok, err = pcall(function()
        local chunk = Chunk.get_chunk_data(event.position)
        module.chunk_analyse(chunk, event.surface)
        --module.debug_chunk_tag(chunk, event.surface)
        --module.debug_chunk_message(chunk, event.surface)
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---Called when a chunk is generated.
---@param event EventData.on_chunk_charted
module.on_chunk_charted = function(event)
    local ok, err = pcall(function()
        local chunk = Chunk.get_chunk_data(event.position)
        local surface = game.get_surface(event.surface_index)
        module.chunk_analyse(chunk, surface)
        module.debug_chunk_tag(chunk, surface)
        --module.debug_chunk_message(chunk, event.surface)
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---Called when an entity of type radar finishes scanning a sector. Can be filtered for the radar using LuaSectorScannedEventFilter.
---@param event EventData.on_sector_scanned
module.on_sector_scanned = function(event)
    local radar = event.radar
    local surface = radar.surface
    local force = radar.force
    local player = radar.last_user

    local chunk = {
        x = event.chunk_position.x,
        y = event.chunk_position.y,
        area = event.area
    }

    local parameters = {}
    parameters.player_index = player.index
    parameters.action = "scan"
    parameters.resource_name = defines.mod.default.filter
    parameters.resource_limit = defines.mod.default.limit
    parameters.event = event
    parameters.force_id = force.index
    parameters.surface_id = surface.index
    parameters.surface_name = surface.name
    parameters.chunks = { chunk }
    module.append_queue(parameters)
end

---@param chunk ChunkData
---@param surface LuaSurface
module.debug_chunk_tag = function(chunk, surface)
    local force = game.forces[1]
    local position = Chunk.get_map_position(chunk)
    local tag = {
        position = position,
        text = string.format("%s,%s", chunk.x, chunk.y),
    }
    force.add_chart_tag(surface, tag)
end

module.debug_chunk_message = function(chunk, surface)
    local force = game.forces[1]
    force.print(string.format("chunk:%s,%s surface:%s", chunk.x, chunk.y, surface.name))
end

module.events =
{
    --[defines.events.on_resource_depleted] = module.on_resource_depleted,
    --[defines.events.on_sector_scanned] = module.on_sector_scanned
    --[defines.events.on_chunk_generated] = module.on_chunk_generated,
    --[defines.events.on_chunk_charted] = module.on_chunk_charted,
}

return module
