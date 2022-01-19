local bindings = require('tmux.lib.bindings')
local registry = require('tmux.lib.registry')

local P = { -- private methods
  last = {
    status = 0,
    tabpage = nil
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

  local is_repeat = false
  local key_table = ''
  local mode = 'terminal'

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'r' then
        is_repeat = true
      elseif value == 'n' then
        key_table = 'root'
      end
    elseif key == 'T' then
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
