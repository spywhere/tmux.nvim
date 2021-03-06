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

  function on_cmdline_leave(event)
    if event.cmdtype == ':' then
      start_insert()
    end
  end

  registry.auto('BufEnter', start_insert)
  registry.auto('CmdlineLeave', 'call ' .. registry.call_for_fn(on_cmdline_leave, 'v:event'))
  registry.auto('TermOpen', 'startinsert!')
  registry.auto({ 'InsertEnter', 'TermEnter' }, function ()
    vim.defer_fn(function ()
      if vim.bo.buftype == 'terminal' then
        vim.cmd('nohlsearch')
      end
    end, 10)
  end)

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
    P.last.tabpage = vim.fn.tabpagenr()
  end
  registry.auto('TabLeave', on_tab_leave)
end)
