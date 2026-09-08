-- nvim-dap 初始化：按键映射 + 调试面板（nvim-dap-ui）
-- Java 的调试适配由 nvim-java 管理（已内置 nvim-dap 自动配置）。
local M = {}

function M.setup()
  vim.cmd.packadd('nvim-dap')
  vim.cmd.packadd('nvim-dap-ui')
  vim.cmd.packadd('nvim-web-devicons')

  local ok_dap = pcall(require, 'dap')
  if not ok_dap then
    vim.notify('nvim-dap 未安装，调试不可用', vim.log.levels.WARN)
    return
  end
  local dap = require('dap')

  -- 面板（变量、调用栈、断点、监视），断点命中时自动打开
  local ok_dapui, dapui = pcall(require, 'dapui')
  if ok_dapui then
    dapui.setup {}
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end

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
      program = function()
        return vim.fn.input('可执行文件路径: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }
  dap.configurations.cpp = dap.configurations.c
  dap.configurations.rust = dap.configurations.c

  -- 常用调试按键
  local map = vim.keymap.set
  map('n', '<F5>', function() dap.continue() end, { desc = 'DAP 继续/启动' })
  map('n', '<F10>', function() dap.step_over() end, { desc = 'DAP 单步跳过' })
  map('n', '<F11>', function() dap.step_into() end, { desc = 'DAP 单步进入' })
  map('n', '<F12>', function() dap.step_out() end, { desc = 'DAP 单步跳出' })

  -- 编译项目（调用 :make，需要项目有 Makefile 或 compile_commands.json）
  map('n', '<F7>', function()
    vim.cmd('make')
  end, { desc = '编译项目' })
  map('n', '<F8>', function()
    vim.cmd('w')
    vim.fn.jobstart({ 'make', 'run' }, {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify('make run 完成', vim.log.levels.INFO)
        else
          vim.notify('make run 失败，退出码 ' .. code, vim.log.levels.ERROR)
        end
      end,
    })
  end, { desc = '编译并运行' })

  map('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = '切换断点' })
  map('n', '<leader>dC', function()
    dap.set_breakpoint(vim.fn.input('条件: '))
  end, { desc = '条件断点' })
  map('n', '<leader>dr', function() dap.repl.open() end, { desc = '打开调试命令行' })
  map('n', '<leader>dq', function() dap.close() end, { desc = '结束调试会话' })
  map('n', '<leader>dl', function() dap.run_last() end, { desc = '重新运行上次调试' })
  map('n', '<leader>du', function()
    if ok_dapui then dapui.toggle() end
  end, { desc = '切换调试面板' })
  map('v', '<F5>', function() dap.continue() end, { desc = 'DAP 继续/启动' })
end

return M