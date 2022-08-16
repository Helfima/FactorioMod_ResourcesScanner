Logging = {}

function Logging:new(level)
  self.limit = 5
  self.level = level or 0
  self.debug_values = {none=0,error=1,warn=2,info=3,debug=4,trace=5}
end

function Logging:trace(...)
  if self.debug_values.trace > self.level then return end
  local arg = {...}
  self:logging("[TRACE]", self.debug_values.trace, table.unpack(arg))
end

function Logging:debug(...)
  if self.debug_values.debug > self.level then return end
  local arg = {...}
  self:logging("[DEBUG]", self.debug_values.debug, table.unpack(arg))
end

function Logging:info(...)
  if self.debug_values.info > self.level then return end
  local arg = {...}
  self:logging("[INFO ]", self.debug_values.info, table.unpack(arg))
end

function Logging:warn(...)
  if self.debug_values.warn > self.level then return end
  local arg = {...}
  self:logging("[WARN ]", self.debug_values.warn, table.unpack(arg))
end

function Logging:error(...)
  if self.debug_values.error > self.level then return end
  local arg = {...}
  self:logging("[ERROR]", self.debug_values.error, table.unpack(arg))
end

function Logging:line(...)
  if self.debug_values.debug > self.level then return end
  local arg = {...}
  self:previousCall("[DEBUG]", table.unpack(arg))
end

function Logging:objectToString(object, level)
  if level == nil then level = 0 end
  local message = ""
  if type(object) == "nil" then
    message = message.." nil"
  elseif type(object) == "boolean" then
    if object then message = message.." true"
    else message = message.." false" end
  elseif type(object) == "number" then
    message = message.." "..object
  elseif type(object) == "string" then
    message = message.."\""..object.."\""
  elseif type(object) == "function" then
    message = message.."\"__function\""
  elseif object.isluaobject then
    if object.valid then
      local help = nil
      pcall(function() help = object.help() end)
      if help ~= nil and help ~= "" then
        local lua_type = string.match(help, "Help for%s([^:]*)")
        if lua_type == "LuaCustomTable" then
          local custom_table = {}
          for _,element in pairs(object) do
            table.insert(custom_table, element)
          end
          return self:objectToString(custom_table, level)
        elseif string.find(lua_type, "Lua") then
          local object_name = "unknown"
          pcall(function() object_name = object.name end)
          message = message..string.format("{\"type\":%q,\"name\":%q}", lua_type, object_name or "nil")
        else
          message = message..string.format("{\"type\":%q,\"name\":%q}", object.type or "nil", object.name or "nil")
        end
      else
        message = message.."invalid object"
      end
    else
      message = message.."invalid object"
    end
  elseif type(object) == "table" then
    if level <= self.limit then
      local first = true
      message = message.."{"
      for key, nextObject in pairs(object) do
        if not first then message = message.."," end
        message = message.."\""..key.."\""..":"..self:objectToString(nextObject, level + 1);
        first = false
      end
      message = message.."}"
    else
      message = message.."\"".."__table".."\""
    end
  end
  return string.gsub(message,"\n","")
end

function Logging:logging(tag, level, ...)
  local arg = {...}
  if arg == nil then arg = "nil" end
  local message = "";
  for key, object in pairs(arg) do
    message = message..self:objectToString(object)
  end
  local debug_info = debug.getinfo(3)
  self:writer(string.format("%s %s:%s|%s", tag, string.match(debug_info.source,"[^/]*$"), debug_info.currentline, message))
end

function Logging:previousCall(tag, back)
  local debug_info = debug.getinfo(back+2)
  self:writer(string.format("%s|%s:%s", tag, string.match(debug_info.source,"[^/]*$"), debug_info.currentline))
end

function Logging:writer(message)
  log(message)
end