-- 文件树配置（nvim-tree）
local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- 保留所有默认映射
  api.map.on_attach.default(bufnr)

  -- ? 显示快捷键帮助（默认是 g?，改成 ? 更直觉）
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
end

require('nvim-tree').setup {
  on_attach = on_attach,
  git = {
    enable = true,
  },
  -- 切换到文件时，文件树自动展开目录并选中当前文件
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = {
      min = 30,
      max = 60,
      padding = 1,
    },
  },
  renderer = {
    group_empty = true,
    indent_markers = {
      enable = true,
    },
  },
}
