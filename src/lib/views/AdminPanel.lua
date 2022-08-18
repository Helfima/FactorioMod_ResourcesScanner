-------------------------------------------------------------------------------
---Class to build panel
---@class AdminPanel : Form
AdminPanel = newclass(Form, function(base, classname)
  Form.init(base, classname)
  base.inner_frame = defines.mod.styles.inner_tab
  base.auto_clear = false
end)

-------------------------------------------------------------------------------
---On initialization
function AdminPanel:on_init()
  self.panel_caption = ({ "helmod_result-panel.tab-button-admin" })
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function AdminPanel:on_style(styles, width_main, height_main)
  styles.flow_panel = {
    width = 500,
    height = 400,
  }
end

-------------------------------------------------------------------------------
---Return button caption
---@return table
function AdminPanel:get_button_caption()
  return { "helmod_result-panel.tab-button-admin" }
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return string,string
function AdminPanel:get_button_sprites()
  return defines.sprites.database_settings.white, defines.sprites.database_settings.black
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function AdminPanel:is_visible()
  return Player.is_admin()
end

-------------------------------------------------------------------------------
---Is special
---@return boolean
function AdminPanel:is_special()
  return true
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function AdminPanel:get_tab_pane()
  local content_panel = self:get_flow_panel("panel", "vertical")
  local panel_name = "tab_panel"
  local name = table.concat({ self.classname, "change-tab", panel_name }, "=")
  if content_panel[name] ~= nil and content_panel[name].valid then
    return content_panel[name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(self.classname, "change-tab", panel_name))
  return panel
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@param panel_name string
---@param caption string
---@return LuaGuiElement
function AdminPanel:get_tab(panel_name, caption)
  local content_panel = self:get_tab_pane()
  local scroll_name = "scroll-" .. panel_name
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption(caption))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"):policy(true))
  content_panel.add_tab(tab_panel, scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create cache tab panel
---@return LuaGuiElement
function AdminPanel:get_tab_cache()
  return self:get_tab("cache-tab-panel", { "helmod_result-panel.cache-list" })
end

-------------------------------------------------------------------------------
---Get or create mods tab panel
---@return LuaGuiElement
function AdminPanel:get_tab_mod()
  return self:get_tab("mod-tab-panel", { "helmod_common.mod-list" })
end

-------------------------------------------------------------------------------
---Get or create gui tab panel
---@return LuaGuiElement
function AdminPanel:get_tab_gui()
  return self:get_tab("gui-tab-panel", { "helmod_common.gui-list" })
end

-------------------------------------------------------------------------------
---Get or create global tab panel
---@return LuaGuiElement
function AdminPanel:get_tab_global()
  return self:get_tab("global-tab-panel", "Global")
end

-------------------------------------------------------------------------------
---is global tab panel
---@return boolean
function AdminPanel:is_tab_global()
  local tab_pane = self:get_tab_pane()
  return tab_pane["global-tab-panel"] ~= nil
end

-------------------------------------------------------------------------------
---On Update
---@param event EventModData
function AdminPanel:on_update(event)
  self:update_cache()
  self:update_mod()
  self:update_gui()
  self:update_global()

  self:get_tab_pane().selected_tab_index = User.get_parameter("admin_selected_tab_index") or 1
end

-------------------------------------------------------------------------------
---Update Gui Tab
function AdminPanel:update_gui()
  ---Rule List
  local scroll_panel = self:get_tab_gui()
  scroll_panel.clear()

  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(3):style("helmod_table_border"))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 5

  self:add_cell_header(table_panel, "location",
    { "", defines.mod.tags.font.default_bold, { "helmod_common.location" }, defines.mod.tags.font.close })
  self:add_cell_header(table_panel, "_name",
    { "", defines.mod.tags.font.default_bold, { "helmod_result-panel.col-header-name" }, defines.mod.tags.font.close })
  self:add_cell_header(table_panel, "mod",
    { "", defines.mod.tags.font.default_bold, { "helmod_common.mod" }, defines.mod.tags.font.close })

  local index = 0
  for _, location in pairs({ "top", "left", "center", "screen", "goal" }) do
    for _, element in pairs(Player.get_gui(location).children) do
      if element.name == "mod_gui_button_flow" or element.name == "mod_gui_frame_flow" then
        for _, element in pairs(element.children) do
          GuiElement.add(table_panel, GuiLabel("location", index):caption(location))
          GuiElement.add(table_panel, GuiLabel("_name", index):caption(element.name))
          GuiElement.add(table_panel, GuiLabel("mod", index):caption(element.get_mod() or "base"))
          index = index + 1
        end
      else
        GuiElement.add(table_panel, GuiLabel("location", index):caption(location))
        GuiElement.add(table_panel, GuiLabel("_name", index):caption(element.name))
        GuiElement.add(table_panel, GuiLabel("mod", index):caption(element.get_mod() or "base"))
        index = index + 1
      end
    end
  end
end

-------------------------------------------------------------------------------
---Update Mod Tab
function AdminPanel:update_mod()
  ---Rule List
  local scroll_panel = self:get_tab_mod()
  scroll_panel.clear()

  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(2):style("helmod_table_border"))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 50

  self:add_cell_header(table_panel, "_name",
    { "", defines.mod.tags.font.default_bold, { "helmod_result-panel.col-header-name" }, defines.mod.tags.font.close })
  self:add_cell_header(table_panel, "version",
    { "", defines.mod.tags.font.default_bold, { "helmod_common.version" }, defines.mod.tags.font.close })

  for name, version in pairs(game.active_mods) do
    GuiElement.add(table_panel, GuiLabel("_name", name):caption(name))
    GuiElement.add(table_panel, GuiLabel("version", name):caption(version))
  end
end

-------------------------------------------------------------------------------
---Update Cache Tab
function AdminPanel:update_cache()
  ---Rule List
  local scroll_panel = self:get_tab_cache()
  scroll_panel.clear()

  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(2))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 50

  if table.size(Cache.get()) > 0 then
    local translate_panel = GuiElement.add(table_panel, GuiFlowV("global-caches"))
    GuiElement.add(translate_panel,
      GuiLabel("translate-label"):caption("Global caches"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(translate_panel, GuiTable("list-data"):column(3))
    self:add_cache_list_header(result_table)

    for key1, data1 in pairs(Cache.get()) do
      self:add_cache_list_row(result_table, "caches", key1, nil, nil, nil, data1)
      for key2, data2 in pairs(data1) do
        self:add_cache_list_row(result_table, "caches", key1, key2, nil, nil, data2)
      end
    end
  end

  local users_data = global["users"]
  if table.size(users_data) > 0 then
    local cache_panel = GuiElement.add(table_panel, GuiFlowV("user-caches"))
    GuiElement.add(cache_panel, GuiLabel("translate-label"):caption("User caches"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(cache_panel, GuiTable("list-data"):column(3))
    self:add_cache_list_header(result_table)

    for key1, data1 in pairs(users_data) do
      self:add_cache_list_row(result_table, "users", key1, nil, nil, nil, data1)
      for key2, data2 in pairs(data1) do
        self:add_cache_list_row(result_table, "users", key1, key2, nil, nil, data2)
        if key2 == "cache" then
          for key3, data3 in pairs(data2) do
            self:add_cache_list_row(result_table, "users", key1, key2, key3, nil, data3)
            if string.find(key3, "^HM.*") then
              for key4, data4 in pairs(data3) do
                self:add_cache_list_row(result_table, "users", key1, key2, key3, key4, data4)
              end
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
---Add Translate List header
---@param itable LuaGuiElement
function AdminPanel:add_translate_list_header(itable)
  ---col action
  self:add_cell_header(itable, "action", { "helmod_result-panel.col-header-action" })
  ---data
  self:add_cell_header(itable, "header-owner", { "helmod_result-panel.col-header-owner" })
  self:add_cell_header(itable, "header-total", { "helmod_result-panel.col-header-total" })
end

-------------------------------------------------------------------------------
---Add Cache List header
---@param itable LuaGuiElement
function AdminPanel:add_cache_list_header(itable)
  ---col action
  self:add_cell_header(itable, "action", { "helmod_result-panel.col-header-action" })
  ---data
  self:add_cell_header(itable, "header-owner", { "helmod_result-panel.col-header-owner" })
  self:add_cell_header(itable, "header-total", { "helmod_result-panel.col-header-total" })
end

-------------------------------------------------------------------------------
---Add row translate List
---@param itable LuaGuiElement
---@param user_name string
---@param user_data table
function AdminPanel:add_translate_list_row(itable, user_name, user_data)
  ---col action
  local cell_action = GuiElement.add(itable, GuiTable("action", user_name):column(4))

  ---col owner
  GuiElement.add(itable, GuiLabel("owner", user_name):caption(user_name))

  ---col translated
  GuiElement.add(itable, GuiLabel("total", user_name):caption(table.size(user_data.translated)))

end

-------------------------------------------------------------------------------
---Add row cache List
---@param gui_table LuaGuiElement
---@param class_name string
---@param key1 string
---@param key2 string
---@param key3 string
---@param key4 string
---@param data table
function AdminPanel:add_cache_list_row(gui_table, class_name, key1, key2, key3, key4, data)
  local caption = ""
  if type(data) == "table" then
    caption = table.size(data)
  else
    caption = data
  end

  ---col action
  local cell_action = GuiElement.add(gui_table,
    GuiTable("action", string.format("%s-%s-%s-%s", key1, key2, key3, key4)):column(4))
  if key2 == nil and key3 == nil and key4 == nil then
    if class_name ~= "users" then
      GuiElement.add(cell_action,
        GuiButton(self.classname, "delete-cache", class_name, key1):sprite("menu", defines.sprites.close.black,
          defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({ "helmod_button.remove" }))
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1):caption({ "", defines.mod.tags.color.orange, defines.mod.tags.font.default_large_bold,
          string.format("%s", key1), defines.mod.tags.font.close, defines.mod.tags.color.close }))
    else
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1):caption({ "", defines.mod.tags.color.blue, defines.mod.tags.font.default_large_bold,
          string.format("%s", key1), defines.mod.tags.font.close, defines.mod.tags.color.close }))
    end

    ---col count
    GuiElement.add(gui_table,
      GuiLabel("total", key1):caption({ "", defines.mod.tags.font.default_semibold, caption, defines.mod.tags.font.close }))
  elseif key3 == nil and key4 == nil then
    if class_name == "users" and (key2 == "translated" or key2 == "cache") then
      GuiElement.add(cell_action,
        GuiButton(self.classname, "delete-cache", class_name, key1, key2):sprite("menu", defines.sprites.close.black,
          defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({ "tooltip.remove-element" }))
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1, key2):caption({ "", defines.mod.tags.color.orange, defines.mod.tags.font.default_bold,
          "|-", key2, defines.mod.tags.font.close, defines.mod.tags.color.close }))
    else
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1, key2):caption({ "", defines.mod.tags.font.default_bold, "|-", key2,
          defines.mod.tags.font.close }))
    end

    ---col count
    GuiElement.add(gui_table,
      GuiLabel("total", key1, key2):caption({ "", defines.mod.tags.font.default_semibold, caption,
        defines.mod.tags.font.close }))
  elseif key4 == nil then
    if class_name == "users" then
      GuiElement.add(cell_action,
        GuiButton(self.classname, "delete-cache", class_name, key1, key2, key3):sprite("menu",
          defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({ "tooltip.remove-element" }))
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1, key2, key3):caption({ "", defines.mod.tags.color.orange,
          defines.mod.tags.font.default_bold, "|\t\t\t|-", key3, defines.mod.tags.font.close,
          defines.mod.tags.color.close }))
    else
      ---col class
      GuiElement.add(gui_table,
        GuiLabel("class", key1, key2, key3):caption({ "", defines.mod.tags.font.default_bold, "|-", key3,
          defines.mod.tags.font.close }))
    end

    ---col count
    GuiElement.add(gui_table,
      GuiLabel("total", key1, key2, key3):caption({ "", defines.mod.tags.font.default_semibold, caption,
        defines.mod.tags.font.close }))
  else
    GuiElement.add(gui_table,
      GuiLabel("class", key1, key2, key3, key4):caption({ "", defines.mod.tags.font.default_bold, "|\t\t\t|\t\t\t|-",
        key4, defines.mod.tags.font.close }))

    ---col count
    GuiElement.add(gui_table,
      GuiLabel("total", key1, key2, key3, key4):caption({ "", defines.mod.tags.font.default_semibold, caption,
        defines.mod.tags.font.close }))
  end

end

local color_name = "blue"
local color_index = 1
local bar_thickness = 2
-------------------------------------------------------------------------------
---Update Global Table
function AdminPanel:update_global()
  if self:is_tab_global() then return end
  local scroll_panel = self:get_tab_global()
  local root_branch = GuiElement.add(scroll_panel, GuiFlowV())
  root_branch.style.vertically_stretchable = false
  self:create_tree(root_branch, { global = global }, true)
end

-------------------------------------------------------------------------------
---Create Tree
---@param parent LuaGuiElement
---@param list table
---@param expand boolean
function AdminPanel:create_tree(parent, list, expand)
  local data_info = table.data_info(list)
  local index = 1
  local size = table.size(list)
  for k, info in pairs(data_info) do
    local tree_branch = GuiElement.add(parent, GuiFlowH())
    -- vertical bar
    local vbar = GuiElement.add(tree_branch, GuiFrameV("vbar"):style("blurry_frame"))
    vbar.style.width = bar_thickness
    vbar.style.left_margin = 15
    if index == size then
      vbar.style.height = 12
    else
      vbar.style.vertically_stretchable = true
      vbar.style.bottom_margin = 0
    end
    -- content
    local content = GuiElement.add(tree_branch, GuiFlowV("content"))
    -- header
    local header = GuiElement.add(content, GuiFlowH("header"))
    local hbar = GuiElement.add(header, GuiFrameV("hbar"):style("subheader_frame"))
    hbar.style.width = 5
    hbar.style.height = bar_thickness
    hbar.style.top_margin = 10
    hbar.style.right_margin = 5
    if info.type == "table" then
      if index >= 25 then
        local caption = { "", defines.mod.tags.font.default_bold, defines.mod.tags.color.green_light, "... (expand)",
        defines.mod.tags.color.close, defines.mod.tags.font.close}
        local label = GuiElement.add(header, GuiLabel(self.classname, "global-continue", "bypass"):caption(caption))
        label.tags = table.slice(list, 25)
      else
        local caption = { "", defines.mod.tags.font.default_bold, defines.mod.tags.color.green_light, k,
        defines.mod.tags.color.close, defines.mod.tags.font.close, " [", table.size(info.value), "]", " (", info.type, ")"}
        if expand then
          GuiElement.add(header, GuiLabel("global-end"):caption(caption))
        else
          local label = GuiElement.add(header, GuiLabel(self.classname, "global-update", "bypass"):caption(caption))
          label.tags = info
        end
      end
    else
      local caption = { "", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, k,
        defines.mod.tags.color.close, defines.mod.tags.font.close, "=", defines.mod.tags.font.default_bold, info.value,
        defines.mod.tags.font.close, " (", info.type, ")" }
      local label = GuiElement.add(header, GuiLabel("global-end"):caption(caption))
    end
    -- next
    local next = GuiElement.add(content, GuiFlowV("next"))

    if expand then
      self:create_tree(next, info.value, false)
    else
      next.visible = false
    end
    index = index + 1
    if index > 25 then
      break
    end
  end
end

-------------------------------------------------------------------------------
---On event
---@param event EventModData
function AdminPanel:on_event(event)
  if event.action == "change-tab" then
    User.set_parameter("admin_selected_tab_index", event.element.selected_tab_index)
  end

  if not (User.isAdmin()) then return end

  if event.action == "global-update" then
    local element = event.element
    local content = element.parent.parent
    local parent_next = content.next
    if #parent_next.children > 0 then
      for _, child in pairs(parent_next.children) do
        child.destroy()
      end
      parent_next.visible = false
    else
      local list = element.tags.value
      parent_next.visible = true
      self:create_tree(parent_next, list)
    end
  end

  if event.action == "global-continue" then
    local element = event.element
    local content = element.parent.parent
    local parent_next = content.parent.parent
    local list = element.tags
    content.parent.destroy()
    self:create_tree(parent_next, list)
  end

  if event.action == "delete-cache" then
    if event.item1 ~= nil and global[event.item1] ~= nil then
      if event.item2 == "" and event.item3 == "" and event.item4 == "" then
        global[event.item1] = nil
      elseif event.item3 == "" and event.item4 == "" then
        global[event.item1][event.item2] = {}
      elseif event.item4 == "" then
        global[event.item1][event.item2][event.item3] = nil
      else
        global[event.item1][event.item2][event.item3][event.item4] = nil
      end
      Player.print("Deleted:", event.item1, event.item2, event.item3, event.item4)
    else
      Player.print("Not found to delete:", event.item1, event.item2, event.item3, event.item4)
    end
    --Controller:send("on_gui_update", event)
  end

end
