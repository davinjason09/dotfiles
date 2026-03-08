local function get_jdtls_cache_dir() return vim.fn.stdpath("cache") .. "/jdtls" end

local function get_jdtls_workspace_dir() return get_jdtls_cache_dir() .. "/workspace" end

local root_dir = vim.fs.root(0, {
  { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" },
  { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" },
})

local ws_name = vim.fn.fnamemodify(root_dir, ":p:h:t")

---@type vim.lsp.Config
return {
  cmd = {
    "jdtls",
    -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
    "--jvm-arg=-XX:+UseParallelGC",
    "--jvm-arg=-XX:MinHeapFreeRatio=5",
    "--jvm-arg=-XX:MaxHeapFreeRatio=10",
    "--jvm-arg=-XX:GCTimeRatio=4",
    "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
    "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
    "--jvm-arg=-Dlog.protocol=true",
    "--jvm-arg=-Dlog.level=ALL",
    "--jvm-arg=-Dfile.encoding=utf-8",
    "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false",
    "--jvm-arg=-Xms256m",
    "--jvm-arg=-Xmx" .. (vim.env.JDTLS_XMX or "1G"),
    "-configuration",
    get_jdtls_cache_dir() .. "/config",
    "-data",
    get_jdtls_workspace_dir() .. ws_name,
  },
  filetypes = { "java" },
  root_dir = root_dir,
}
