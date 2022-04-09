local fn = require('tmux.lib.fn')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  M.bind(P.prefix, cmds.send_prefix {} )
  -- splits
  M.bind('c', cmds.new_window {} )
  M.bind('n', cmds.next_window {} )
  M.bind('p', cmds.previous_window {} )
  M.bind('%', cmds.split_window { 'v' } )
  M.bind('"', cmds.split_window { 'h' } )
  M.bind('&', cmds.kill_window {} )
  M.bind(',', cmds.command_prompt {
    I = function () return vim.fn.fnamemodify(vim.api.nvim_buf_get_var(0, 'term_title'), ':t') end,
    p = '(rename window) ',
    cmds.rename_window
  })
  M.bind('<space>', cmds.next_layout {} )
  M.bind('<C-o>', cmds.rotate_window {} )
  M.bind('<A-o>', cmds.rotate_window { 'U' } )

  -- move between windows
  for idx = 1, 10 do
    M.bind(
      string.format('%s', idx - 1),
      cmds.select_window { t = idx - 1 }
    )
  end
  M.bind(';', cmds.select_window { 'l' } )

  -- pane management
  M.bind('x', cmds.kill_pane {} )
  M.bind('{', cmds.swap_pane { 'U' } )
  M.bind('}', cmds.swap_pane { 'D' } )

  -- move between panes
  M.bind('<left>', cmds.select_pane { 'L' } )
  M.bind('<down>', cmds.select_pane { 'D' } )
  M.bind('<up>', cmds.select_pane { 'U' } )
  M.bind('<right>', cmds.select_pane { 'R' } )
  M.bind('o', cmds.select_pane { t = ':.+' } )

  -- resize
  M.bind('<A-left>', cmds.resize_pane { L = 8 }, { 'r' })
  M.bind('<A-right>', cmds.resize_pane { R = 8 }, { 'r' })
  M.bind('<A-up>', cmds.resize_pane { U = 4 }, { 'r' })
  M.bind('<A-down>', cmds.resize_pane { D = 4 }, { 'r' })
  M.bind('<C-left>', cmds.resize_pane { L = 1 }, { 'r' })
  M.bind('<C-right>', cmds.resize_pane { R = 1 }, { 'r' })
  M.bind('<C-up>', cmds.resize_pane { U = 1 }, { 'r' })
  M.bind('<C-down>', cmds.resize_pane { D = 1 }, { 'r' })

  -- command prompt
  M.bind(':', cmds.command_prompt {} )

  -- copy mode (back to normal mode)
  M.bind('[', cmds.copy_mode {} )
  M.bind(']', cmds.paste_buffer {} )
  M.bind('q', cmds.cancel {}, { T = 'copy-mode' })
end)
