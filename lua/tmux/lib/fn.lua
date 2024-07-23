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
  local function recurse(time, ...)
    local args = {...}
    if time < count then
      return function (...)
        return recurse(time + 1, unpack(args), ...)
      end
    elseif callback then
      return callback(unpack(args))
    end
  end

  return function (...)
    return recurse(1, ...)
  end
end

return M
