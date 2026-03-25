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
    ["${HOME}/%.local/share/chezmoi/.*"] = {
      function(path, buf)
        if not vim.uv.fs_stat(path) then return end

        local filename = vim.fs.basename(path)
        if filename:match("dot_") then
          return vim.filetype.match({ buf = buf, filename = filename:gsub("dot_", ".") })
        end

        if filename:match("^external_") then
          return vim.filetype.match({ buf = buf, filename = filename:gsub("external_", "") })
        end

        if filename:match("executable_") then
          local shebang = vim.fn.readfile(path, "", 1)[1]

          if shebang:match("^#!") then
            local shell = shebang:match("^#!.*%s([^%s]+)") or shebang:match("^#!.*%/([^%s]+)")
            return (shell and shell ~= "") and shell or "sh"
          else
            return "sh"
          end
        end
      end,
      { priority = -math.huge },
    },
  },
})

vim.treesitter.language.register("markdown", { "blink-cmp-documentation", "mdx" })

-- .tmpl file injection
vim.treesitter.query.add_directive("inject-gotmpl!", function(_, _, buf, _, metadata)
  local ok, buf_name = pcall(vim.api.nvim_buf_get_name, buf)
  if not ok then return end

  local fname = vim.fs.basename(buf_name)
  local ext = vim.filetype.match({ buf = buf, filename = fname:gsub("%.tmpl", "") })
  metadata["injection.language"] = ext
end, {})

-- mise toml injection
vim.treesitter.query.add_predicate("is-mise?", function(_, _, bufnr, _)
  local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
  local split = vim.split(filepath, "/")
  local filename = split[#split - 1] .. split[#split]
  return filename:match(".*mise.*%.toml$") ~= nil
end, { force = true, all = false })
