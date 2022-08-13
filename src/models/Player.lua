-------------------------------------------------------------------------------
---Description of the module.
---@class Player
local Player = {
  ---single-line comment
  classname = "HMPlayer"
}

local Lua_player = nil

-------------------------------------------------------------------------------
---Print message
function Player.print(...)
  if Lua_player ~= nil then
    Lua_player.print(table.concat({ ... }, " "))
  end
end

-------------------------------------------------------------------------------
---Print message
function Player.printf(format, ...)
  if Lua_player ~= nil then
    Lua_player.print(string.format(format, ...))
  end
end

-------------------------------------------------------------------------------
---Load factorio player
---@param event CustomCommandData
---@return Player
function Player.load(event)
  Lua_player = game.players[event.player_index]
  return Player
end

-------------------------------------------------------------------------------
---Set factorio player
---@param player LuaPlayer
---@return Player
function Player.set(player)
  Lua_player = player
  return Player
end

-------------------------------------------------------------------------------
---Get game day
---@return number, number, number, number
function Player.get_game_day()
  local surface = game.surfaces[1]
  local day = surface.ticks_per_day
  local dusk = surface.evening - surface.dusk
  local night = surface.morning - surface.evening
  local dawn = surface.dawn - surface.morning
  return day, day * dusk, day * night, day * dawn
end

------------------------------------------------------------------------------
---Get display sizes
---@return number, number
function Player.get_display_sizes()
  if Lua_player == nil then return 800, 600 end
  local display_resolution = Lua_player.display_resolution
  local display_scale = Lua_player.display_scale
  return display_resolution.width / display_scale, display_resolution.height / display_scale
end

-------------------------------------------------------------------------------
---Return entity prototypes
---@param filters table --{{filter="type", mode="or", invert=false type="transport-belt"}}
---@return table
function Player.get_entity_prototypes(filters)
  if filters ~= nil then
    return game.get_filtered_entity_prototypes(filters)
  end
  return game.entity_prototypes
end

-------------------------------------------------------------------------------
---Return resources list
---@return {[uint] : LuaEntityPrototype}
function Player.get_resource_entity_prototypes()
  local filters = { { filter = "type", invert = false, mode = "or", type = "resource" } }
  return Player.get_entity_prototypes(filters)
end

-------------------------------------------------------------------------------
---Return force's player
---@return LuaForce
function Player.get_force()
  return Lua_player.force
end

-------------------------------------------------------------------------------
---Return force's player
---@return LuaSurface
function Player.get_surface()
  return Lua_player.surface
end

-------------------------------------------------------------------------------
---Is valid sprite path
---@param sprite_path string
---@return boolean
function Player.is_valid_sprite_path(sprite_path)
  if Lua_player == nil then return false end
  return Lua_player.gui.is_valid_sprite_path(sprite_path)
end

-------------------------------------------------------------------------------
---Return factorio player
---@return LuaPlayer
function Player.native()
  return Lua_player
end

-------------------------------------------------------------------------------
---Return admin player
---@return boolean
function Player.is_admin()
  return Lua_player.admin
end

-------------------------------------------------------------------------------
---Get gui
---@param location string
---@return LuaGuiElement
function Player.get_gui(location)
  return Lua_player.gui[location]
end

return Player
