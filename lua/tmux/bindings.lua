local fn = require('tmux.lib.fn')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  -- splits
  M.bind('c', cmds.new_window())
  M.bind('-', cmds.split_window({ 'h' }))
  M.bind('<bar>', cmds.split_window({ 'v' }))

  -- command prompt
  M.bind(':', cmds.command_prompt())

  -- move between panes
  M.bind('<C-h>', cmds.select_pane({ 'L' }), { 'n' })
  M.bind('<C-j>', cmds.select_pane({ 'D' }), { 'n' })
  M.bind('<C-k>', cmds.select_pane({ 'U' }), { 'n' })
  M.bind('<C-l>', cmds.select_pane({ 'R' }), { 'n' })

  -- resize
  M.bind('<S-Left>', cmds.resize_pane({ L = 8 }), { 'r' })
  M.bind('<S-Right>', cmds.resize_pane({ R = 8 }), { 'r' })
  M.bind('<S-Up>', cmds.resize_pane({ U = 4 }), { 'r' })
  M.bind('<S-Down>', cmds.resize_pane({ D = 4 }), { 'r' })
  M.bind('<Left>', cmds.resize_pane({ L = 1 }), { 'r' })
  M.bind('<Right>', cmds.resize_pane({ R = 1 }), { 'r' })
  M.bind('<Up>', cmds.resize_pane({ U = 1 }), { 'r' })
  M.bind('<Down>', cmds.resize_pane({ D = 1 }), { 'r' })

  -- copy mode (back to normal mode)
  M.bind('[', cmds.copy_mode())
  M.bind('q', cmds.cancel(), { T = 'copy-mode' })
end)
