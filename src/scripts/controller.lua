require("gui.Gui")
require("views.Views")
local ModGui = require "mod-gui"

local module = {}

module.views = {}
module.views["RSMapOptionsView"] = MapOptionsView("RSMapOptionsView")

module.update_mod_menu = function()
    local lua_player = Player.native()
    local lua_gui_element = ModGui.get_button_flow(lua_player)
    if lua_gui_element ~= nil and lua_gui_element[defines.mod.action.main] == nil then
        local gui_button = GuiElement.add(lua_gui_element,
            GuiButton(defines.mod.action.main)
            :sprite("menu", defines.sprites.jewel.white, defines.sprites.jewel.black)
            --:style("helmod_button_menu_dark")
            :tooltip({ defines.mod.action.main }))
        gui_button.style.width = 37
        gui_button.style.height = 37
    end
end

module.reset_ui = function()
    for _, locate in pairs(defines.mod.views.locate) do
        local lua_gui_element = Player.get_gui(locate)
        for _, children_name in pairs(lua_gui_element.children_names) do
            local lua_element = lua_gui_element[children_name]
            if lua_element:get_mod() == defines.mod.mod_name then
                lua_element.destroy()
            end
        end
    end
end

local pattern = "([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)"
---@param event EventData.on_gui_click
module.on_gui_action = function(event)
    event.classname, event.action, event.item1, event.item2, event.item3 = string.match(event.element.name, pattern)
    if module.views[event.classname] then
        local view = module.views[event.classname]
        view:event(event)
        view:update(event)
    end
end

local clickable_type = {}
clickable_type["button"] = true
clickable_type["sprite-button"] = true
clickable_type["checkbox"] = true

---@param event EventData.on_gui_click
module.on_gui_click = function(event)
    local ok, err = pcall(function()
        if event ~= nil and event.player_index ~= nil then
            Player.load(event)
            if event.element ~= nil and event.element:get_mod() == defines.mod.mod_name and
                clickable_type[event.element.type] == true then
                module.on_gui_action(event)
            end
        end
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---@param event EventData.on_gui_confirmed
module.on_gui_confirmed = function(event)
    local ok, err = pcall(function()
        if event ~= nil and event.player_index ~= nil then
            Player.load(event)
            if event.element ~= nil and event.element:get_mod() == defines.mod.mod_name and
                event.element.type == "textfield" then
                module.on_gui_action(event)
            end
        end
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---@param event EventData.on_player_created
module.on_player_created = function(event)
    local ok, err = pcall(function()
        if event ~= nil and event.player_index ~= nil then
            Player.load(event)
            module.update_mod_menu()
        end
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---@param event EventData.on_player_joined_game
module.on_player_joined_game = function(event)
    local ok, err = pcall(function()
        if event ~= nil and event.player_index ~= nil then
            Player.load(event)
            module.update_mod_menu()
        end
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

---@param event EventData.on_console_command
module.on_console_command = function(event)
    local ok, err = pcall(function()
        if event ~= nil and event.player_index ~= nil then
            if event.command == defines.mod.command.name then
                Player.load(event)
                if event.parameters == defines.mod.command.action.menu then
                    module.update_mod_menu()
                end
                if event.parameters == defines.mod.command.action.reset_ui then
                    module.reset_ui()
                end
            end
        end
    end)
    if not (ok) then
        Player.print(err)
        log(err)
    end
end

module.events =
{
    [defines.events.on_console_command] = module.on_console_command,
    [defines.events.on_player_created] = module.on_player_created,
    [defines.events.on_player_joined_game] = module.on_player_joined_game,
    [defines.events.on_gui_click] = module.on_gui_click,
    [defines.events.on_gui_confirmed] = module.on_gui_confirmed,
}

return module
