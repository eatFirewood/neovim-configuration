local M = {}

M.build_markers = {
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
  'mvnw',
  'gradlew',
}

M.root_markers = vim.list_extend(vim.deepcopy(M.build_markers), { '.git' })

local function find_java_home()
  local java = vim.fn.exepath('java')
  if java == '' then
    return nil
  end
  return vim.fs.dirname(vim.fs.dirname(java))
end

local function find_lombok_jar()
  local jar_pattern = vim.fs.joinpath(vim.fn.expand('~'), '.m2', 'repository', 'org', 'projectlombok', 'lombok', '*', 'lombok-*.jar')
  local jars = vim.split(vim.fn.glob(jar_pattern), '\n', { trimempty = true })
  local latest_jar
  local latest_mtime = -1

  for _, jar in ipairs(jars) do
    if not jar:match('%-sources%.jar$') and not jar:match('%-javadoc%.jar$') then
      local stat = vim.uv.fs_stat(jar)
      local mtime = stat and stat.mtime and stat.mtime.sec or -1
      if mtime > latest_mtime then
        latest_jar = jar
        latest_mtime = mtime
      end
    end
  end

  return latest_jar
end

local function has_build_marker(dir)
  for _, marker in ipairs(M.build_markers) do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
      return true
    end
  end
  return false
end

local function get_root_dir(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == '' then
    return nil
  end

  local nearest_build_root = vim.fs.root(bufname, M.build_markers)
  local git_root = vim.fs.root(bufname, { '.git' })

  if git_root and has_build_marker(git_root) then
    return git_root
  end

  return nearest_build_root or git_root
end

local function get_workspace_dir(root_dir)
  local project_name = vim.fs.basename(root_dir)
  local project_hash = vim.fn.sha256(root_dir):sub(1, 12)
  return vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls', 'workspace', project_name .. '-' .. project_hash)
end

local function stop_clients_for_root(root_dir)
  for _, client in ipairs(vim.lsp.get_clients({ name = 'jdtls' })) do
    if client.config and client.config.root_dir == root_dir then
      client:stop(true)
    end
  end
end

local function get_runtimes()
  local java_home = find_java_home()
  if not java_home then
    return {}
  end

  return {
    {
      name = 'JavaSE-21',
      path = java_home,
      default = true,
    },
  }
end

function M.settings()
  return {
    java = {
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      configuration = {
        detectJdksAtStart = true,
        updateBuildConfiguration = 'interactive',
        runtimes = get_runtimes(),
      },
      references = {
        includeAccessors = true,
        includeDeclarations = true,
        includeDecompiledSources = true,
      },
      implementationCodeLens = 'all',
      referencesCodeLens = {
        enabled = true,
      },
      signatureHelp = {
        enabled = true,
      },
      symbols = {
        includeGeneratedCode = true,
        includeSourceMethodDeclarations = true,
      },
    },
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
  }
end

-- 调试 bundle：java-debug（断点调试）+ vscode-java-test（测试调试）
-- 按 nvim-jdtls 官方文档：从 Open VSX 扩展包解压出的 jar 放在
-- ~/.local/share/java-dap/jars/{java-debug,java-test}/ 下
function M.bundles()
  local java_debug_jar = vim.fn.glob(vim.fs.joinpath(
    vim.fn.expand('~'), '.local', 'share', 'java-dap', 'jars', 'java-debug',
    'com.microsoft.java.debug.plugin-*.jar'), true)

  local bundles = {}
  if java_debug_jar ~= '' then
    table.insert(bundles, java_debug_jar)
  end

  -- 测试调试用 jar：官方文档明确排除这两个（它们是运行期依赖，不是 jdtls 插件）
  local excluded = {
    'com.microsoft.java.test.runner-jar-with-dependencies.jar',
    'jacocoagent.jar',
  }
  local java_test_pattern = vim.fs.joinpath(
    vim.fn.expand('~'), '.local', 'share', 'java-dap', 'jars', 'java-test', '*.jar')
  for _, jar in ipairs(vim.split(vim.fn.glob(java_test_pattern), '\n')) do
    if jar ~= '' and not vim.tbl_contains(excluded, vim.fn.fnamemodify(jar, ':t')) then
      table.insert(bundles, jar)
    end
  end

  return bundles
end

function M.init_options()
  return {
    bundles = M.bundles(),
  }
end

function M.lsp_config()
  return {
    filetypes = { 'java' },
    root_markers = M.build_markers,
    settings = M.settings(),
    init_options = M.init_options(),
  }
end

local function make_cmd(root_dir)
  local cmd = { vim.fn.exepath('jdtls') ~= '' and vim.fn.exepath('jdtls') or 'jdtls' }
  local lombok_jar = find_lombok_jar()

  if lombok_jar then
    table.insert(cmd, '--jvm-arg=-javaagent:' .. lombok_jar)
  end

  table.insert(cmd, '-data')
  table.insert(cmd, get_workspace_dir(root_dir))

  local debug_file = vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls', 'last_cmd.txt')
  vim.fn.mkdir(vim.fs.dirname(debug_file), 'p')
  vim.fn.writefile(cmd, debug_file)

  return cmd
end

local function setup_codelens(client, bufnr)
  if not client:supports_method('textDocument/codeLens') then
    return
  end

  local group = vim.api.nvim_create_augroup('my.java.codelens.' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
    end,
  })
  pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
end

local function on_attach(client, bufnr)
  local jdtls = require('jdtls')

  vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, {
    buffer = bufnr,
    desc = 'Java organize imports',
  })
  vim.keymap.set('n', '<leader>jR', function()
    M.reset_workspace(bufnr)
  end, {
    buffer = bufnr,
    desc = 'Java reset jdtls workspace',
  })

  -- 调试接入（按 nvim-jdtls 官方文档 Debugger via nvim-dap 一节）：
  -- nvim-dap 可用时注册 java 调试适配器，并提供测试调试和主类发现的按键
  local ok_dap = pcall(require, 'dap')
  if ok_dap then
    local dap = require('dap')
    pcall(jdtls.setup_dap, { hotcodereplace = 'auto' })

    vim.keymap.set('n', '<leader>df', function()
      jdtls.test_class()
    end, { buffer = bufnr, desc = 'Java 调试当前测试类' })
    vim.keymap.set('n', '<leader>dn', function()
      jdtls.test_nearest_method()
    end, { buffer = bufnr, desc = 'Java 调试最近的测试方法' })
    vim.keymap.set('n', '<leader>jM', function()
      require('jdtls.dap').setup_dap_main_class_configs({ verbose = true })
    end, { buffer = bufnr, desc = 'Java 发现并注册项目主类' })

    -- 等 jdtls 把项目导入完后再自动发现主类（失败可用 <leader>jM 手动重试）
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(require('jdtls.dap').setup_dap_main_class_configs, { verbose = false })
      end
    end, 8000)
  end

  setup_codelens(client, bufnr)
end

function M.start_or_attach(bufnr)
  local root_dir = get_root_dir(bufnr)
  if not root_dir then
    return
  end

  local config = vim.tbl_deep_extend('force', M.lsp_config(), {
    cmd = make_cmd(root_dir),
    root_dir = root_dir,
    on_attach = on_attach,
  })

  require('jdtls').start_or_attach(config)
end

function M.reset_workspace(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local root_dir = get_root_dir(bufnr)
  if not root_dir then
    vim.notify('Java root dir not found', vim.log.levels.WARN)
    return
  end

  local workspace_dir = get_workspace_dir(root_dir)
  stop_clients_for_root(root_dir)
  vim.fn.delete(workspace_dir, 'rf')

  vim.notify('Reset jdtls workspace: ' .. workspace_dir)

  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.start_or_attach(bufnr)
    end
  end, 300)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('my.java', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'java',
    callback = function(args)
      M.start_or_attach(args.buf)
    end,
  })

  vim.api.nvim_create_user_command('JavaResetWorkspace', function()
    M.reset_workspace()
  end, {
    desc = 'Reset jdtls workspace for current Java project',
  })
end

return M
