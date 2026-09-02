--- 为 JavaScript、TypeScript 和 React 文件提供补全、类型检查及代码跳转。
return {
  -- 通过已安装的 TypeScript 语言服务与 Neovim 通信。
  cmd = { 'typescript-language-server', '--stdio' },
  -- 同时支持普通脚本和 React 的 JSX/TSX 文件。
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  -- 优先按 TypeScript 配置确定项目目录，并兼容只有 package.json 的项目。
  root_markers = {
    'tsconfig.json',
    'jsconfig.json',
    'package.json',
    '.git',
  },
}
