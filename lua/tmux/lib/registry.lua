local logger = require('tmux.lib.logger')
local _registry = 'tmux.lib.registry'
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
local _plugins = {}
local _pre = {}
local _post = {}
local _defers = {}
local _callbacks = {}
local _experiments = {}
local increment = std.count()

local remove = function (index, group_name)
  local clear = 'autocmd! ' .. group_name
  _callbacks[index] = nil
  vim.api.nvim_command(clear)
end

M._call = function (index, group_name, ...)
  local kill = function ()
    remove(index, group_name)
  end
  _callbacks[index](M, kill, ...)
end

M.group = function (group_name, group_fn)
  if _group then
    logger.error('still defining autogroup \'' .. _group.name .. '\'')
    return
  end

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
  _group = {
    name = name or increment()
  }
  _group.expression = {
    'augroup ' .. _group.name,
    'autocmd!'
  }
  group()
  table.insert(_group.expression, 'augroup END')
  vim.api.nvim_exec(table.concat(_group.expression, '\n'), false)
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

  local evnts = std.wrap(_events)
  for event in ipairs(evnts) do
    assert(vim.fn.exists('##' .. event))
  end

  local index = increment()
  local events = table.concat(evnts, ',')
  local filter = table.concat(std.wrap(_filter or '*'), ',')
  local modifiers = table.concat(std.wrap(_modifiers or {}), ' ')
  local call_args = {
    index,
    string.format('%q', _group.name)
  }
  local fn_call = {
    'lua require(\'' .. _registry ..'\')',
    '_call(' .. table.concat(call_args, ', ') .. ')'
  }
  if type(func) == 'string' then
    fn_call = { func }
  else
    _callbacks[index] = func
  end

  local expression = {
    'autocmd',
    events,
    filter,
    modifiers,
    table.concat(fn_call, '.')
  }
  table.insert(_group.expression, table.concat(expression, ' '))

  return function ()
    remove(index, _group.name)
  end
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
