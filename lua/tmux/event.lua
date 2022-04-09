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
      local has_windows = vim.fn.tabpagenr('$') > 1
      if not has_windows then
        local current_buffer = vim.api.nvim_get_current_buf()
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          local buffer = vim.api.nvim_win_get_buf(win)
          local buffer_type = vim.api.nvim_buf_get_option(buffer, 'buftype')
          if current_buffer ~= buffer and buffer_type == 'terminal' then
            has_windows = true
            break
          end
        end
      end

      if has_windows then
        vim.cmd([[exe 'bdelete! '..expand('<abuf>')]])
      else
        vim.cmd('cquit! ' .. P.last.status)
      end
    end, 10)
  end

  function on_terminal_close(event)
    P.last.status = event.status

    on_window_close()
  end

  registry.auto('TermClose', 'call ' .. registry.call_for_fn(on_terminal_close, 'v:event'))

  function on_tab_leave()
    P.last.tabpage = vim.api.nvim_tabpage_get_number(0)
  end
  registry.auto('TabLeave', on_tab_leave)
end)
