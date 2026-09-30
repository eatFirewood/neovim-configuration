vim.g.mapleader = ' '

-- Install third-party plugins via Neovim's built-in package manager.
vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/stevearc/quicker.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/mfussenegger/nvim-dap',
  -- 调试界面：零依赖（不像 nvim-dap-ui 还需要 nvim-nio）
  'https://github.com/igorlfs/nvim-dap-view',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/flash.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/JavaHello/spring-boot.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-java/nvim-java',
})

-- 各模块的配置脚本都移到 lua/config/ 下，这里只负责加载
require('config.picker').setup()   -- fzf-lua（预览窗口、鼠标修复等）
require('config.quicker')          -- 快速修复列表
require('config.nvimtree')         -- 文件树

require('config.ui')
require('config.keymaps')
require('config.lsp')
require('config.dap').setup()

-- Java（官方示例）
require('java').setup({
  spring_boot_tools = { enable = false },
})

-- 改完 pom.xml 后 jdtls 自动重新导入，需要补两项（nvim-java 只负责启动参数）：
-- 1) Neovim 在 Linux 上把 workspace/didChangeWatchedFiles.dynamicRegistration 硬编码为 false
--    （runtime/lua/vim/lsp/protocol.lua 里 `sysname == 'Darwin' or sysname == 'Windows_NT'`），
--    导致 jdtls 注册的 `**/pom.xml` 监听被整段丢弃，jdtls 永远收不到 pom 变更通知。
--    这里手动覆盖成 true，Neovim 才会真正去注册 watcher 并发 didChangeWatchedFiles。
-- 2) jdtls 默认 java.configuration.updateBuildConfiguration = "interactive"，会通过
--    language/actionableNotification 让客户端弹「是否同步 classpath」按钮，
--    Neovim 没有该 method 的 handler（nvim-java 也没实现），弹不出来。
--    设为 automatic 后 jdtls 直接重新导入，不再询问客户端。
-- 注：多模块工程还要装 inotify-tools（提供 inotifywait），否则 Neovim 的
--    watchdirs 回退只监听根目录一层，子模块的 pom.xml 收不到事件。
vim.lsp.config('jdtls', {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
    },
  },
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = 'automatic',
      },
    },
  },
})

vim.lsp.enable('jdtls')
