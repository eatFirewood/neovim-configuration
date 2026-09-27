-- TypeScript 7+ 自带标准 LSP，同时支持 JavaScript 和 TypeScript。
return {
  -- 使用 PATH 中的新版 tsc，不再通过 typescript-language-server/tsserver。
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tsconfig.json',
    'jsconfig.json',
    'package.json',
    '.git',
  },
}
