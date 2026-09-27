-- 使用当前 PATH 中的 Racket（本机由 asdf 管理）。
return {
  cmd = { 'racket', '--lib', 'racket-langserver' },
  filetypes = { 'racket' },
  root_markers = { 'info.rkt', '.git' },
}
