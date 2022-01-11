local fn = require('tmux.lib.fn')
local cmds = require('tmux.commands')

return fn.nested(2, function (P, M)
  M.bind('c', cmds.new_window())
  M.bind('-', cmds.split_window({ 'h' }))
  M.bind('<bar>', cmds.split_window({ 'v' }))
  M.bind(':', cmds.command_prompt())

  M.bind('<C-h>', cmds.select_pane({ 'L' }), { 'n' })
  M.bind('<C-j>', cmds.select_pane({ 'D' }), { 'n' })
  M.bind('<C-k>', cmds.select_pane({ 'U' }), { 'n' })
  M.bind('<C-l>', cmds.select_pane({ 'R' }), { 'n' })
end)
