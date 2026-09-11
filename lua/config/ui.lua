-- 界面显示配置：行号、光标线、诊断显示等
-- 与各功能模块（LSP、Java、调试）分开，方便按需调整

vim.opt.termguicolors = true  -- 开启真彩色（终端支持时），否则颜色降级到 256 色，很灰

-- 补全弹窗：menuone 显示候选（单个匹配也显示）、popup 显示说明窗口；
-- noselect 保证弹窗出现时不预选任何条目（否则输入时第一条会被回车/空格直接插入）
vim.opt.completeopt = 'menuone,noselect,popup'

-- 主题（tokyonight，自带完整的 LSP 语义高亮配色，无需手动指定颜色）
vim.cmd.colorscheme('tokyonight-night')

vim.opt.number = true          -- 显示行号
vim.opt.relativenumber = true  -- 相对行号（便于跳转）
vim.opt.cursorline = true       -- 高亮光标所在行
vim.opt.updatetime = 300        -- 光标停留约 300ms 后触发符号引用高亮
vim.opt.signcolumn = 'yes'      -- 始终显示左侧图标列（断点、诊断等）
vim.opt.wrap = false            -- 不自动折行，超长行水平滚动查看

-- 缩进：Tab 显示为 4 列，自动缩进和连续按 Tab 也使用 4 列。
-- 不开启 expandtab，避免 Makefile 的命令行被转换成空格。
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false

-- 诊断信息显示样式（诊断信息来自 LSP、语法检查等）
-- 官方推荐方式：行内摘要 + 当前行完整展开 + 快捷键手动查看浮动窗口
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',           -- 行内前缀，方便快速识别
    format = function(diagnostic)
      -- 只显示消息前 80 个字符，避免右边截断太严重
      local msg = diagnostic.message:gsub('\n', ' ')
      local max_len = math.max(20, math.floor(vim.o.columns * 0.25))
      if #msg > max_len then
        return string.sub(msg, 1, max_len) .. '…'
      end
      return msg
    end,
  },
  virtual_lines = {
    current_line = true,    -- 当前行在问题行上时，在下方展开完整诊断信息
  },
  severity_sort = true,     -- 按严重程度排序
  signs = true,             -- 左侧图标
  underline = true,         -- 下划线标记
  float = {
    border = 'rounded',
    source = 'if_many',
    max_width = math.max(40, math.floor(vim.o.columns * 0.8)),
  },
})

-- 快捷键：<leader>e 手动查看当前行的完整诊断浮动窗口
vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float({
    focus = false,
    scope = 'line',
    border = 'rounded',
    source = 'if_many',
    max_width = math.max(40, math.floor(vim.o.columns * 0.8)),
  })
end, { desc = '查看当前行完整诊断' })
