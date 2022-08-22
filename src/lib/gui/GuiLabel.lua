-------------------------------------------------------------------------------
--- Class to help to build GuiLabel
---@class GuiLabel : GuiElement
GuiLabel = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLabel"
  base.options.type = "label"
end)

-------------------------------------------------------------------------------
---Set wrap
---@param wrap boolean
---@return GuiLabel
function GuiLabel:wordWrap(wrap)
  self.options.word_wrap = wrap
  return self
end

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiLabel
function GuiLabel:color(color)
  local color = defines.tag.color[color] or defines.tag.color.orange
  self.m_caption = {"", color, self.m_caption, defines.tag.color.close}
  return self
end