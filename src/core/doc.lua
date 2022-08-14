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
---Dictionnary {[resource.key] : ResourceData}
---@field resources {[uint] : ResourceData}

---@class ChunkData : ChunkPositionAndArea
---@field patchs table

---@class ForceSettingData
---@field limit uint
---@field show boolean

---@class ForceMarkerData
---@field tag_number uint
---@field patch_id uint

---@class ForceData
---Dictionnary {[tag.tag_number] : ForceMarkerData}
---@field markers {[uint] : ForceMarkerData}
---Dictionnary {[resource.key] : ForceSettingData}
---@field settings {[string] : ForceSettingData}

---@class SurfaceData
---Dictionnary {[resource.key] : ResourceData}
---@field resources {[string] : ResourceData}
---Dictionnary {[resource.name] : boolean}
---@field resource_names {[string] : boolean}
---Dictionnary {[path.id] : PatchData}
---@field patchs {[uint] : PatchData}
---@field patch_id uint
---Dictionnary {[force.index] : ForceData}
---@field forces {[uint] : ForceData}

---@class CacheData
---Dictionnary {[surface.index] : SurfaceData}
---@field surfaces {[uint] : SurfaceData}

---Definition of class base
---@class newclass
local newclass = {
    ---Initialize
    ---@param base newclass
    ---@param param any
    init=function(base, param)end,
}