-------------------------------------------------------------------------------
---Class to help to build form
---@class Form : Object
---@field locate string
---@field panel_caption string
---@field auto_clear boolean
Form = newclass(Object, function(base, classname)
    Object.init(base, classname)
    base:style()
    base.locate = defines.mod.views.locate.screen
    base.content_verticaly = true
    base.auto_clear = true
end)

-------------------------------------------------------------------------------
---Style
function Form:style()
  self.styles = {
    flow_panel ={
        width = nil,
        height = 400
      }
  }
  self:on_style(self.styles)
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
function Form:on_style(styles)
  
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

--------------------------------------------------------------------------------
---Get the parent panel
---@return LuaGuiElement
function Form:get_panel()
    local panel_name = self:get_panel_name()
    local inner_name = "inner"
    local parent_panel = self:get_parent_panel()
    if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
        return parent_panel[panel_name][inner_name]
    end
    ---main panel
    local frame = GuiFrameV(panel_name):style(defines.mod.styles.frame):caption(self.panel_caption or self.classname)
    local gui_frame = GuiElement.add(parent_panel, frame)
    self:set_style(gui_frame, "flow_panel", "height")
    self:set_style(gui_frame, "flow_panel", "width")
    gui_frame.location = {5,50}
    
    local inner = GuiFrameV(inner_name):style(defines.mod.styles.inner)
    local gui_inner = GuiElement.add(gui_frame, inner)
    return gui_inner
end

-------------------------------------------------------------------------------
---Get or create scroll panel
---@param panel_name string
---@return LuaGuiElement
function Form:get_scroll_panel(panel_name)
  local content_panel = self:get_panel()
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
            local panel = self:get_panel()
            panel.parent.destroy()
        else
            self:get_panel()
        end
    end
    if not (self:is_opened()) then return end
    self:on_event(event)
end

-------------------------------------------------------------------------------
---On event
---@param event EventModData
function Form:on_event(event)
end

-------------------------------------------------------------------------------
---Update
---@param event EventModData
function Form:update(event)
    if not (self:is_opened()) then return end
    local inner_panel = self:get_panel()
    if self.auto_clear then inner_panel.clear() end
    self:on_update(event)
    --self:updateLocation(event)
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function Form:on_update(event)
end
