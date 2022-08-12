-------------------------------------------------------------------------------
---@class Resource
local Resource = {
  ---single-line comment
  classname = "HMCache"
}

---get resource key
---@param resource ResourceData|LuaEntity
---@return string
Resource.get_key = function (resource)
    return string.format("%s,%s", resource.position.x, resource.position.y)
end

---create resource
---@param resource LuaEntity
---@return ResourceData
Resource.create = function(resource)
    ---@type ResourceData
    local new_resource = {
        name=resource.name,
        type=resource.type,
        position=resource.position,
        amount=resource.amount
    }
    Surface.add_resource(new_resource)
    return new_resource
end

---@param resource LuaEntity
---@return string
Resource.get_product_type = function(resource)
    local type = "item"
    local product = Resource.get_product(resource)
    if product ~= nil then
        type = product.type
    end
    return type
end
---@param resource LuaEntity
---@return Product|nil
Resource.get_product = function(resource)
    local products = resource.prototype.mineable_properties.products
    if products ~= nil then
        return products[1]
    end
    return nil
end

---@param resource LuaEntity
Resource.get_icon = function(resource)
    local name = resource.name
    local type = "item"
    local product = Resource.get_product(resource)
    if product ~= nil then
        name = product.name
        type = product.type
    end
    local icon = {name=name, type=type}
    return icon
end

return Resource