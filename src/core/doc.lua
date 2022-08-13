---@class EventModData : EventData
---@field player_index uint
---@field element LuaGuiElement
---@field classname string
---@field action string
---@field item1 string
---@field item2 string

---@class ParametersData
---@field index uint
---@field player_index uint
---@field action string
---@field resource_names {[uint] : string}
---@field resource_limit string
---@field event CustomCommandData
---@field force_id uint
---@field surface_id uint
---@field surface_name string

---@class ResourceData
---@field position MapPosition
---@field name string
---@field type string
---@field amount uint
---@field patch_id uint

---@class PatchData
---@field id uint
---@field name string
---@field icon {name:string, type:string}
---@field amount uint
---@field area BoundingBox
---@field resources {[uint] : ResourceData}
---@field tag_number uint

---@class ChunkData : ChunkPositionAndArea
---@field patchs table

---@class CacheData
--- Dictionnary {[surface.index] : {[force.index] : CacheResources}}
---@field surfaces {[uint] : {[uint] : CacheResources}}

---@class CacheResources
---@field resources {[string] : ResourceData}
---@field patchs {[uint] : PatchData}
---@field patch_id uint
---@field markers {[uint] : boolean}
---@field settings {[string] : {limit:uint, show:boolean}}

---Definition of class base
---@class newclass
local newclass = {
    ---Initialize
    ---@param base newclass
    ---@param param any
    init=function(base, param)end,
}