
---Definition of class base
---@class newclass
local newclass = {
    ---Initialize
    ---@param base newclass
    ---@param param any
    init=function(base, param)end,
}

---@class EventModData : EventData
---@field player_index uint
---@field element LuaGuiElement
---@field classname string
---@field action string
---@field item1 string
---@field item2 string
---@field item3 string
---@field item4 string

---@class ResourceData
---@field position MapPosition
---@field name string
---@field type string
---@field amount uint