local fn = require('tmux.lib.fn')

local M = {}

M.next_layout = function ()
  return fn.nested(2, function ()
    vim.cmd('wincmd =')
  end)
end

M.new_window = function ()
  return fn.nested(2, function ()
    vim.cmd('tabnew +terminal')
  end)
end
M.neww = M.new_window

M.rename_window = function (opts)
  opts = opts or {}

  local new_name = ''
  for key, value in pairs(opts) do
    if type(key) == 'number' then
      new_name = value
    end
  end

  return fn.nested(2, function (P)
    if new_name == '' then
      return
    end

    vim.api.nvim_buf_set_var(0, 'term_title', new_name)
  end)
end
M.renamew = M.rename_window

M.rotate_window = function (opts)
  opts = opts or {}

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'U' then
        return fn.nested(2, function ()
          vim.cmd('wincmd R')
        end)
      end
    end
  end

  return fn.nested(2, function ()
    vim.cmd('wincmd r')
  end)
end

M.previous_window = function ()
  return fn.nested(2, function ()
    vim.cmd('tabprevious')
  end)
end
M.prev = M.pervious_window

M.next_window = function ()
  return fn.nested(2, function ()
    vim.cmd('tabnext')
  end)
end
M.next = M.next_window

M.select_window = function (opts)
  opts = opts or {}

  if opts.t then
    return fn.nested(2, function (P)
      local target_window = opts.t + P.index_offset
      if
        0 < target_window and
        target_window <= #vim.api.nvim_list_tabpages()
      then
        vim.cmd('tabnext ' .. target_window)
      end
    end)
  end

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'l' then
        return fn.nested(2, function (P)
          if
            P.last.tabpage ~= nil and
            P.last.tabpage <= #vim.api.nvim_list_tabpages()
          then
            vim.cmd('tabnext ' .. P.last.tabpage)
          end
        end)
      elseif value == 'n' then
        return fn.nested(2, function ()
          vim.cmd('tabnext +1')
        end)
      elseif value == 'p' then
        return fn.nested(2, function ()
          vim.cmd('tabnext -1')
        end)
      end
    end
  end

  return fn.nested(2)
end
M.selectw = M.select_window

M.split_window = function (opts)
  opts = opts or {}
  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'h' then
        return fn.nested(2, function ()
          vim.cmd('split | terminal')
        end)
      elseif value == 'v' then
        return fn.nested(2, function ()
          vim.cmd('vsplit | terminal')
        end)
      end
    end
  end

  return fn.nested(2)
end
M.splitw = M.split_window

M.kill_window = function ()
  return fn.nested(2, function ()
    vim.cmd('tabclose!')
  end)
end
M.killw = M.kill_window

M.confirm_before = function (opts)
  opts = opts or {}

  local cb = nil
  local prompt = opts.p or 'input: '

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if type(value) == 'function' then
        cb = value
      end
    end
  end

  if cb then
    return fn.nested(2, function (P, M)
      local prompt_text = prompt
      if type(prompt_text) == 'function' then
        prompt_text = prompt_text()
      end
      if P.confirm(prompt_text, '&y\n&n', 2) == 1 then
        cb(P)(M)
      end
    end)
  end

  return fn.nested(2)
end
M.confirm = M.confirm_before

M.command_prompt = function (opts)
  opts = opts or {}

  local cb = nil
  local placeholders = {}
  local prompts = { '' }

  if type(opts.I) == 'table' then
    placeholders = opts.I
  elseif opts.I ~= nil then
    placeholders = { opts.I }
  end
  if type(opts.p) == 'table' then
    prompts = opts.p
  elseif opts.p ~= nil then
    prompts = { opts.p }
  end

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if type(value) == 'function' then
        cb = value
      end
    end
  end

  if cb then
    return fn.nested(2, function (P, M)
      local outputs = {}
      for index, prompt in ipairs(prompts) do
        local prompt_text = prompt or ''
        local placeholder_text = placeholders[index] or ''
        if type(prompt_text) == 'function' then
          prompt_text = prompt_text()
        end
        if type(placeholder_text) == 'function' then
          placeholder_text = placeholder_text()
        end
        table.insert(outputs, P.input(prompt_text, placeholder_text))
      end
      cb(outputs)(P)(M)
    end)
  else
    return fn.nested(2, function ()
      vim.cmd('stopinsert')
      vim.api.nvim_feedkeys(':', 'n', true)
    end)
  end
end

M.send_prefix = function ()
  return fn.nested(2, function (P)
    local prefix = vim.api.nvim_replace_termcodes(P.prefix, true, true, true)
    vim.api.nvim_feedkeys(prefix, 't', true)
  end)
end

M.select_pane = function (opts)
  opts = opts or {}

  if opts.t == ':.+' then
    return fn.nested(2, function ()
      vim.cmd('wincmd w')
    end)
  end

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'L' then
        return fn.nested(2, function ()
          vim.cmd('wincmd h')
        end)
      elseif value == 'D' then
        return fn.nested(2, function ()
          vim.cmd('wincmd j')
        end)
      elseif value == 'U' then
        return fn.nested(2, function ()
          vim.cmd('wincmd k')
        end)
      elseif value == 'R' then
        return fn.nested(2, function ()
          vim.cmd('wincmd l')
        end)
      end
    end
  end

  return fn.nested(2)
end
M.selectp = M.select_pane

local function swap_pane(opts)
  opts = opts or {}

  local source = function ()
    if opts.s ~= nil then
      return opts.s
    elseif P.mark.win == nil then
      return vim.fn.winnr()
    else
      return P.mark.win
    end
  end
  local target = function ()
    if opts.t == nil then
      return vim.fn.winnr()
    else
      return opts.t
    end
  end
  local op = nil
  local keep_active = false

  for key, value in pairs(opts) do
    if type(key) == 'number' then
      if value == 'D' or value == 'U' then
        source = function ()
          if opts.t ~= nil then
            vim.cmd(opts.t..'wincmd w')
          end
          return vim.fn.winnr()
        end
        op = function ()
          if value == 'D' then
            vim.cmd('wincmd w')
          else
            vim.cmd('wincmd W')
          end
        end
        target = function ()
          return vim.fn.winnr()
        end
      elseif value == 'd' then
        keep_active = true
      end
    end
  end

  return fn.nested(2, function (P)
    local src = source()
    if op ~= nil then
      op()
    end
    local tgt = target()

    if src ~= tgt then
      vim.cmd(tgt..'wincmd w')
      local target_buffer = vim.fn.bufnr()
      vim.cmd(src..'wincmd w')
      local source_buffer = vim.fn.bufnr()
      vim.cmd('hide buffer '..target_buffer)
      vim.cmd(tgt..'wincmd w')
      vim.cmd('hide buffer '..source_buffer)
      if keep_active then
        vim.cmd(src..'wincmd w')
      end
    end
  end)
end
M.swap_pane = swap_pane
M.swapp = swap_pane

M.resize_pane = function (opts)
  opts = opts or {}

  local sign = '+'
  local value = opts.L or opts.R or opts.x or opts.y or 0
  local expression = {}

  if opts.L or opts.R or opts.x then
    table.insert(expression, 'vertical')
  end
  if opts.L or opts.D then
    sign = '-'
  elseif opts.x or opts.y then
    sign = ''
  end

  table.insert(expression, 'resize')

  if value ~= 0 then
    table.insert(expression, string.format('%s%d', sign, value))
  end

  local command = table.concat(expression, ' ')
  return fn.nested(2, function ()
    vim.cmd(command)
  end)
end
M.resizep = M.resize_pane

M.kill_pane = function (opts)
  return fn.nested(2, function (P)
    local has_tabs = vim.fn.tabpagenr('$') > 1
    local has_windows = false

    local current_buffer = vim.api.nvim_get_current_buf()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
      local buffer = vim.api.nvim_win_get_buf(win)
      local buffer_type = vim.api.nvim_buf_get_option(buffer, 'buftype')
      if current_buffer ~= buffer and buffer_type == 'terminal' then
        has_windows = true
        break
      end
    end

    if has_windows then
      vim.cmd([[exe 'bdelete! '..expand('<abuf>')]])
    elseif has_tabs then
      vim.cmd('quit!')
    elseif P.last.status == -1 then
      -- terminal is killed
      vim.cmd('cquit! 1')
    else
      vim.cmd('cquit! ' .. P.last.status)
    end
  end)
end
M.kill_p = M.kill_pane

M.copy_mode = function ()
  return fn.nested(2, function ()
    vim.cmd('stopinsert')
  end)
end

M.paste_buffer = function ()
  return fn.nested(2, function ()
    vim.cmd('put')
  end)
end

M.cancel = function ()
  return fn.nested(2, function ()
    local mode = vim.fn.mode()
    local vblock = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
    if mode == 'v' or mode == 'V' or mode == vblock then
      vim.api.nvim_feedkeys(mode, 'n', true)
    end
    vim.cmd('startinsert!')
  end)
end

return M
