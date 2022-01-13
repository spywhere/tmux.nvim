local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')

return fn.nested(2, function (P)
  -- no status line
  vim.o.laststatus = 0
  vim.o.showtabline = 2

  vim.o.statusline = '─'
  vim.o.fillchars = 'stl:─,stlnc:─,eob: '

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
    local line = string.format('[%s]', vim.fn.getpid())

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

    return line
  end
  vim.o.tabline = string.format('%%!%s', registry.call_for_fn(tabline))

  -- no command line
  --   currently not possible
  --   ref: https://github.com/neovim/neovim/issues/1004
  -- vim.o.cmdheight = 0
  -- workaround for hiding command line
  vim.opt.lines:append(1)

  -- remove command line clutter
  vim.o.showmode = false
  vim.o.showcmd = false
  vim.o.ruler = false

  vim.o.splitright = true
  vim.o.splitbelow = true

  vim.o.mouse = 'a'
end)
