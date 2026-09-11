local M = {}

function M.setup()
  require('java').setup()
  vim.lsp.enable('jdtls')
end

return M
