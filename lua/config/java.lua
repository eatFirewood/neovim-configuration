local M = {}

function M.setup()
  require('java').setup({
    spring_boot_tools = { enable = false },
    jdk = {
      auto_install = false,
      path = '/usr/lib/jvm/java-21-openjdk',
    },
  })
  vim.lsp.enable('jdtls')
end

return M
