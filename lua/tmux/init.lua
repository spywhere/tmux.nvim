local bindings = require('tmux.lib.bindings')

local P = { -- private methods
  last_status = 0,
  prefix = '<C-b>'
}
local M = {} -- public methods

local _ready = {}

P.setup = function ()
  M.on_ready(require('tmux.config')(P))
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
  table.insert(_ready, callback)
end

M.start = function ()
  for _, callback in ipairs(_ready) do
    callback(M)
  end

  vim.cmd('terminal')
end

return P.setup()
