vim.lsp.config('*', {
  root_markers = { '.git' },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local picker = require('config.picker')

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map('n', 'gd', picker.lsp_definitions, 'Goto definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Goto declaration')
    map('n', 'gI', picker.lsp_implementations, 'Goto implementation')
    map('n', 'gr', picker.lsp_references, 'Goto references')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>F', function()
      vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
    end, 'Format buffer')

    if client:supports_method('textDocument/completion') then
      -- 内置补全默认只响应语言服务声明的字符；加入可打印字符后可在输入普通字母时自动提示。
      -- 排除 # 字符：clangd 对 # 返回预处理器指令补全（ifndef 等），
      -- 继续输入时会被自动插入，干扰 C 文件输入。#include 路径补全由 < 触发，不受影响。
      local trigger_characters = {}
      for code = 32, 126 do
        if code ~= 35 then  -- 35 = '#'
          table.insert(trigger_characters, string.char(code))
        end
      end
      client.server_capabilities.completionProvider.triggerCharacters = trigger_characters

      vim.lsp.completion.enable(true, client.id, ev.buf, {
        autotrigger = true,
      })
      -- Ctrl-I 与 Tab 使用同一个按键码，不能同时作为补全快捷键；改用 Ctrl-K。
      map('i', '<C-K>', vim.lsp.completion.get, 'Trigger code completion')
    end

    if client:supports_method('textDocument/documentHighlight') then
      -- 光标停留片刻后，高亮当前符号在本文件中的其他引用；移动光标时清除旧高亮。
      local highlight_group = vim.api.nvim_create_augroup(
        'my.lsp.document_highlight.' .. ev.buf,
        { clear = true }
      )
      vim.api.nvim_create_autocmd('CursorHold', {
        buffer = ev.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
        buffer = ev.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client:supports_method('textDocument/documentColor') then
      vim.lsp.document_color.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- 启用已配置的语言服务；ts_ls 负责 JavaScript、TypeScript 和 React 文件。
vim.lsp.enable({
  'lua_ls',
  'pyright',
  'clangd',
  'ts_ls',
})
