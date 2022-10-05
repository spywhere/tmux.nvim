local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  local function start_insert()
    vim.defer_fn(function ()
      P.last.status = -1
      if vim.bo.buftype == 'terminal' then
        vim.cmd('startinsert!')
      end
    end, 10)
  end

  local function on_cmdline_leave()
    if vim.v.event.cmdtype == ':' then
      start_insert()
    end
  end

  registry.auto('BufEnter', start_insert)
  registry.auto('CmdlineLeave', on_cmdline_leave)
  registry.auto('TermOpen', 'startinsert!')
  registry.auto({ 'InsertEnter', 'TermEnter' }, function ()
    vim.defer_fn(function ()
      if vim.bo.buftype == 'terminal' then
        vim.cmd('nohlsearch')
      end
    end, 10)
  end)

  local function on_terminal_close()
    P.last.status = vim.v.event.status

    -- if terminal was not killed
    if P.last.status ~= -1 then
      vim.defer_fn(function ()
        cmds.kill_pane({})(P)(M)
      end, 10)
    end
  end

  registry.auto('TermClose', on_terminal_close)

  local function on_tab_leave()
    P.last.tabpage = vim.fn.tabpagenr()
  end
  registry.auto('TabLeave', on_tab_leave)
end)
