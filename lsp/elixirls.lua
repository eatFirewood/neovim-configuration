-- ElixirLS 启动时会按当前 Elixir/OTP 版本安装并编译自身。
return {
  cmd = { vim.fn.expand('~/.local/share/elixir-ls/language_server.sh') },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  root_markers = { 'mix.exs', '.git' },
  settings = {
    elixirLS = {
      -- 先提供补全、跳转和编译诊断，避免初次体验时长时间构建 Dialyzer 缓存。
      dialyzerEnabled = false,
    },
  },
}
