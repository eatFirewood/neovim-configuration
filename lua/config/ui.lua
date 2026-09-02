-- 界面显示配置：行号、光标线、诊断显示等
-- 与各功能模块（LSP、Java、调试）分开，方便按需调整

vim.opt.termguicolors = true  -- 开启真彩色（终端支持时），否则颜色降级到 256 色，很灰

-- 主题（tokyonight，自带完整的 LSP 语义高亮配色，无需手动指定颜色）
vim.cmd.colorscheme('tokyonight-night')

vim.opt.number = true          -- 显示行号
vim.opt.relativenumber = true  -- 相对行号（便于跳转）
vim.opt.cursorline = true       -- 高亮光标所在行
vim.opt.signcolumn = 'yes'      -- 始终显示左侧图标列（断点、诊断等）
vim.opt.wrap = false            -- 不自动折行，超长行水平滚动查看

-- 诊断信息显示样式（诊断信息来自 LSP、语法检查等）
vim.diagnostic.config({
  virtual_text = true,      -- 行内显示诊断文字
  severity_sort = true,     -- 按严重程度排序
  signs = true,             -- 左侧图标
  underline = true,         -- 下划线标记
  float = { border = 'rounded' },  -- 浮动窗口圆角边框
})