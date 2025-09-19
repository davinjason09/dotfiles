local is_nofile = vim.bo.buftype == "nofile"

vim.opt_local.wrap = not is_nofile
vim.opt_local.linebreak = true
vim.opt_local.spell = not is_nofile
