local fn = require('tmux.lib.fn')

return fn.nested(2, function (P)
  -- bottom status only support in neovim 0.7 (using unified status line)
  if P.status.position == 'bottom' and vim.fn.has('nvim-0.7') == 1 then
    -- always show status line
    vim.o.laststatus = 3
    -- no tab line
    vim.o.showtabline = 0

    vim.o.fillchars = 'stl: ,stlnc: '
  else
    -- no status line
    vim.o.laststatus = 0
    -- always show tab line
    vim.o.showtabline = 2

    vim.o.fillchars = 'stl:─,stlnc:─'
    vim.o.statusline = '─'
  end

  vim.opt.fillchars:append('eob: ')

  vim.o.termguicolors = true

  if vim.fn.has('nvim-0.8') == 1 then
    vim.o.cmdheight = 0
  end

  -- remove command line clutter
  vim.o.showmode = false
  vim.o.showcmd = false
  vim.o.ruler = false

  vim.o.splitright = true
  vim.o.splitbelow = true

  vim.o.mouse = 'a'
end)
