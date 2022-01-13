local fn = require('tmux.lib.fn')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  -- splits
  M.bind('c', cmds.new_window {} )
  M.bind('%', cmds.split_window { 'v' } )
  M.bind('"', cmds.split_window { 'h' } )

  -- move between panes
  M.bind('<left>', cmds.select_pane { 'L' } )
  M.bind('<down>', cmds.select_pane { 'D' } )
  M.bind('<up>', cmds.select_pane { 'U' } )
  M.bind('<right>', cmds.select_pane { 'R' } )

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
