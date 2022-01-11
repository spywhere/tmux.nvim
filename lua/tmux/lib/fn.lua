local M = {}

local unpack = unpack or table.unpack

M.partial = function (size, callback)
  local function recurse(...)
    local args = {...}
    if #args < size then
      return function (...)
        return recurse(unpack(args), ...)
      end
    elseif callback then
      return callback(unpack(args))
    end
  end

  return recurse
end

M.nested = function (count, callback)
  local function recurse(...)
    local args = {...}
    count = count - 1
    if count > 0 then
      return function (...)
        return recurse(unpack(args), ...)
      end
    elseif callback then
      return callback(unpack(args))
    end
  end

  return recurse
end

return M
