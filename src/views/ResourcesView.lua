-------------------------------------------------------------------------------
---Class to build rule edition dialog
---@class ResourcesView : Form
ResourcesView = newclass(Form, function(base, classname)
    Form.init(base, classname)
    base.auto_clear = true
end)


-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ResourcesView:on_style(styles, width_main, height_main)
    styles.flow_panel = {
        width = 500,
        minimal_height = 400,
        maximal_height = height_main-200,
    }
end

-------------------------------------------------------------------------------
---On initialization
function ResourcesView:on_init()
    self.panel_caption = { "ResourcesScanner.visualize-title" }
    --self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
---For Bind Dispatcher Event
function ResourcesView:on_bind()
    Dispatcher:bind(defines.mod.events.on_before_delete_cache, self, self.on_before_delete_cache)
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function ResourcesView:on_before_delete_cache(event)
    self:close(event)
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function ResourcesView:on_update(event)
    self:update_resources(event)
end

-------------------------------------------------------------------------------
---On event
---@param event EventModData
function ResourcesView:on_event(event)
    local patch_id = tonumber(event.item1)
    local surface = Player.get_surface()
    Surface.load(surface.index)

    if event.action == "patch-ping" then
        local resource = self:get_resource()
        local patch = Surface.get_patch(patch_id)
        local quantity = patch.amount or 0
        local position = Area.get_center(patch.area)
        local gps = Position.get_gps_string(position, surface)
        Player.print_localized({ "ResourcesScanner.ping-message", Format.floorNumberKilo(quantity),
            resource.localised_name, gps })
    end

    if event.action == "sort-column" then
        local column_sorted = {name=event.item1, state=event.element.state}
        User.set_parameter("resources_view_sort", column_sorted)
        Dispatcher:send(defines.mod.events.on_gui_update, nil, ResourcesView.classname)
    end
end

---Return entity resource
---@return LuaEntityPrototype
function ResourcesView:get_resource()
    local resource_name = User.get_parameter("resource_name");
    local resource = nil
    local entities = Player.get_resource_entity_prototypes()
    for _, entity in pairs(entities) do
        if entity.name == resource_name then
            resource = entity
            break
        end
    end
    return resource
end



---@param event EventModData
function ResourcesView:update_resources(event)
    local get_distance = function(patch)
        local center = Area.get_center(patch.area)
        local distance = math.ceil(Position.distance({x=0,y=0}, center))
        return distance
    end
    
    local column_sorted = User.get_parameter("resources_view_sort") or {name="quantity", state=true}
    
    local left_margin = 16
    local resource = self:get_resource()
    local flow_panel, content_panel, menu_panel = self:get_panel()
    local force = Player.get_force()
    local surface = Player.get_surface()
    Surface.load(surface.index)
    local patchs = Surface.get_patchs()

    local scroll = self:get_scroll_panel("scroll")
    local list_panel = GuiElement.add(scroll, GuiTable("list"):column(4):style("helfima_lib_table_default"))
    list_panel.style.cell_padding = 2

    local col1 = GuiElement.add(list_panel,
        GuiCheckBox("label", "column", 1):style("helmod_sort_checkbox_inactive"):state(false):caption({ "ResourcesScanner.resource" }))
    col1.style.margin = 5
    
    local sorter = function(t, a, b) return t[b].amount < t[a].amount end

    local quantity_style = "helmod_sort_checkbox_inactive"
    local quantity_state = false
    if column_sorted.name == "quantity" then
        quantity_style = "helmod_sort_checkbox"
        quantity_state = column_sorted.state
        if quantity_state == false then
            sorter = function(t, a, b) return t[b].amount > t[a].amount end
        end
    end
    GuiElement.add(list_panel,
        GuiCheckBox(self.classname, "sort-column", "quantity"):style(quantity_style):state(quantity_state):caption({ "ResourcesScanner.quantity" }))
    
    local distance_style = "helmod_sort_checkbox_inactive"
    local distance_state = true
    if column_sorted.name == "distance" then
        distance_style = "helmod_sort_checkbox"
        distance_state = column_sorted.state
        sorter = function(t, a, b) return get_distance(t[b]) > get_distance(t[a]) end
        if distance_state == true then
            sorter = function(t, a, b) return get_distance(t[b]) < get_distance(t[a]) end
        end
    end
    GuiElement.add(list_panel,
        GuiCheckBox(self.classname, "sort-column", "distance"):style(distance_style):state(distance_state):caption({ "ResourcesScanner.distance-from-origin" }))
    GuiElement.add(list_panel,
        GuiCheckBox("label", "column", 4):style("helmod_sort_checkbox_inactive"):state(false):caption({ "ResourcesScanner.action" }))

    for _, patch in spairs(patchs, sorter) do
        if patch.name == resource.name then
            local icon = EntityPrototype.get_icon_string(resource)
            local label = GuiElement.add(list_panel,
                GuiLabel("label", patch.id):caption({ "", icon }):tooltip(resource.localised_name))
                label.style.left_margin = left_margin

            local quantity = patch.amount or 0
            local label_quantity = GuiElement.add(list_panel,
                GuiLabel("label_quantity", patch.id):caption(Format.floorNumberKilo(quantity)))
                label_quantity.style.left_margin = left_margin

            local distance = get_distance(patch)
            local label_distance = GuiElement.add(list_panel,
                GuiLabel("label_distance", patch.id):caption(distance))
                label_distance.style.left_margin = left_margin

            local button = GuiElement.add(list_panel,
                GuiButton(self.classname, "patch-ping", patch.id):caption({ "ResourcesScanner.ping" }))
                button.style.left_margin = left_margin
        end
    end
end
