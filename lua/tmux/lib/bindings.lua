local _bindings = 'tmux.lib.bindings'
local std = {}
std.count = function ()
  local i = 0
  return function ()
    i = i + 1
    return i
  end
end

local M = {}

local increment = std.count()

local _callbacks = {}

M._cmd = function (index, args, ...)
  local modifiers = {...}
  modifiers.args = args
  return function (...)
    _callbacks[index](modifiers, ...)
  end
end

M._call = function (index, ...)
  _callbacks[index](M, ...)
end

M.cmd = function (name, command)
  assert(command[1], 'command \'' .. name ..'\' definition is required')
  assert(
    type(command[1]) == 'function',
    'command \'' .. name .. '\' expect function as first argument'
  )
  local index = increment()
  _callbacks[index] = command[1]
  local definition = { 'command!' }
  local command_args = { index, '<q-args>' }
  for k, v in pairs(command) do
    if type(k) == 'string' and type(v) == 'boolean' and v then
      table.insert(definition, '-' .. k)
      local escape_arg = ({
        bang = '\'<bang>\'',
        count = '\'<count>\''
      })[k]
      if escape_arg then
        table.insert(command_args, escape_arg)
      end
    elseif type(k) == 'number' and type(v) == 'string' and v:match('^%-') then
      table.insert(definition, v)
    end
  end
  table.insert(definition, name)

  local expression = {
    'lua require(\'' .. _bindings ..'\')',
    '_cmd('.. table.concat(command_args, ',') .. ')(<f-args>)'
  }

  table.insert(definition, table.concat(expression, '.'))

  vim.api.nvim_command(table.concat(definition, ' '))
end

local build_lua_map_ops = function (tbl)
  local sep = ' '
  if tbl.import then
    sep = '.'
  end

  local ops = table.concat(tbl, sep)

  if tbl.import then
    return '<cmd>lua require(\'' .. tbl.import .. '\').' .. ops .. '<cr>'
  else
    return '<cmd>lua ' .. ops .. '<cr>'
  end
end

local map = function (mapper)
  local defaultOptions = { noremap = true, silent = true }

  local keymap = function (modes)
    return function (key, _ops, _options)
      local ops = _ops or ''
      local options = vim.tbl_extend(
        'force',
        defaultOptions,
        _options or {}
      )

      if type(ops) == 'function' then
        local index = increment()
        _callbacks[index] = ops
        ops = {
          import = _bindings,
          '_call(' .. index .. ')'
        }
      end

      if type(ops) == 'table' then
        ops = build_lua_map_ops(ops)
      end

      if not modes then
        mapper('', key, ops, options)
        return
      end

      for _, mode in ipairs(modes) do
        mapper(mode, key, ops, options)
      end
    end
  end

  return {
    mode = keymap,
    all = keymap (),
    normal = keymap {'n'},
    command = keymap {'c'},
    visual = keymap {'v'},
    insert = keymap {'i'},
    replace = keymap {'r'},
    operator = keymap {'o'},
    terminal = keymap {'t'},
    ni = keymap {'n', 'i'},
    nv = keymap {'n', 'v'}
  }
end

local buffer_set_keymap = function (mode, lhs, rhs, opts)
  vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
end

M.map = map(vim.api.nvim_set_keymap)
M.map.buffer = map(buffer_set_keymap)

return M
