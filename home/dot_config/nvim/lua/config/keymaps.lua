local map = vim.keymap.set

-- HACK: update heirline mode immediately after pressing the visual mode keys
-- While the autocommand solution (nvim/lua/config/autocmds.lua) works to update the statusline during
-- O-PENDING mode, it doesn't update the statusline correctly on mode V and <C-v> because which-key
-- put a defer to those mode. As a workaround, we surpress the which-key event by executing the mode
-- change directly. We then call which-key to show the menu after a delay so the statusline can be
-- redrawn before the event is blocked.

local mode_keys = { "v", "V", "\22" }
for _, key in ipairs(mode_keys) do
  map("n", key, function()
    local defer = key == "V" or key == "\22"
    vim.cmd("normal! " .. key)
    vim.defer_fn(function() require("which-key").show({ defer = defer }) end, 1)
  end)
end
