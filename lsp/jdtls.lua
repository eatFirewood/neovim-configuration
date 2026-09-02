-- Java is managed by lua/config/java.lua via nvim-jdtls start_or_attach().
-- That path adds the Lombok javaagent and workspace handling.
-- Keep this file only as documentation to avoid accidentally starting a plain
-- jdtls instance without Lombok support through vim.lsp.enable().
return {}
