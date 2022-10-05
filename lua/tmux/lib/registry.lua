local std = {}
std.count = function ()
  local i = 0
  return function ()
    i = i + 1
    return i
  end
end
std.wrap = function (value)
  if type(value) == 'table' then
    return value
  else
    return { value }
  end
end

_fn = {}
local M = {}

local _group = nil
local increment = std.count()

M.group = function (group_name, group_fn)
  local name = group_name
  local group = group_fn
  if group then
    assert(
      type(name) == 'string' or type(name) == 'number',
      'group name must be a string or number'
    )
    assert(type(group) == 'function', 'group must be a function')
  else
    assert(type(name) == 'function', 'group must be a function')
    group = name
    name = nil
  end
  _group = vim.api.nvim_create_augroup(
    name or string.format('_lua_%s', increment()),
    {}
  )
  group()
  _group = nil
end

M.auto = function (_events, func, _filter, _modifiers)
  if not _group then
    M.group(
      function ()
        M.auto(_events, func, _filter, _modifiers)
      end
    )
    return
  end

  local events = std.wrap(_events)
  for event in ipairs(events) do
    assert(vim.fn.exists('##' .. event))
  end

  local filter = std.wrap(_filter or '*')

  vim.api.nvim_create_autocmd(events, {
    group = _group,
    pattern = filter,
    callback = func
  })
end

M.call_for_fn = function (func, args)
  local call = { 'v:lua' }
  local index = increment()
  _fn['_' .. index] = func
  local arguments = table.concat(std.wrap(args) or {}, ',')
  table.insert(call, '_fn._' .. index .. '(' .. arguments .. ')')
  return table.concat(call, '.')
end

M.fn = function (fn_signature, fn_ref)
  local func = fn_ref
  local signature = fn_signature or {}
  if type(signature) == 'function' then
    func = signature
    signature = {}
  end
  local name = signature.name or string.format(
    '_lua_%s',
    increment()
  )
  assert(type(name) == 'string', 'function name must be a string')
  assert(
    func,
    'callback function is required for function \'' .. name .. '\''
  )
  assert(
    type(func) == 'function',
    'callback function must be a function for function \'' .. name .. '\''
  )

  local params = {}
  local args = {}
  for k, v in pairs(signature) do
    if type(k) == 'number' and type(v) == 'string' then
      table.insert(params, v)
      table.insert(args, 'a:' .. v)
    end
  end
  local definition = {
    'function! ' .. name .. '(' .. table.concat(params, ',') ..')',
    'return ' .. M.call_for_fn(func, args),
    'endfunction'
  }
  vim.api.nvim_exec(table.concat(definition, '\n'), false)
  return name
end

return M
