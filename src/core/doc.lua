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
---@field chunks ChunkData
---@field patch_ids {[uint] : uint}

---@class ChunkData : ChunkPositionAndArea
---Dictionnary {[path.id] : PatchData}
---@field patchs {[uint] : boolean}

---@class PatchData
---@field id uint
---@field name string
---@field icon {name:string, type:string}
---@field amount uint
---@field tag_number uint
---@field area BoundingBox
---Dictionnary {[chunk.key] : boolean}
---@field chunks {[string] : boolean}

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
---Dictionnary {[chunk.key] : ChunkData}
---@field chunks {[string] : ChunkData}
---Dictionnary {[resource.name] : boolean}
---@field resource_names {[string] : boolean}
---Dictionnary {[path.id] : PatchData}
---@field patchs {[uint] : PatchData}
---@field patch_id uint
---Dictionnary {[force.index] : ForceData}
---@field forces {[uint] : ForceData}

---@class SurfacesData
---Dictionnary {[surface.index] : SurfaceData}
---@field surfaces {[uint] : SurfaceData}
