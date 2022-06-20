-- plugins will be installed to the cache directory
local plugin_home = vim.fn.stdpath('cache') .. '/tmux.nvim'
local config_home = vim.fn.stdpath('config')
local plug_path = config_home .. '/lua/plug.lua'
local plug_url = 'https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua'

if vim.fn.filereadable(vim.fn.expand(plug_path)) == 0 then
  if vim.fn.executable('curl') == 0 then
    -- curl not installed, skip the config
    print('cannot install plug.nvim, curl is not installed')
    return
  end
  vim.cmd(
    'silent !curl -fLo ' .. plug_path .. ' --create-dirs ' .. plug_url
  )
end

vim.opt.runtimepath:append(plugin_home)

local plug = require('plug')

-- install or update plugins as needed
local install_or_update = function ()
  local has_plugin = function ()
    return vim.fn.isdirectory(plugin_home .. '/tmux.nvim') == 1
  end
  local install = function ()
    vim.cmd('PlugInstall --sync | q')
  end
  local update = function ()
    vim.cmd('PlugUpdate --sync | q')
  end

  return function (hook)
    hook('post_setup', function ()
      if has_plugin() then
        update()
      else
        install()
      end
    end)
  end
end

plug.setup {
  plugin_dir = plugin_home,
  extensions = {
    -- also perform automatic installation for vim-plug and missing plugins
    plug.extension.auto_install {
      -- do not automatically install plugins, we will do that ourselves
      missing = false
    },
    install_or_update {},
    plug.extension.config {}
  }
}

{
  'spywhere/tmux.nvim',
  config = function ()
    local tmux = require('tmux')
    local cmds = require('tmux.commands')

    -- some configurations go here

    -- may be changing the default prefix key?
    --   tmux.prefix('<C-a>')

    -- may be binding a new key?
    --   tmux.bind('|', cmds.split_window { 'v' } )
    --   tmux.bind('-', cmds.split_window { 'h' } )

    tmux.start() -- this will start a terminal session
  end
}

''
