-- 全局键位：文件树、断点、代码跳转提示（which-key）
-- 各功能专属键位留在对应模块：LSP 跳转键在 config/lsp.lua，Java 键在 config/java.lua
require('which-key').setup {
  triggers = {
    { '<leader>', mode = { 'n', 'v' } },
    { 'g', mode = { 'n', 'v' } },
  },
  presets = {
    g = false,
  },
  spec = {
    { '<leader>e', desc = 'Toggle file tree' },
    { '<leader>b', desc = 'Toggle breakpoint' },
    { '<leader>lg', desc = 'Open lazygit' },
    { 'g', group = 'Code navigation' },
    { 'gd', desc = 'Goto definition' },
    { 'gD', desc = 'Goto declaration' },
    { 'gI', desc = 'Goto implementation' },
    { 'gr', desc = 'Goto references' },
  },
}

local map = vim.keymap.set

map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', {
  desc = 'Toggle file tree',
})

map('n', '<leader>b', function()
  require('dap').toggle_breakpoint()
end, {
  desc = 'Toggle breakpoint',
})

-- lazygit：浮动窗口打开 Git 管理界面（提交、分支、diff 等）
map('n', '<leader>lg', '<cmd>LazyGit<CR>', {
  desc = 'Open lazygit',
})

-- 快捷跳转（flash.nvim）：输入字符后，所有候选位置标出标签，按标签键直接跳转
require('flash').setup {
  labels = 'asdfghjklqwertyuiopzxcvbnm',
}

map({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash 快捷跳转' })
map({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash 语法节点跳转' })
