-------------------------------------------------------------------------------
---Class to help to build form
---@class Form : Object
---@field inner_frame string
---@field locate string
---@field panel_caption string
---@field auto_clear boolean
---@field panel_close boolean
---@field add_special_button boolean
Form = newclass(Object, function(base, classname)
  Object.init(base, classname)
  base:style()
  base.inner_frame = defines.mod.styles.inner
  base.locate = defines.mod.views.locate.screen
  base.content_verticaly = true
  base.auto_clear = true
  base.panel_close = true
  base.add_special_button = true
end)

Form.views = {}

-------------------------------------------------------------------------------
---Style
function Form:style()
  local width_main, height_main = User.get_main_sizes()
  self.styles = {
    flow_panel = {
      width = width_main,
      height = height_main,
      minimal_width = width_main,
      minimal_height = height_main,
      maximal_width = width_main,
      maximal_height = height_main,
    }
  }
  self:on_style(self.styles, width_main, height_main)
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function Form:on_style(styles, width_main, height_main)

end

-------------------------------------------------------------------------------
---Set style
---@param element LuaGuiElement
---@param style string
---@param property string
function Form:set_style(element, style, property)
  if element.style ~= nil and self.styles ~= nil and self.styles[style] ~= nil and self.styles[style][property] ~= nil then
    element.style[property] = self.styles[style][property]
  end
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return string,string
function Form:get_button_sprites()
  return nil,nil
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function Form:is_visible()
  return false
end

-------------------------------------------------------------------------------
---Is special
---@return boolean
function Form:is_special()
  return false
end

-------------------------------------------------------------------------------
---Get panel name
---@return string
function Form:get_panel_name()
  return self.classname
end

-------------------------------------------------------------------------------
---Get the parent panel
---@return LuaGuiElement
function Form:get_parent_panel()
  return Player.get_gui(self.locate)
end

-------------------------------------------------------------------------------
---Set style
---@param flow_panel LuaGuiElement
function Form:set_style_flow(flow_panel)
  self:set_style(flow_panel, "flow_panel", "width")
  self:set_style(flow_panel, "flow_panel", "height")
  self:set_style(flow_panel, "flow_panel", "minimal_width")
  self:set_style(flow_panel, "flow_panel", "minimal_height")
  self:set_style(flow_panel, "flow_panel", "maximal_width")
  self:set_style(flow_panel, "flow_panel", "maximal_height")
end

--------------------------------------------------------------------------------
---Get the parent panel
---@return LuaGuiElement
function Form:get_panel()
  local panel_name = self:get_panel_name()
  local inner_name = "inner"
  local header_name = "header_panel"
  local menu_name = "menu_panel"
  local parent_panel = self:get_parent_panel()
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name], parent_panel[panel_name][inner_name],
        parent_panel[panel_name][header_name][menu_name]
  end
  ---main panel
  local flow_panel = GuiElement.add(parent_panel, GuiFrameV(panel_name):style(defines.mod.styles.frame))
  flow_panel.style.horizontally_stretchable = true
  flow_panel.style.vertically_stretchable = true
  flow_panel.location = User.get_form_location(panel_name)
  self:set_style_flow(flow_panel)

  local header_panel = GuiElement.add(flow_panel, GuiFlowH(header_name))
  header_panel.style.horizontally_stretchable = true
  ---header panel
  local title_panel = GuiElement.add(header_panel,
    GuiFrameH("title_panel"):caption(self.panel_caption or self.classname):style(defines.mod.styles.frame_invisible))
  title_panel.style.horizontally_stretchable = true
  title_panel.style.height = 28
  title_panel.drag_target = flow_panel

  local menu_panel = GuiElement.add(header_panel, GuiFlowH(menu_name))
  menu_panel.style.horizontal_spacing = 10
  menu_panel.style.horizontal_align = "right"

  local content_panel
  content_panel = GuiElement.add(flow_panel, GuiFrameV(inner_name):style(self.inner_frame))
  content_panel.style.vertically_stretchable = true
  content_panel.style.horizontally_stretchable = true
  return flow_panel, content_panel, menu_panel
end

-------------------------------------------------------------------------------
---Get or create flow panel
---@param panel_name string
---@param direction string
---@return LuaGuiElement
function Form:get_flow_panel(panel_name, direction)
  local flow_panel, content_panel, menu_panel = self:get_panel()
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local frame_panel = nil
  if direction == "horizontal" then
    frame_panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  else
    frame_panel = GuiElement.add(content_panel, GuiFlowV(panel_name))
  end
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
---Get or create scroll panel
---@param panel_name string
---@return LuaGuiElement
function Form:get_scroll_panel(panel_name)
  local flow_panel, content_panel, menu_panel = self:get_panel()
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local frame_panel = GuiElement.add(content_panel, GuiScroll(panel_name))
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
---Is opened panel
---@return boolean
function Form:is_opened()
  local parent_panel = self:get_parent_panel()
  if parent_panel[self:get_panel_name()] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
---Event
---@param event EventModData
function Form:event(event)
  if event.action == "OPEN" then
    if self:is_opened() then
      self:close(event)
    else
      self:open(event)
    end
  end
  if not (self:is_opened()) then return end
  self:on_event_form(event)
  self:on_event(event)
end

-------------------------------------------------------------------------------
---On form event
---@param event EventModData
function Form:on_event_form(event)
  local flow_panel, content_panel, menu_panel = self:get_panel()
  if event.action == "CLOSE" then
    self:close(event)
  end
  if event.action == "minimize-window" then
    content_panel.visible = false
    flow_panel.style.height = 50
    flow_panel.style.minimal_width = 100
  end
  if event.action == "maximize-window" then
    content_panel.visible = true
    self:set_style_flow(flow_panel)
  end
end

-------------------------------------------------------------------------------
---Close
---@param event EventModData
function Form:close(event)
  if not (self:is_opened()) then return end
  local flow_panel, content_panel, menu_panel = self:get_panel()
  User.set_form_close(self.classname, flow_panel.location)
  flow_panel.destroy()
  self:on_close(event)
end

-------------------------------------------------------------------------------
---Close
---@param event EventModData
function Form:on_close(event)
end

-------------------------------------------------------------------------------
---On event
---@param event EventModData
function Form:on_event(event)
end

-------------------------------------------------------------------------------
---Build first container
---@param event EventModData
function Form:open(event)
  self:style()
  self:on_open_before(event)
  if self:is_opened() then
    local flow_panel = self:get_panel()
    flow_panel.bring_to_front()
    return true
  end
  local parent_panel = self:get_parent_panel()
  User.set_form_opened(self.classname)
  self:update_menu_header(event)
  local panel_name = self:get_panel_name()
  if parent_panel[panel_name] == nil then
    self:on_open(event)
  end
end

-------------------------------------------------------------------------------
---On before open
---@param event EventModData
function Form:on_open_before(event)
end

-------------------------------------------------------------------------------
---On before open
---@param event EventModData
function Form:on_open(event)
end

-------------------------------------------------------------------------------
---Update
---@param event EventModData
function Form:update(event)
  if not (self:is_opened()) then return end
  local flow_panel, content_panel, menu_panel = self:get_panel()
  if self.auto_clear then content_panel.clear() end
  self:update_menu_header(event)
  self:on_update(event)
  self:update_location(event)
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function Form:on_update(event)
end

-------------------------------------------------------------------------------
---Update top menu
---@param event EventModData
function Form:update_menu_header(event)
  ---ajoute un menu
  if self.panel_caption ~= nil then
    local flow_panel, content_panel, menu_panel = self:get_panel()
    menu_panel.clear()
    if self.panel_close then
      ---special tab
      local special_group = GuiElement.add(menu_panel, GuiFlowH("special_group"))
      for _, form in pairs(Form.views) do
        if self.add_special_button == true and form:is_visible() and form:is_special() then
          local icon_hovered, icon = form:get_button_sprites()
          GuiElement.add(special_group, GuiButton(form.classname, "OPEN"):sprite("menu", icon_hovered, icon):style(defines.mod.styles.frame_action_button):tooltip(form.panel_caption))
        end
      end
      ---Standard group
      local standard_group = GuiElement.add(menu_panel, GuiFlowH("standard_group"))
      GuiElement.add(standard_group,
        GuiButton(self.classname, "minimize-window"):sprite("menu", defines.sprites.minimize.white,
          defines.sprites.minimize.black):style(defines.mod.styles.frame_action_button):tooltip({ "helfima-lib-button.minimize" }))
      GuiElement.add(standard_group,
        GuiButton(self.classname, "maximize-window"):sprite("menu", defines.sprites.maximize.white,
          defines.sprites.maximize.black):style(defines.mod.styles.frame_action_button):tooltip({ "helfima-lib-button.maximize" }))
      GuiElement.add(standard_group,
        GuiButton(self.classname, "CLOSE"):sprite("menu", defines.sprites.close.white, defines.sprites.close.black):
        style(defines.mod.styles.frame_action_button):tooltip({ "helfima-lib-button.close" }))
    end
  else
    Logging:warn(self.classname, "self.panel_caption not found")
  end
end

-------------------------------------------------------------------------------
---Update location
---@param event EventModData
function Form:update_location(event)
  local width, height = Player.get_display_sizes()
  local width_main, height_main = User.get_main_sizes()
  local flow_panel, content_panel, menu_panel = self:get_panel()

  local location = flow_panel.location
  if location.x < 0 or location.x > (width - 100) then
    location.x = 0
    flow_panel.location = location
  end
  if location.y < 0 or location.y > (height - 50) then
    location.y = 50
    flow_panel.location = location
  end
end

-------------------------------------------------------------------------------
---Add cell header
---@param guiTable LuaGuiElement
---@param name string
---@param caption string|table
function Form:add_cell_header(guiTable, name, caption)
  local cell = GuiElement.add(guiTable, GuiFlowH("header", name))
  GuiElement.add(cell, GuiLabel("label"):caption(caption))
end