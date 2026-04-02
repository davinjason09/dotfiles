---@param buf integer,
---@param client vim.lsp.Client
local function sign_in(buf, client)
  client:request("signIn", vim.empty_dict(), function(err, result)
    if err then return vim.notify(err.message, vim.log.levels.ERROR) end

    if result.command then
      local code = result.userCode
      local command = result.command
      vim.fn.setreg("+", code)
      vim.fn.setreg("*", code)
      local continue = vim.fn.confirm(
        "Copied your one-time code to clipboard.\n" .. "Open the browser to complete the sign-in process?",
        "&Yes\n&No"
      )

      if continue ~= 1 then goto continue end
      client:exec_cmd(command, { bufnr = buf }, function(cmd_err, cmd_result)
        if cmd_err then return vim.notify(cmd_err.message, vim.log.levels.ERROR) end
        if cmd_result.status == "OK" then vim.notify("Signed in as " .. cmd_result.user .. ".") end
      end)
    end

    ::continue::
    if result.status == "PromptUserDeviceFlow" then
      vim.notify("Enter your one-time code " .. result.userCode .. " in " .. result.verificationUri)
    elseif result.status == "AlreadySignedIn" then
      vim.notify("Already signed in as " .. result.user .. ".")
    end
  end)
end

---@param client vim.lsp.Client
local function sign_out(_, client)
  client:request("signOut", vim.empty_dict(), function(err, result)
    if err then return vim.notify(err.message, vim.log.levels.ERROR) end
    if result.status == "NotSignedIn" then vim.notify("Not signed in.") end
  end)
end

---@type vim.lsp.Config
return {
  cmd = { "copilot-language-server", "--stdio" },
  root_markers = { ".git" },
  auto_attach = false,
  init_options = {
    editorInfo = {
      name = "Neovim",
      version = tostring(vim.version()), ---@diagnostic disable-line: call-non-callable
    },
    editorPluginInfo = {
      name = "Neovim",
      version = tostring(vim.version()), ---@diagnostic disable-line: call-non-callable
    },
  },
  settings = {
    telemetry = { telemetryLevel = "off" },
  },
}
