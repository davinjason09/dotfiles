local width = math.max(100, math.floor(vim.o.columns * 0.65)) - 2
local delta_cmd = string.format("delta -w %s", width)

return {
  "snacks.nvim",
  opts = {
    ---@type snacks.picker.Config
    picker = {
      prompt = " ",
      layout = { preset = "default" },
      matcher = {
        cwd_bonus = true,
        frecency = true,
      },
      formatters = {
        file = {
          filename_first = true,
          truncate = 50,
        },
      },
      previewers = {
        diff = {
          builtin = false,
          cmd = delta_cmd,
        },
        git = { builtin = false },
      },
      sources = {
        files = { hidden = true },
        smart = { hidden = true },
        buffers = {
          on_show = function(picker) picker:action("stopinsert") end,
          layout = "ivy",
          win = {
            input = { keys = { ["d"] = "bufdelete" } },
            list = { keys = { ["d"] = "bufdelete" } },
          },
        },
        diagnostics = { layout = "dropdown" },
        diagnostics_buffer = { layout = "dropdown" },
        keymaps = {
          plugs = true,
          layout = {
            hidden = { "preview" },
            layout = { width = 0.8, height = 0.6 },
          },
        },
        notifications = {
          layout = "vertical",
          win = {
            preview = { minimal = true },
          },
        },
        undo = { layout = "dropdown" },
      },
      on_close = function()
        local last_win = vim.fn.win_getid(vim.fn.winnr("#"))
        vim.schedule(Utils.edit.escape)

        if last_win == 0 or not vim.api.nvim_win_is_valid(last_win) then return end
        vim.api.nvim_set_current_win(last_win)
      end,
      actions = {
        stopinsert = function() vim.cmd.stopinsert() end,
      },
      win = {
        input = {
          keys = {
            ["<ESC>"] = { "close", mode = { "n", "i" } },
            ["<C-c>"] = { "stopinsert", mode = { "i" } },
            ["<C-e>"] = { "toggle_preview", mode = { "n", "i" } },
            ["<C-u>"] = { "preview_scroll_up", mode = { "n", "i" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "n", "i" } },
            ["<C-f>"] = { "list_scroll_down", mode = { "n", "i" } },
            ["<C-b>"] = { "list_scroll_up", mode = { "n", "i" } },
            ["<C-p>"] = { "history_back", mode = { "n", "i" } },
            ["<C-n>"] = { "history_forward", mode = { "n", "i" } },
            ["<C-BS>"] = { "<C-S-w>", mode = { "i" }, expr = true },
          },
        },
        preview = {
          wo = { signcolumn = "no" },
        },
      },
      icons = {
        files = { dir = "", dir_open = "", file = "" },
        kinds = Defaults.icons.kind,
        git = Defaults.icons.git,
      },
    },
  },
  -- stylua: ignore
  keys = {
    -- Top Pickers
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    -- Find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "[F]ind [B]uffers" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "[F]ind by [G]rep" },
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "[F]ind [W]ord", mode = { "n", "x" } },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "[F]ind [C]onfig File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "[F]ind [F]iles" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "[F]ind [P]rojects" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "[F]ind [R]ecent" },
    { "<leader>fl", function() Snacks.picker.lines() end, desc = "[F]ind [L]ines" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "[F]ind [H]elp" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "[F]ind [K]eymaps" },
    -- Search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "[S]earch Registers [\"]" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "[S]earch History [/]" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "[S]earch [A]utocmds" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "[S]earch [C]ommand History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "[S]earch [C]ommands" },
    { "<leader>sh", function() Snacks.picker.highlights() end, desc = "[S]earch [H]ighlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "[S]earch [I]cons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "[S]earch [J]umps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "[S]earch [L]ocation List" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "[S]earch [M]arks" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "[S]earch [M]an Pages" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "[S]earch [P]lugin Spec" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "[S]earch [Q]uickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "[S]earch: [R]esume Search" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "[S]earch [U]ndo History" },
    -- Git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "[G]it [B]ranches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "[G]it [L]og" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "[G]it [L]og Line" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "[G]it [S]tatus" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "[G]it [S]tash" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "[G]it Log [F]ile" },
    -- Diagnostics
    { "<leader>xd", function() Snacks.picker.diagnostics() end, desc = "Global Diagnostics" },
    { "<leader>xD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    -- Misc
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "z=", function() Snacks.picker.spelling() end, desc = "Spelling Suggestions" },
    -- Custom
    { "<leader>dr", function() Utils.picker.reload() end, desc = "[D]ebug: [R]eload Plugins" },
    { "<leader>so", function() Utils.picker.options() end, desc = "[S]earch [O]ption" },
    { "<leader>sz", function() Utils.picker.chezmoi() end, desc = "[S]earch Che[z]moi File" },
  },
}
