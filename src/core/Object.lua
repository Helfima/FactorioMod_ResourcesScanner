-------------------------------------------------------------------------------
--- Class Object
---
---@class Object : newclass
---@field classname string
Object = newclass(function(base, classname)
    base.classname = classname
    base:on_init()
end)

-------------------------------------------------------------------------------
---On initialization
function Object:on_init()
end
