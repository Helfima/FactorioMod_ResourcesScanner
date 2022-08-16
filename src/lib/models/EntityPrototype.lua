-------------------------------------------------------------------------------
---Description of the module.
---@class EntityPrototype
local EntityPrototype = {
  ---single-line comment
  classname = "LibEntityPrototype"
}

---get entity key
---@param entity LuaEntityPrototype
---@return string
EntityPrototype.get_key = function (entity)
    return string.format("%s=%s", entity.type, entity.name)
end

---@param entity LuaEntityPrototype
---@return Product|nil
EntityPrototype.get_product = function(entity)
    local products = entity.mineable_properties.products
    if products ~= nil then
        return products[1]
    end
    return nil
end

---@param entity LuaEntityPrototype
EntityPrototype.get_icon = function(entity)
    local name = entity.name
    local type = "item"
    local product = EntityPrototype.get_product(entity)
    if product ~= nil then
        name = product.name
        type = product.type
    end
    local icon = {name=name, type=type}
    return icon
end

---@param entity LuaEntityPrototype
EntityPrototype.get_icon_string = function(entity)
    local icon = EntityPrototype.get_icon(entity)
    return string.format("[%s=%s]", icon.type, icon.name)
end

return EntityPrototype
