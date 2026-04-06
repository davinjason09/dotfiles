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
  on_attach = function(client, buf)
    vim.api.nvim_buf_create_user_command(
      buf,
      "LspCopilotSignIn",
      function() sign_in(buf, client) end,
      { desc = "Sign in Copilot with GitHub" }
    )
    vim.api.nvim_buf_create_user_command(
      buf,
      "LspCopilotSignOut",
      function() sign_out(buf, client) end,
      { desc = "Sign out Copilot with GitHub" }
    )

    local map = vim.keymap.set
    local comp = Utils.edit.completion

    -- Accept suggestion by word
    map("i", "<C-Right>", function()
      if not vim.lsp.inline_completion.get({ on_accept = comp.accept_word }) then return "<C-Right>" end
    end, { expr = true, replace_keycodes = true, buf = buf })

    -- Accept suggestion by line
    map("i", "<C-S-Right>", function()
      if not vim.lsp.inline_completion.get({ on_accept = comp.accept_line }) then return "<C-S-Right>" end
    end, { expr = true, replace_keycodes = true, buf = buf })

    -- Accept suggestion without change
    map("i", "<C-Down>", function()
      if not vim.lsp.inline_completion.get() then return "<C-Down>" end
    end, { expr = true, replace_keycodes = true, buf = buf })

    -- Cycle to next suggestion
    map("i", "<M-]>", function() vim.lsp.inline_completion.select() end, { buffer = buf })

    -- Cycle to prev suggestion
    map("i", "<M-[>", function() vim.lsp.inline_completion.select({ count = -1 }) end, { buffer = buf })
  end,
  on_exit = vim.schedule_wrap(function()
    local unmap = vim.api.nvim_buf_del_keymap
    unmap(0, "i", "<C-Right>")
    unmap(0, "i", "<C-S-Right>")
    unmap(0, "i", "<C-Down>")
    unmap(0, "i", "<M-]>")
    unmap(0, "i", "<M-[>")
  end),
}
