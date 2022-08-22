-------------------------------------------------------------------------------
---Class to help to build flow
---@class GuiFlow : GuiElement
GuiFlow = newclass(GuiElement, function(base, ...)
  GuiElement.init(base, ...)
  base.classname = "HMGuiFlow"
  base.options.type = "flow"
end)

-------------------------------------------------------------------------------
---@class GuiFlowH : GuiFlow
GuiFlowH = newclass(GuiFlow, function(base, ...)
  GuiFlow.init(base, ...)
  base.options.direction = defines.gui.direction.horizontal
  base.options.style = defines.gui.styles.flow.horizontal
end)

-------------------------------------------------------------------------------
---@class GuiFlowV : GuiFlow
GuiFlowV = newclass(GuiFlow, function(base, ...)
  GuiFlow.init(base, ...)
  base.options.direction = defines.gui.direction.vertical
  base.options.style = defines.gui.styles.flow.vertical
end)
