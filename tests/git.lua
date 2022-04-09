-- plugins will be installed to the cache directory
plugin_home = vim.fn.stdpath('cache') .. '/tmux.nvim'
vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
vim_plug = plugin_home .. '/plug.vim'

-- install vim-plug automatically if needed
if vim.fn.filereadable(vim_plug) == 0 then
  vim.cmd(
  'silent !curl -fLo ' .. vim_plug .. ' --create-dirs ' .. vim_plug_url
  )
end
vim.opt.runtimepath:append(plugin_home)

vim.fn['plug#begin'](plugin_home)
vim.fn['plug#']('spywhere/tmux.nvim')
vim.fn['plug#end']()

-- install or update plugins as needed
if vim.fn.isdirectory(plugin_home .. '/tmux.nvim') == 0 then
  vim.cmd('PlugInstall --sync | q')
else
  vim.cmd('PlugUpdate --sync | q')
end

local tmux = require('tmux')
local cmds = require('tmux.commands')

-- some configurations go here

-- may be changing the default prefix key?
--   tmux.prefix('<C-a>')

-- may be binding a new key?
--   tmux.bind('|', cmds.split_window { 'v' } )
--   tmux.bind('-', cmds.split_window { 'h' } )

tmux.start() -- this will start a terminal session
