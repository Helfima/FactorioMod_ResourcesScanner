local pow_chars =
{
  k = 10^3,
  K = 10^3,
  M = 10^6,
  G = 10^9,
  T = 10^12,
  P = 10^15,
  E = 10^18,
  Z = 10^21,
  Y = 10^24
}

string.parse_number = function(value)
  if value == nil or value == "" then error("invalid value!") end
  if tonumber(value) then return tonumber(value) end
  local magnitude = value:sub(-1)
  -- si pas de magnitude c'est un nombre
  if tonumber(magnitude) then return tonumber(value) end
  local multiplier = pow_chars[magnitude]
  local number = tonumber(value:sub(1, value:len()-1))
  return  number * multiplier
end