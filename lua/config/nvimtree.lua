-- 文件树配置（nvim-tree）
local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- 保留所有默认映射
  api.map.on_attach.default(bufnr)

  -- ? 显示快捷键帮助（默认是 g?，这样更直观）
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
end

require('nvim-tree').setup {
  on_attach = on_attach,
  git = {
    enable = false,
  },
  -- 切换到文件时，文件树自动展开目录并选中当前文件。
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = {
      min = 30,       -- 最窄宽度
      max = 60,       -- 最宽上限，防止挤掉编辑区
      padding = 1,    -- 右侧留白
    },
  },
  renderer = {
    -- 只含单层子文件夹的目录合并显示，减少深层嵌套视觉
    -- 例如 src/main/java/com/example/ 合并成一行
    group_empty = true,
    -- 缩进引导线（│ └ 等），层级关系更清晰
    indent_markers = {
      enable = true,
    },
  },
}
