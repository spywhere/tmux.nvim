local bindings = require('tmux.lib.bindings')
local registry = require('tmux.lib.registry')

local P = { -- private methods
  last = {
    status = -1,
    tabpage = nil
  },
  status = {
    position = vim.fn.has('nvim-0.7') == 0 and 'top' or 'bottom',
    left = '[{session_name}] ',
    right = '"{host}" {t:%H:%M %d-%b-%y}',
    format = '{window_index}:{window_name}{window_flags}',
    current_format = '{window_index}:{window_name}{window_flags}',
    separator = ' '
  },
  mark = {
    tabpage = nil,
    win = nil
  },
  index_offset = 0,
  refresh_interval = 5,
  prefix = '<C-b>',
  ready = {}
}
local M = {} -- public methods

P.redraw = function (wait)
  local delay = 0

  if wait then
    delay = P.refresh_interval * 1000
  end

  vim.defer_fn(function ()
    vim.cmd('mode')
  end, delay)
end

P.input = function (...)
  vim.fn.inputsave()
  local output = vim.fn.input(...)
  vim.fn.inputrestore()
  P.redraw()
  return output
end

P.confirm = function (...)
  vim.fn.inputsave()
  local output = vim.fn.confirm(...)
  vim.fn.inputrestore()
  P.redraw()
  return output
end

P.setup = function ()
  M.on_ready(require('tmux.config')(P))
  M.on_ready(require('tmux.statusbar')(P))
  M.on_ready(require('tmux.bindings')(P))
  M.on_ready(require('tmux.event')(P))
  return M
end

M.bind = function (key, fn, opts)
  opts = opts or {}
  local keymap = key

  local is_repeat = false -- TODO: support repeated
  local key_table = ''
  local mode = 'terminal'

  for index, value in pairs(opts) do
    if type(index) == 'number' then
      if value == 'r' then
        is_repeat = true
      elseif value == 'n' then
        key_table = 'root'
      end
    elseif index == 'T' then
      key_table = value
    end
  end

  if key_table == 'copy-mode' then
    mode = 'nv'
  elseif key_table ~= 'root' then
    keymap = string.format('%s%s', P.prefix, key)
  end

  bindings.map[mode](keymap, fn(P))
end

M.prefix = function (key)
  P.prefix = key
end

M.on_ready = function (callback)
  table.insert(P.ready, callback)
end

M.start = function (opts)
  if vim.fn.has('nvim-0.7.0') == 0 then
    vim.notify(
      'tmux.nvim requires neovim v0.7.0 or later',
      vim.log.levels.ERROR
    )
    return
  end

  opts = opts or {}

  for _, callback in ipairs(P.ready) do
    callback(M)
  end

  if opts.force or vim.v.vim_did_enter == 1 then
    vim.cmd('terminal')
  else
    registry.auto('VimEnter', function () vim.cmd('terminal') end)
  end
end

return P.setup()
