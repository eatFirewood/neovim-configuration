return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--offset-encoding=utf-8',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = {
    'compile_commands.json',
    '.clangd',
    '.git',
  },
}
