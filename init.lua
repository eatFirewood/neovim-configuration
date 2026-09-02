vim.g.mapleader = ' '

-- Install third-party plugins via Neovim's built-in package manager.
vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/stevearc/quicker.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/mfussenegger/nvim-jdtls',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/flash.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
})

-- 各模块的配置脚本都移到 lua/config/ 下，这里只负责加载
require('config.picker').setup()   -- fzf-lua（预览窗口、鼠标修复等）
require('config.quicker')          -- 快速修复列表
require('config.nvimtree')         -- 文件树

require('config.ui')
require('config.keymaps')
require('config.lsp')
require('config.dap').setup()
require('config.java').setup()
