vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
plugin_home = vim.fn.stdpath('cache') .. '/plugged'
vim_plug = plugin_home .. '/plug.vim'

if vim.fn.filereadable(vim_plug) ~= 0 then
  vim.cmd(
  'silent !curl -fLo ' .. vim_plug .. ' --create-dirs ' .. vim_plug_url
  )
end
vim.opt.runtimepath:append(plugin_home)

vim.fn['plug#begin'](plugin_home)
vim.fn['plug#']('spywhere/tmux.nvim')
vim.fn['plug#end']()

vim.cmd('PlugInstall --sync | q')

require('tmux').start()
