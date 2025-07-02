_G.Config = os.getenv("HOME") .. "/.config/yazi/config"

require("full-border"):setup({ type = ui.Border.ROUNDED })

-- Statusline
local stl_opts = dofile(Config .. "/yatline.lua")
require("yatline"):setup(stl_opts.yatline)
require("yatline-githead"):setup(stl_opts.githead)
