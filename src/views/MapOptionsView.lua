
-------------------------------------------------------------------------------
---Class to build rule edition dialog
---@class MapOptionsView : Form
MapOptionsView = newclass(Form, function(base, classname)
  Form.init(base, classname)
  base.auto_clear = false
end)


-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function MapOptionsView:on_style(styles, width_main, height_main)
  styles.flow_panel = {
    width = 500,
    height = 400,
  }
end

-------------------------------------------------------------------------------
---On initialization
function MapOptionsView:on_init()
  self.panel_caption = { "ResourcesScanner-MapOptionsView.title" }
  --self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function MapOptionsView:on_update(event)
  self:update_resources()
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

  if event.action == "resource-show" then
    Surface.set_setting(force, resource_name, setting.limit, not (setting.show))
    Surface.update_markers(force, surface)
  end

  if event.action == "resource-limit" then
    local text = event.element.text
    local limit = string.parse_number(text)
    Surface.set_setting(force, resource_name, limit, setting.show)
    Surface.update_markers(force, surface)
  end

  if event.action == "scan-map" then
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
end

function MapOptionsView:update_resources()
  local flow_panel, content_panel, menu_panel = self:get_panel()
  local force = Player.get_force()
  local surface = Player.get_surface()
  Surface.load(surface.index)
  local resource_names = Surface.get_resource_names()

  if table.size(resource_names) > 0 then
    if content_panel["scroll"] then return end
    local scroll = self:get_scroll_panel("scroll")
    local list_panel = GuiElement.add(scroll, GuiTable("list"):column(3))
    GuiElement.add(list_panel,
      GuiLabel("label", "column", 1):caption({ "ResourcesScanner-MapOptionsView.column-header-visible" }))
    GuiElement.add(list_panel,
      GuiLabel("label", "column", 2):caption({ "ResourcesScanner-MapOptionsView.column-header-resource" }))
    GuiElement.add(list_panel,
      GuiLabel("label", "column", 3):caption({ "ResourcesScanner-MapOptionsView.column-header-limit" }))


    local resources = Player.get_resource_entity_prototypes()
    for _, resource in pairs(resources) do
      if Surface.get_resource_name(resource.name) then
        local setting = Surface.get_setting(force, resource.name)
        local show = setting.show
        local limit = Format.floorNumberKilo(setting.limit)

        local checkbox = GuiElement.add(list_panel,
          GuiCheckBox(self.classname, "resource-show", resource.name):state(show))
        local icon = EntityPrototype.get_icon_string(resource)
        local label = GuiElement.add(list_panel,
          GuiLabel("label", resource.name):caption({ "", icon }):tooltip(resource.localised_name))
        local input = GuiElement.add(list_panel,
          GuiTextField(self.classname, "resource-limit", resource.name):text(limit))
      end
    end
  else
    if content_panel["scan"] then return end
    local scan_panel = self:get_flow_panel("scan", "vertical")
    local button = GuiElement.add(scan_panel,
      GuiButton(self.classname, "scan-map"):caption("Scan map"))
  end
end
