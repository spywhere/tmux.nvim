local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')

return fn.nested(2, function (P)
  local tabname = function (tid)
    local buffers = vim.fn.tabpagebuflist(tid)
    local winid = vim.fn.tabpagewinnr(tid)
    local bufid = buffers[winid]

    if vim.fn.exists('b:term_title') == 0 then
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
      local flag = ' '

      if i == vim.fn.tabpagenr() then
        flag = '*'
      elseif i == P.last.tabpage then
        flag = '-'
      end

      line = string.format(
        '%s %s:%s%s',
        line,
        i - P.index_offset,
        name,
        flag
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
