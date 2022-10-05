local M = {}

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
        options.callback = ops
        ops = ''
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
