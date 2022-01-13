local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')

return fn.nested(2, function ()
  -- no status line
  vim.o.laststatus = 0

  vim.o.statusline = '─'
  vim.o.fillchars = 'stl:─,stlnc:─,eob: '

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
