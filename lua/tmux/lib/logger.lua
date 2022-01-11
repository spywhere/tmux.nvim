local M = {}

local log = function (severity, trailing)
  return function (message)
    if trailing == nil then
      vim.notify(message, severity)
    else
      vim.notify(message .. trailing, severity)
    end
  end
end

return {
  error = log(vim.log.levels.ERROR, '\n'),
  warn = log(vim.log.levels.WARN, '\n'),
  info = log(vim.log.levels.INFO, '\n'),
  trace = log(vim.log.levels.TRACE, '\n'),
  debug = log(vim.log.levels.DEBUG, '\n'),
  inline = {
    error = log(vim.log.levels.ERROR),
    warn = log(vim.log.levels.WARN),
    info = log(vim.log.levels.INFO),
    trace = log(vim.log.levels.TRACE),
    debug = log(vim.log.levels.DEBUG),
  }
}
