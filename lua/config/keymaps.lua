-- 全局键位：文件树、断点、代码跳转提示（which-key）
-- 各功能专属键位留在对应模块：LSP 跳转键在 config/lsp.lua，Java 键位由 nvim-java 提供
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
    { '<leader>f', desc = 'Search files' },
    { '<leader>/', desc = 'Search project text' },
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

-- 搜索当前项目中的文件
map('n', '<leader>f', function()
  require('config.picker').files()
end, {
  desc = 'Search files',
})

-- 在当前项目中搜索文字（依赖 rg，由 fzf-lua 提供交互式结果和预览）
map('n', '<leader>/', function()
  require('config.picker').live_grep()
end, {
  desc = 'Search project text',
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
