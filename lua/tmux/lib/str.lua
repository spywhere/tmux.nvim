local M = {}

M.format = function (format, tab, ...)
  local args = { ... }
  local unpck = unpack or table.unpack
  return string.gsub(format, '%b{}', function (block)
    local name, fmt = string.match(block, '{([^:]*):(.*)}')
    name = name or string.match(block, '{(.*)}')

    local value = tab[name]

    if type(value) == 'function' then
      value, fmt = value(fmt, unpck(args))
    end

    if fmt then
      return string.format(fmt, value)
    else
      return tostring(value)
    end
  end)
end

return M
