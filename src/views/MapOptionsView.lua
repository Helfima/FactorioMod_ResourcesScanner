EntityPrototype = require("models.EntityPrototype")
-------------------------------------------------------------------------------
---Class to build rule edition dialog
---@class MapOptionsView : Form
MapOptionsView = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.auto_clear = false
end)

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
  Surface.load(force.index, surface.index)
  local setting = Surface.get_setting(resource_name)
  
  if event.action == "resource-show" then
    Surface.set_setting(resource_name, setting.limit, not (setting.show))
    Surface.update_markers(force, surface)
  end

  if event.action == "resource-limit" then
    local text = event.element.text
    local limit = string.parse_number(text)
    Surface.set_setting(resource_name, limit, setting.show)
    Surface.update_markers(force, surface)
  end
end

function MapOptionsView:update_resources()
  local panel = self:get_panel()
  if panel["scroll"] then return end
  local scroll = self:get_scroll_panel("scroll")
  local list_panel = GuiElement.add(scroll, GuiTable("list"):column(3))
  GuiElement.add(list_panel,
    GuiLabel("label", "column", 1):caption({ "ResourcesScanner-MapOptionsView.column-header-visible" }))
  GuiElement.add(list_panel,
    GuiLabel("label", "column", 2):caption({ "ResourcesScanner-MapOptionsView.column-header-resource" }))
  GuiElement.add(list_panel,
    GuiLabel("label", "column", 3):caption({ "ResourcesScanner-MapOptionsView.column-header-limit" }))

  local force = Player.get_force()
  local surface = Player.get_surface()
  Surface.load(force.index, surface.index)

  local resources = Player.get_resource_entity_prototypes()
  for _, resource in pairs(resources) do
    local setting = Surface.get_setting(resource.name)
    local show = setting.show
    local limit = Format.floorNumberKilo(setting.limit)

    local checkbox = GuiElement.add(list_panel, GuiCheckBox(self.classname, "resource-show", resource.name):state(show))
    local icon = EntityPrototype.get_icon_string(resource)
    local label = GuiElement.add(list_panel,
      GuiLabel("label", resource.name):caption({ "", icon }):tooltip(resource.localised_name))
    local input = GuiElement.add(list_panel, GuiTextField(self.classname, "resource-limit", resource.name):text(limit))
  end
end
