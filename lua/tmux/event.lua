local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')

return fn.nested(2, function (P, M)
  function start_insert()
    vim.defer_fn(function ()
      if vim.bo.buftype == 'terminal' then
        vim.cmd('startinsert!')
      end
    end, 10)
  end

  registry.auto({ 'BufEnter', 'CmdlineLeave' }, start_insert)
  registry.auto('TermOpen', 'startinsert!')

  function on_window_close()
    vim.defer_fn(function ()
      local wins = vim.api.nvim_list_wins()

      local count = 0
      for _, win in ipairs(wins) do
        local buffer = vim.api.nvim_win_get_buf(win)
        local buffer_type = vim.api.nvim_buf_get_option(buffer, 'buftype')
        if buffer_type == 'terminal' then
          count = count + 1
        end
      end

      if count == 0 then
        vim.cmd('cquit! ' .. P.last_status)
      end
    end, 10)
  end

  function on_terminal_close(event)
    P.last_status = event.status

    on_window_close()
  end

  registry.auto('TermClose', 'call ' .. registry.call_for_fn(on_terminal_close, 'v:event'))
  registry.auto('BufLeave', on_window_close)
end)
