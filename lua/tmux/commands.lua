local fn = require('tmux.lib.fn')

local M = {}

M.new_window = function ()
  return fn.nested(2, function ()
    vim.cmd('terminal')
  end)
end
M.neww = M.new_window

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

M.kill_window = function ()
  return fn.nested(2, function ()
  end)
end
M.killw = M.kill_window

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

M.select_window = function ()
  return fn.nested(2, function ()
  end)
end
M.selectw = M.select_window

M.split_window = function (opts)
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

M.select_pane = function (opts)
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

return M
