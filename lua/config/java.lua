local M = {}

function M.setup()
  require('java').setup({
    spring_boot_tools = { enable = false },
  })
  vim.lsp.enable('jdtls')
end

return M
