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
    local resource = self:get_resource()
    local flow_panel, content_panel, menu_panel = self:get_panel()
    local force = Player.get_force()
    local surface = Player.get_surface()
    Surface.load(surface.index)
    local patchs = Surface.get_patchs()

    local scroll = self:get_scroll_panel("scroll")
    local list_panel = GuiElement.add(scroll, GuiTable("list"):column(4))
    list_panel.style.cell_padding = 2
    GuiElement.add(list_panel,
        GuiLabel("label", "column", 1):caption({ "ResourcesScanner.resource" }))
    GuiElement.add(list_panel,
        GuiLabel("label", "column", 2):caption({ "ResourcesScanner.quantity" }))
    GuiElement.add(list_panel,
        GuiLabel("label", "column", 3):caption({ "ResourcesScanner.distance-from-origin" }))
    GuiElement.add(list_panel,
        GuiLabel("label", "column", 4):caption({ "ResourcesScanner.action" }))

    for _, patch in spairs(patchs, function(t, a, b) return t[b].amount < t[a].amount end) do
        if patch.name == resource.name then
            local center = Area.get_center(patch.area)
            local icon = EntityPrototype.get_icon_string(resource)
            local label = GuiElement.add(list_panel,
                GuiLabel("label", patch.id):caption({ "", icon }):tooltip(resource.localised_name))

            local quantity = patch.amount or 0
            local label_quantity = GuiElement.add(list_panel,
                GuiLabel("label_quantity", patch.id):caption(Format.floorNumberKilo(quantity)))

            local distance = math.ceil(Position.distance({x=0,y=0}, center))
            local label_distance = GuiElement.add(list_panel,
                GuiLabel("label_distance", patch.id):caption(distance))

            local button = GuiElement.add(list_panel,
                GuiButton(self.classname, "patch-ping", patch.id):caption({ "ResourcesScanner.ping" }))
        end
    end
end
