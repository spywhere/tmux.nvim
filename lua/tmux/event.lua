local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  function start_insert()
    vim.defer_fn(function ()
      P.last.status = -1
      if vim.bo.buftype == 'terminal' then
        vim.cmd('startinsert!')
      end
    end, 10)
  end

  registry.auto({ 'BufEnter', 'CmdlineLeave' }, start_insert)
  registry.auto('TermOpen', 'startinsert!')

  function on_terminal_close(event)
    P.last.status = event.status

    -- if terminal was not killed
    if P.last.status ~= -1 then
      vim.defer_fn(function ()
        cmds.kill_pane({})(P)(M)
      end, 10)
    end
  end

  registry.auto('TermClose', 'call ' .. registry.call_for_fn(on_terminal_close, 'v:event'))

  function on_tab_leave()
    P.last.tabpage = vim.api.nvim_tabpage_get_number(0)
  end
  registry.auto('TabLeave', on_tab_leave)
end)
