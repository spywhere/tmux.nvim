local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')

return fn.nested(2, function (P)
  local tabname = function (tid)
    local buffers = vim.fn.tabpagebuflist(tid)
    local winid = vim.fn.tabpagewinnr(tid)
    local bufid = buffers[winid]

    local has_title = function (bid)
      return pcall(function ()
        return vim.api.nvim_buf_get_var(bid, 'term_title')
      end)
    end
    if not has_title(bufid) then
      return ''
    end

    return vim.fn.fnamemodify(
      vim.api.nvim_buf_get_var(bufid, 'term_title'),
      ':t'
    )
  end

  local tabline = function ()
    -- left
    local line = string.format('[%s]', vim.fn.getpid())

    -- mid
    for i = 1, vim.fn.tabpagenr('$') do
      local name = tabname(i)
      local flags = ' '

      if i == vim.fn.tabpagenr() then
        flags = '*'
      elseif i == P.last.tabpage then
        flags = '-'
      end

      local is_zoom = function (tid)
        return pcall(function ()
          return vim.api.nvim_tabpage_get_var(tid, 'tmux_pane_zoom')
        end)
      end
      if i == P.mark.tabpage then
        flags = string.format('%sM', flags)
      end
      if is_zoom(i) then
        flags = string.format('%sZ', flags)
      end

      line = string.format(
        '%s %s:%s%s',
        line,
        i - P.index_offset,
        name,
        flags
      )
    end

    local hostname = vim.trim(vim.fn.hostname())
    local datetime = os.date('%H:%M %d-%b-%y')

    -- right
    line = string.format('%s%%= "%s" %s', line, hostname, datetime)

    return line
  end

  if P.status.position == 'top' then
    vim.o.tabline = string.format('%%!%s', registry.call_for_fn(tabline))
  else
    vim.o.statusline = string.format('%%!%s', registry.call_for_fn(tabline))
  end
end)
