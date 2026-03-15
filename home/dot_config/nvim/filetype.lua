vim.filetype.add({
  filename = {
    [".chezmoiignore"] = "gitignore",
    [".chezmoiremove"] = "gitignore",
    [".clang-format"] = "yaml",
    [".env"] = "sh",
    [".prettierignore"] = "gitignore",
    [".styluaignore"] = "gitignore",
    [".zshenv"] = "zsh",
    [".zprofile"] = "zsh",
    [".zshrc"] = "zsh",
  },
  extension = {
    mdx = "mdx",
    pyx = "cython",
    pxd = "cython",
    tmpl = "gotmpl",
    xaml = "xml",
    yml = "yaml",
  },
  pattern = {
    [".*%.gitconfig"] = "gitconfig",
    ["tsconfig*.json"] = "json",
    [".*%.example"] = function(path, buf)
      return vim.filetype.match({ buf = buf, filename = path:gsub(".example", "") })
    end,
    [".*"] = function(path, buf)
      if not path or not buf or vim.bo[buf].filetype == "bigfile" then return end
      if path ~= vim.api.nvim_buf_get_name(buf) then return end

      local size = vim.fn.getfsize(path)
      if size <= 0 then return end

      local bigfile_opts = Defaults.bigfile

      if size > bigfile_opts.size then return "bigfile" end

      local lines = vim.api.nvim_buf_line_count(buf)
      if lines <= 0 then return end

      return (size - lines) / lines > bigfile_opts.line_length and "bigfile" or nil
    end,
    ["${HOME}/.local/share/chezmoi/.*"] = {
      function(path, buf)
        if path:match("/dot_*") then
          return vim.filetype.match({ buf = buf, filename = path:gsub("/dot_", "/.") })
        end

        for _, pattern in ipairs({ "external_", "executable_" }) do
          if path:match(pattern) then
            return vim.filetype.match({ buf = buf, filename = path:gsub(pattern, "") })
          end
        end
      end,
      { priority = -math.huge },
    },
  },
})

vim.treesitter.language.register("markdown", "blink-cmp-documentation")

-- .tmpl file injection
vim.treesitter.query.add_directive("inject-gotmpl!", function(_, _, bufnr, _, metadata)
  local ok, buf_name = pcall(vim.api.nvim_buf_get_name, bufnr)
  if not ok then return end

  local fname = vim.fs.basename(buf_name)
  local ext = vim.filetype.match({ buf = bufnr, filename = fname:gsub("%.tmpl", "") })
  metadata["injection.language"] = ext
end, {})
