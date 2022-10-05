local fn = require('tmux.lib.fn')
local registry = require('tmux.lib.registry')
local str = require('tmux.lib.str')

local is_zoom = function (tid)
  return pcall(function ()
    return vim.api.nvim_tabpage_get_var(tid, 'tmux_pane_zoom')
  end)
end

local functions = function (P)
  local gettid = function (tid)
    return tid or vim.fn.tabpagenr()
  end

  return {
    pid = function ()
      return vim.fn.getpid()
    end,
    session_name = function ()
      -- TODO: use actual session name when possible
      return vim.fn.getpid()
    end,
    host = function ()
      return vim.trim(vim.fn.hostname())
    end,
    pane_id = function (_, tid)
      return vim.fn.tabpagewinnr(gettid(tid))
    end,
    window_flags = function (_, tid)
      tid = gettid(tid)
      local flags = ' '

      if tid == vim.fn.tabpagenr() then
        flags = '*'
      elseif tid == P.last.tabpage then
        flags = '-'
      end

      if tid == P.mark.tabpage then
        flags = string.format('%sM', flags)
      end
      if is_zoom(tid) then
        flags = string.format('%sZ', flags)
      end

      return flags
    end,
    window_id = function (_, tid)
      return gettid(tid)
    end,
    window_index = function (_, tid)
      return gettid(tid) - P.index_offset
    end,
    window_name = function (_, tid)
      tid = gettid(tid)

      local buffers = vim.fn.tabpagebuflist(tid)
      local winid = vim.fn.tabpagewinnr(tid)
      local bufid = buffers[winid]

      local has_title = function (bid)
        return pcall(function ()
          return vim.api.nvim_buf_get_var(bid, 'term_title')
        end)
      end
      if not has_title(bufid) then
        return ''
      end

      return vim.fn.fnamemodify(
        vim.api.nvim_buf_get_var(bufid, 'term_title'),
        ':t'
      )
    end,
    window_zoomed_flag = function (_, tid)
      return is_zoom(gettid(tid)) and 1 or 0, '%d'
    end,
    version = function ()
      local version = vim.version()
      return string.format(
        '%s.%s.%s%s',
        version.major,
        version.minor,
        version.patch,
        version.prerelease and '-dev' or ''
      )
    end,
    t = function (format)
      return os.date(format)
    end
  }
end

return fn.nested(2, function (P)
  local statusline = function ()
    local windows = {}
    for tid = 1, vim.fn.tabpagenr('$') do
      local format = P.status.format

      if tid == vim.fn.tabpagenr() then
        format = P.status.current_format
      end

      local window = str.format(
        format,
        functions(P),
        tid
      )

      table.insert(windows, window)
    end

    return string.format(
      '%s%s%%=%s',
      str.format(P.status.left, functions(P)),
      table.concat(windows, P.status.separator),
      str.format(P.status.right, functions(P))
    )
  end

  if P.status.position == 'top' then
    vim.o.tabline = string.format('%%!%s', registry.call_for_fn(statusline))
  else
    vim.o.statusline = string.format('%%!%s', registry.call_for_fn(statusline))
  end
end)
