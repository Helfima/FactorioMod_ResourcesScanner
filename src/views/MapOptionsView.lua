-------------------------------------------------------------------------------
---Class to build rule edition dialog
---@class MapOptionsView : Form
MapOptionsView = newclass(Form, function(base, classname)
    Form.init(base, classname)
    base.auto_clear = true
    base.mod_menu = true
end)


-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function MapOptionsView:on_style(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_width = 520,
        maximal_width = 700,
        minimal_height = 400,
        maximal_height = height_main-200,
    }
end

-------------------------------------------------------------------------------
---On initialization
function MapOptionsView:on_init()
    self.panel_caption = { "ResourcesScanner.options-title" }
    --self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
---For Bind Dispatcher Event
function MapOptionsView:on_bind()
    Dispatcher:bind(defines.mod.events.on_before_delete_cache, self, self.on_before_delete_cache)
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function MapOptionsView:on_before_delete_cache(event)
    -- remove all data
    Surface.destroy()
    Dispatcher:send(defines.mod.events.on_gui_update, nil, MapOptionsView.classname)
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return string,string
function MapOptionsView:get_button_sprites()
  return defines.sprites.jewel.white, defines.sprites.jewel.black
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function MapOptionsView:on_update(event)
    self:update_resources(event)
end

-------------------------------------------------------------------------------
---On event
---@param event EventModData
function MapOptionsView:on_event(event)
    local resource_name = event.item1
    local force = Player.get_force()
    local surface = Player.get_surface()
    Surface.load(surface.index)
    local setting = Surface.get_setting(force, resource_name)

    if event.action == "resource-open" then
        User.set_parameter("resource_name", resource_name)
        event.action = "OPEN"
        Dispatcher:send(defines.mod.events.on_gui_open, event, "RSResourcesView")
    end

    if event.action == "resource-show" then
        Surface.set_setting(force, resource_name, setting.limit, not (setting.show))
        Surface.update_markers(force, surface)
        Dispatcher:send(defines.mod.events.on_gui_update, nil, MapOptionsView.classname)
    end

    if event.action == "resource-show-all" then
        local show=event.element.state
        local resources = Player.get_resource_entity_prototypes()
        for _, resource in pairs(resources) do
            local resource_name = resource.name
            if Surface.get_resource_name(resource_name) then
                local setting = Surface.get_setting(force, resource_name)
                Surface.set_setting(force, resource_name, setting.limit, show)
                Surface.update_markers(force, surface)
            end
        end
        Dispatcher:send(defines.mod.events.on_gui_update, nil, MapOptionsView.classname)
    end

    if event.action == "resource-limit" then
        local text = event.element.text
        local limit = string.parse_number(text)
        Surface.set_setting(force, resource_name, limit, setting.show)
        Dispatcher:send(defines.mod.events.on_gui_update, nil, MapOptionsView.classname)
        Surface.update_markers(force, surface)
    end

    if event.action == "scan-map" then
        Surface.destroy_surface(surface)
        event.name = defines.mod.command.name
        event.parameter = "scan"
        local parameters = Resources_Manager.get_parameter(event)
        local response = Resources_Manager.append_queue(parameters)
        if response then
            Player.printf("Added in queue! %s", parameters.surface_name)
        else
            Player.print("Already in queue!")
        end
    end

    if event.action == "scan-refresh" then
        event.name = defines.mod.command.name
        event.parameter = "refresh"
        local parameters = Resources_Manager.get_parameter(event)
        local response = Resources_Manager.append_queue(parameters)
        if response then
            Player.printf("Added in queue! %s", parameters.surface_name)
        else
            Player.print("Already in queue!")
        end
    end
end

---@param event EventModData
function MapOptionsView:update_resources(event)
    local flow_panel, content_panel, menu_panel = self:get_panel()
    local force = Player.get_force()
    local surface = Player.get_surface()
    Surface.load(surface.index)
    local resource_names = Surface.get_resource_names()
    local has_patch = table.size(resource_names) > 0

    local scan_panel = self:get_flow_panel("scan", defines.mod.direction.horizontal)
    local button_scan = GuiElement.add(scan_panel,
        GuiButton(self.classname, "scan-map"):caption({"ResourcesScanner.scan-map"}))
    local button_refresh = GuiElement.add(scan_panel,
    GuiButton(self.classname, "scan-refresh"):caption({"ResourcesScanner.scan-refresh"}))
    if event.percent then
        local percent_panel = self:get_flow_panel("percent", defines.mod.direction.horizontal)
        local caption = math.floor(event.percent * 100)
        local bar = GuiElement.add(percent_panel,
            GuiProgressBar(self.classname, "scan-bar"):value(event.percent):caption(caption):style("scan_progressbar"))
        bar.style.top_margin = 3
        button_scan.enabled = false
        button_refresh.enabled = false
    else
        button_refresh.enabled = has_patch
    end
    if has_patch then
        local scroll = self:get_scroll_panel("scroll")

        local list_panel = GuiElement.add(scroll, GuiTable("list"):column(6):style("helfima_lib_table_default"))
        list_panel.style.cell_padding = 2

        local resource_state_all = true
        local resource_show_all = GuiElement.add(list_panel, GuiCheckBox(self.classname, "resource-show-all", 1):state(false):caption({ "ResourcesScanner.visible" }))
        
        GuiElement.add(list_panel, GuiLabel("label", "column", 2):caption({ "ResourcesScanner.resource" }))
        GuiElement.add(list_panel, GuiLabel("label", "column", 3):caption({ "ResourcesScanner.limit" }))
        GuiElement.add(list_panel, GuiLabel("label", "column", 4):caption({ "ResourcesScanner.count" }))
        GuiElement.add(list_panel, GuiLabel("label", "column", 5):caption({ "ResourcesScanner.quantity" }))
        GuiElement.add(list_panel, GuiLabel("label", "column", 6):caption({ "ResourcesScanner.action" }))

        local quantities = Surface.get_patch_quantities()
        local resources = Player.get_resource_entity_prototypes()
        for _, resource in pairs(resources) do
            if Surface.get_resource_name(resource.name) then
                local setting = Surface.get_setting(force, resource.name)
                local show = setting.show
                if show == false then
                    resource_state_all = false
                end
                local limit = Format.floorNumberKilo(setting.limit)

                local checkbox = GuiElement.add(list_panel,
                    GuiCheckBox(self.classname, "resource-show", resource.name):state(show))

                local icon = EntityPrototype.get_icon_string(resource)
                local label = GuiElement.add(list_panel,
                    GuiLabel("label", resource.name):caption({ "", icon }):tooltip(resource.localised_name))

                local input = GuiElement.add(list_panel,
                    GuiTextField(self.classname, "resource-limit", resource.name):text(limit))

                local count = quantities[resource.name].count or 0
                local label_count = GuiElement.add(list_panel,
                    GuiLabel("label_count", resource.name):caption(count))

                local quantity = quantities[resource.name].quantity or 0
                local label_quantity = GuiElement.add(list_panel,
                    GuiLabel("label_quantity", resource.name):caption(Format.floorNumberKilo(quantity)))

                local button = GuiElement.add(list_panel,
                    GuiButton(self.classname, "resource-open", resource.name):caption({"ResourcesScanner.resources-list"}))
            end
        end
        resource_show_all.state = resource_state_all
    end
end
