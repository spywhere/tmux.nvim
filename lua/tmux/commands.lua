local fn = require('tmux.lib.fn')

local M = {}

M.new_window = function ()
  return fn.nested(2, function ()
    vim.cmd('terminal')
  end)
end
M.neww = M.new_window

M.previous_window = function ()
  return fn.nested(2, function ()
  end)
end
M.prev = M.pervious_window

M.next_window = function ()
  return fn.nested(2, function ()
  end)
end
M.next = M.next_window

M.select_window = function (opts)
  return fn.nested(2)
end
M.selectw = M.select_window

M.split_window = function (opts)
  opts = opts or {}
  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'h' then
        return fn.nested(2, function ()
          vim.cmd('split | terminal')
        end)
      elseif value == 'v' then
        return fn.nested(2, function ()
          vim.cmd('vsplit | terminal')
        end)
      end
    end
  end

  return fn.nested(2)
end
M.splitw = M.split_window

M.kill_window = function ()
  return fn.nested(2, function ()
  end)
end
M.killw = M.kill_window

M.command_prompt = function ()
  return fn.nested(2, function ()
    vim.cmd('stopinsert')
    vim.api.nvim_feedkeys(':', 'n', true)
  end)
end

M.send_prefix = function ()
  return fn.nested(2, function (P)
    vim.api.nvim_feedkeys(P.prefix, 't', true)
  end)
end

M.select_pane = function (opts)
  opts = opts or {}
  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'L' then
        return fn.nested(2, function ()
          vim.cmd('wincmd h')
        end)
      elseif value == 'D' then
        return fn.nested(2, function ()
          vim.cmd('wincmd j')
        end)
      elseif value == 'U' then
        return fn.nested(2, function ()
          vim.cmd('wincmd k')
        end)
      elseif value == 'R' then
        return fn.nested(2, function ()
          vim.cmd('wincmd l')
        end)
      end
    end
  end

  return fn.nested(2)
end
M.selectp = M.select_pane

M.resize_pane = function (opts)
  opts = opts or {}

  local sign = '+'
  local value = opts.L or opts.R or opts.x or opts.y or 0
  local expression = {}

  if opts.L or opts.R or opts.x then
    table.insert(expression, 'vertical')
  end
  if opts.L or opts.D then
    sign = '-'
  elseif opts.x or opts.y then
    sign = ''
  end

  table.insert(expression, 'resize')

  if value ~= 0 then
    table.insert(expression, string.format('%s%d', sign, value))
  end

  local command = table.concat(expression, ' ')
  return fn.nested(2, function ()
    vim.cmd(command)
  end)
end
M.resizep = M.resize_pane

M.copy_mode = function ()
  return fn.nested(2, function ()
    vim.cmd('stopinsert')
  end)
end

M.paste_buffer = function ()
  return fn.nested(2, function ()
    vim.cmd('put')
  end)
end

M.cancel = function ()
  return fn.nested(2, function ()
    local mode = vim.fn.mode()
    local vblock = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
    if mode == 'v' or mode == 'V' or mode == vblock then
      vim.api.nvim_feedkeys(mode, 'n', true)
    end
    vim.cmd('startinsert!')
  end)
end

return M
