local M = {}

local function has_fzf()
  return vim.fn.executable('fzf') == 1
end

local function notify_fallback()
  vim.notify('fzf 未安装，已回退到 Neovim 内置 LSP 跳转。安装后可恢复预览：sudo pacman -S fzf', vim.log.levels.WARN)
end

local function project_root()
  return vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
end

function M.setup()
  require('fzf-lua').setup {
    fzf_colors = true,
    winopts = {
      height = 0.85,
      width = 0.80,
      border = 'rounded',
      preview = {
        border = 'rounded',
        layout = 'flex',
        vertical = 'down:45%',
        horizontal = 'right:60%',
        title = true,
        scrollbar = 'float',
        delay = 20,
        winopts = {
          number = true,
          relativenumber = false,
          cursorline = true,
          signcolumn = 'no',
          foldenable = false,
          foldmethod = 'manual',
        },
      },
    },
  }

  -- fzf 终端窗口：鼠标点回结果窗口时自动进入终端模式，
  -- 否则鼠标滚动和键盘输入会被 Neovim 截获，不传给 fzf
  vim.api.nvim_create_autocmd('WinEnter', {
    callback = function()
      if vim.bo.filetype == 'fzf' and vim.fn.mode() ~= 't' then
        vim.cmd('startinsert')
      end
    end,
  })
end

function M.lsp_definitions()
  if has_fzf() then
    require('fzf-lua').lsp_definitions()
    return
  end
  notify_fallback()
  vim.lsp.buf.definition()
end

function M.lsp_references()
  if has_fzf() then
    require('fzf-lua').lsp_references()
    return
  end
  notify_fallback()
  vim.lsp.buf.references()
end

function M.lsp_implementations()
  if has_fzf() then
    require('fzf-lua').lsp_implementations()
    return
  end
  notify_fallback()
  vim.lsp.buf.implementation()
end

function M.files()
  if has_fzf() then
    require('fzf-lua').files({
      file_icons = false,
      cwd = project_root(),
      cwd_prompt = false,
    })
    return
  end
  vim.cmd('find ')
end

function M.live_grep()
  if vim.fn.executable('rg') ~= 1 then
    vim.notify('未找到 rg，无法搜索项目文字。请先安装 ripgrep。', vim.log.levels.ERROR)
    return
  end

  require('fzf-lua').live_grep({ cwd = project_root() })
end

return M
