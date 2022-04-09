local fn = require('tmux.lib.fn')

return fn.nested(2, function (P)
  if P.status.position == 'top' then
    -- no status line
    vim.o.laststatus = 0
    -- always show tab line
    vim.o.showtabline = 2

    vim.o.fillchars = 'stl:─,stlnc:─'
    vim.o.statusline = '─'
  else
    -- always show status line
    if vim.fn.has('nvim-0.7') == 1 then
      vim.o.laststatus = 3
    else
      vim.o.laststatus = 2
    end
    -- no tab line
    vim.o.showtabline = 0

    vim.o.fillchars = 'stl: ,stlnc: '
  end

  vim.opt.fillchars:append('eob: ')

  -- no command line
  --   currently not possible
  --   ref: https://github.com/neovim/neovim/issues/1004
  -- vim.o.cmdheight = 0
  -- workaround for hiding command line
  -- vim.opt.lines:append(1)

  -- remove command line clutter
  vim.o.showmode = false
  vim.o.showcmd = false
  vim.o.ruler = false

  vim.o.splitright = true
  vim.o.splitbelow = true

  vim.o.mouse = 'a'
end)
