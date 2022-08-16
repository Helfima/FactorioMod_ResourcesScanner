-------------------------------------------------------------------------------
---Description of the module.
---@class User
local User = {
  ---single-line comment
  classname = "LibUser",
  version = 1,
  prefix = nil,
  default_settings = {},
  mod_preferences = {},
  mod_settings = {},
}

---Get user global data
---@return table
function User.get_global()
  if global["users"] == nil then
    global["users"] = {}
  end
  local user_name = User.name()
  if global["users"][user_name] == nil then
    global["users"][user_name] = {}
  end
  return global["users"][user_name]
end

-------------------------------------------------------------------------------
---Get global variable for user
---@param key string
---@return any
function User.get(key)
  local user_global = User.get_global()
  if key ~= nil then
    if user_global[key] == nil then
      user_global[key] = {}
    end
    return user_global[key]
  end
  return user_global
end

-------------------------------------------------------------------------------
---Set
---@param property string
---@param value any
---@return any
function User.set(property, value)
  User.set_version()
  local user_global = User.get_global()
  user_global[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get version
---@return string
function User.get_version()
  local user_global = User.get_global()
  return user_global["version"] or ""
end

-------------------------------------------------------------------------------
---Set version
---@return any
function User.set_version()
  local user_global = User.get_global()
  user_global["version"] = User.version
  return User.version
end

-------------------------------------------------------------------------------
---Get Name
---@return string
function User.name()
  return Player.native().name or "nil"
end

-------------------------------------------------------------------------------
---Get Name
---@return uint
function User.index()
  return Player.native().index or 0
end

-------------------------------------------------------------------------------
---Return is admin player
---@return boolean
function User.isAdmin()
  return Player.native().admin
end

-------------------------------------------------------------------------------
---Get default settings
---@return table
function User.get_default_settings()
  return User.default_settings
end

-------------------------------------------------------------------------------
---Get parameter
---@param property string
---@return any
function User.get_parameter(property)
  local parameters = User.get("parameters")
  if parameters ~= nil and property ~= nil then
    return parameters[property]
  end
  return parameters
end

-------------------------------------------------------------------------------
---Set parameter
---@param property string
---@param value any
---@return nil
function User.set_parameter(property, value)
  if property == nil then
    return nil
  end
  User.set_version()
  local parameters = User.get("parameters")
  parameters[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get preference
---@param type string
---@param name? string
---@return any
function User.get_preference(type, name)
  local preferences = User.get("preferences")
  if preferences ~= nil and type ~= nil then
    if name ~= nil and name ~= "" then
      local preference_name = string.format("%s_%s", type, name)
      return preferences[preference_name]
    else
      return preferences[type]
    end
  end
  return preferences
end

-------------------------------------------------------------------------------
---Set preference
---@param type string
---@param name string
---@param value any
---@return any
function User.set_preference(type, name, value)
  if type == nil then
    return nil
  end
  User.set_version()
  local preferences = User.get("preferences")
  if name == nil then
    local preference = User.mod_preferences[type]
    if value == nil then
      value = preference.default_value
    end
    if preference.minimum_value ~= nil and value < preference.minimum_value then
      value = preference.default_value
    end
    if preference.maximum_value ~= nil and value > preference.maximum_value then
      value = preference.default_value
    end

    preferences[type] = value
  else
    local preference_name = string.format("%s_%s", type, name)
    preferences[preference_name] = value
  end
  return value
end

-------------------------------------------------------------------------------
---Get user settings
---@return table
function User.get_settings()
  local user_global = User.get_global()
  if user_global["settings"] == nil then
    user_global["settings"] = User.get_default_settings()
  end
  return user_global["settings"]
end

-------------------------------------------------------------------------------
---Get user settings
---@param property string
---@return any
function User.get_setting(property)
  local settings = User.get_settings()
  if settings ~= nil and property ~= nil then
    local value = settings[property]
    if value == nil then
      value = User.get_default_settings()[property]
    end
    return value
  end
  return settings
end

-------------------------------------------------------------------------------
---Set setting
---@param property string
---@param value any
---@return any
function User.set_setting(property, value)
  User.set_version()
  local settings = User.get("settings")
  settings[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get settings
---@param property_name string
---@return any
function User.get_mod_setting(property_name)
  local property = nil
  if User.prefix then
    property_name = string.format("%s_%s",User.prefix,property_name)
  end
  if Player.native() ~= nil then
    property = Player.native().mod_settings[property_name]
  else
    property = settings.global[property_name]
  end
  if property ~= nil then
    return property.value
  else
    return User.mod_settings[property_name].default_value
  end
end

-------------------------------------------------------------------------------
---Get settings
---@param property_name string
---@return any
function User.get_mod_global_setting(property_name)
  local property = nil
  if User.prefix then
    property_name = string.format("%s_%s",User.prefix,property_name)
  end
  property = settings.global[property_name]
  if property ~= nil then
    return property.value
  else
    return User.mod_settings[property_name].default_value
  end
end

-------------------------------------------------------------------------------
---Get preference settings
---@param type string
---@param name string
---@return any
function User.get_preference_setting(type, name)
  local preference_type = User.get_preference(type)
  if name == nil then
    local preference = User.mod_preferences[type]
    if preference_type == nil then
      return preference.default_value
    end
    if preference.minimum_value ~= nil and preference_type < preference.minimum_value then
      return preference.default_value
    end
    if preference.maximum_value ~= nil and preference_type > preference.maximum_value then
      return preference.default_value
    end
    return preference_type
  end
  if preference_type == nil then return false end
  local preference_name = User.get_preference(type, name)
  if preference_name ~= nil then
    return preference_name
  else
    if User.mod_preferences[type].items == nil or User.mod_preferences[type].items[name] == nil then return false end
    return User.mod_preferences[type].items[name]
  end
end

-------------------------------------------------------------------------------
---Reset global variable for user
function User.reset()
  local user_name = User.name()
  global["users"][user_name] = {}
end

-------------------------------------------------------------------------------
---Reset global variable for all user
function User.reset_all()
  global["users"] = {}
end

-------------------------------------------------------------------------------
---Get navigate
---@param property? string
---@return any
function User.get_navigate(property)
  local navigate = User.get("navigate")
  if navigate ~= nil and property ~= nil then
    return navigate[property]
  elseif property ~= nil then
    navigate[property] = {}
    return navigate[property]
  end
  return navigate
end

-------------------------------------------------------------------------------
---Set navigate
---@param property string
---@param value any
---@return any
function User.set_navigate(property, value)
  User.set_version()
  local navigate = User.get("navigate")
  navigate[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get main sizes
---@return number, number
function User.get_main_sizes()
  local width , height = Player.get_display_sizes()
  --local display_ratio_horizontal = User.get_mod_setting("display_ratio_horizontal")
  --local display_ratio_vertictal = User.get_mod_setting("display_ratio_vertical")
  local display_ratio_horizontal = 0.85
  local display_ratio_vertictal = 0.85
  if type(width) == "number" and  type(height) == "number" then
    local width_main = math.ceil(width*display_ratio_horizontal)
    local height_main = math.ceil(height*display_ratio_vertictal)
    return width_main, height_main
  end
  return 800,600
end

-------------------------------------------------------------------------------
---update
function User.update()
  if User.get_version() ~= User.version then
    User.reset()
  end
end

-------------------------------------------------------------------------------
---Add translate
---@param request table --{player_index=number, localised_string=#string, result=#string, translated=#boolean}
function User.add_translate(request)
  if request.translated == true then
    local localised_string = request.localised_string
    local string_translated = request.result
    if type(localised_string) == "table" then
      local localised_value = localised_string[1]
      if localised_value ~= nil and localised_value ~= "" then
        local _,key = string.match(localised_value,"([^.]*).([^.]*)")
        if key ~= nil and key ~= "" then
          local translated = User.get("translated")
          translated[key] = string_translated
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
---Is translate
---@return boolean
function User.is_translate()
  local translated = User.get("translated")
  return translated ~= nil and table.size(translated) > 0
end

-------------------------------------------------------------------------------
---Get translate
---@param name string
---@return any
function User.get_translate(name)
  local translated = User.get("translated")
  if translated == nil or translated[name] == nil then return name end
  return translated[name]
end

-------------------------------------------------------------------------------
---Reset translate
function User.reset_translate()
  local user_global = User.get_global()
  user_global["translated"] = {}
end

-------------------------------------------------------------------------------
---Return Cache User
---@param classname string
---@param name string
---@return any
function User.get_cache(classname, name)
  local data = User.get("cache")
  if classname == nil and name == nil then return data end
  if data[classname] == nil or data[classname][name] == nil then return nil end
  return data[classname][name]
end

-------------------------------------------------------------------------------
---Set Cache User
---@param classname string
---@param name string
---@param value any
function User.set_cache(classname, name, value)
  local data = User.get("cache")
  if data[classname] == nil then data[classname] = {} end
  data[classname][name] = value
end

-------------------------------------------------------------------------------
---Has User Cache
---@param classname string
---@param name string
---@return boolean
function User.has_cache(classname, name)
  local data = User.get("cache")
  return data[classname] ~= nil and data[classname][name] ~= nil
end

-------------------------------------------------------------------------------
---Reset cache
---@param classname string
---@param name string
function User.reset_cache(classname, name)
  local data = User.get("cache")
  if classname == nil and name == nil then
    User.set("cache",{})
  elseif data[classname] ~= nil and name == nil then
    data[classname] = nil
  elseif data[classname] ~= nil then
    data[classname][name] = nil
  end
end

-------------------------------------------------------------------------------
---Get location Form
---@param classname string
---@return table
function User.get_form_location(classname)
  local navigate = User.get_navigate()
  if navigate[classname] == nil or navigate[classname]["location"] == nil then return {x=200,y=100} end
  return navigate[classname]["location"]
end

-------------------------------------------------------------------------------
---Set Close Form
---@param classname string
function User.set_form_opened(classname)
  local navigate = User.get_navigate()
  if navigate[classname] == nil then navigate[classname] = {} end
  navigate[classname]["open"] = true
end

-------------------------------------------------------------------------------
---Set Close Form
---@param classname string
---@param location table
function User.set_form_close(classname, location)
  local navigate = User.get_navigate()
  if navigate[classname] == nil then navigate[classname] = {} end
  navigate[classname]["open"] = false
  navigate[classname]["location"] = location
end

return User