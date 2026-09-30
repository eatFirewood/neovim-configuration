-- nvim-dap 初始化：适配器配置 + 按键映射 + 调试界面（nvim-dap-view）
-- nvim-dap-view：零依赖的调试 UI（侧栏面板 / hover / 行内变量值），不装 nvim-dap-ui
-- Java 的调试适配由 nvim-java 管理（已内置 nvim-dap 自动配置）。
local M = {}

function M.setup()
  vim.cmd.packadd('nvim-dap')
  -- 注意：packadd 用的是仓库目录名（nvim-dap-view），不是 Lua 模块名（dap-view）
  vim.cmd.packadd('nvim-dap-view')
  -- nvim-web-devicons 是文件树（nvim-tree）的图标依赖，与调试无关，保留
  vim.cmd.packadd('nvim-web-devicons')

  local ok_dap = pcall(require, 'dap')
  if not ok_dap then
    vim.notify('nvim-dap 未安装，调试不可用', vim.log.levels.WARN)
    return
  end
  local dap = require('dap')

  -- 调试界面：nvim-dap-view（零依赖，自带侧栏面板 / hover / 行内变量值）
  local ok_dapview, dapview = pcall(require, 'dap-view')
  if ok_dapview then
    dapview.setup({
      -- 会话开始自动打开、结束自动关（默认 false，不设就不会自动弹）
      auto_toggle = 'open',
      -- 行内显示变量值（需要 Neovim 0.12+，本机 0.12.5 满足）
      virtual_text = { enabled = true },
    })
  else
    vim.notify('nvim-dap-view 未加载，调试面板不可用', vim.log.levels.WARN)
  end

  -- 面板之外，nvim-dap 还自带这些查看方式（无需插件）：
  --   <Leader>dh 悬停看值（可视模式选中表达式也用它）、<Leader>dp 预览
  --   <Leader>df 浮动调用栈、<Leader>ds 浮动 scopes、<Leader>dr REPL

  -- 断点符号提示（命中/活动断点）
  vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = 'Debug', numhl = '' })

  -- 通用调试适配器（lldb-dap，支持 C/C++/Rust 等）
  -- 系统已安装 lldb-dap（LLVM 22），通过 stdio 通信，不需要额外配置
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-dap',
    name = 'lldb',
    -- lldb-dap 第一次启动可能超过 nvim-dap 默认的 4 秒等待时间。
    options = { initialize_timeout_sec = 10 },
  }

  dap.configurations.c = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      -- nvim-dap 内置占位符：弹选择器挑可执行文件（vm.ui.select，本机由 fzf-lua 实现），
      -- 递归列出可执行文件；比 vim.fn.input 手输更稳，也不会把目录当程序传进去。
      program = '${command:pickFile}',
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }
  dap.configurations.cpp = dap.configurations.c
  dap.configurations.rust = dap.configurations.c

  -- 键位：官方示例见 `:help dap-mappings`，这里按它原样保留（不再自创 F7/F8 之类）
  local map = vim.keymap.set
  map('n', '<F5>', function() dap.continue() end, { desc = 'DAP 继续/启动' })
  map('n', '<F10>', function() dap.step_over() end, { desc = 'DAP 单步跳过' })
  map('n', '<F11>', function() dap.step_into() end, { desc = 'DAP 单步进入' })
  map('n', '<F12>', function() dap.step_out() end, { desc = 'DAP 单步跳出' })
  map('n', '<Leader>b', function() dap.toggle_breakpoint() end, { desc = 'DAP 切换断点' })
  -- 官方 <Leader>B 就是无参 set_breakpoint()：替换式设置、不弹条件输入框。
  -- 想要「输入条件」就把下一行换成 dap.set_breakpoint(vim.fn.input('Condition: '))
  map('n', '<Leader>B', function() dap.set_breakpoint() end, { desc = 'DAP 设置断点' })
  map('n', '<Leader>lp', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
  end, { desc = 'DAP 日志断点' })
  map('n', '<Leader>dr', function() dap.repl.open() end, { desc = 'DAP 打开 REPL' })
  map('n', '<Leader>dl', function() dap.run_last() end, { desc = 'DAP 重跑上次调试' })
  map({ 'n', 'v' }, '<Leader>dh', function()
    require('dap.ui.widgets').hover()
  end, { desc = 'DAP 悬停看值' })
  map({ 'n', 'v' }, '<Leader>dp', function()
    require('dap.ui.widgets').preview()
  end, { desc = 'DAP 预览看值' })
  map('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
  end, { desc = 'DAP 浮动调用栈' })
  map('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
  end, { desc = 'DAP 浮动 scopes' })

  -- 面板开关（nvim-dap-view 默认不自动开，靠上面的 auto_toggle；这个键是手动开关）
  map('n', '<Leader>du', function()
    if ok_dapview then dapview.toggle() end
  end, { desc = 'DAP 调试面板开关' })
end

return M