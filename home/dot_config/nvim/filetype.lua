vim.filetype.add({
  filename = {
    [".chezmoiignore"] = "gitignore",
    [".chezmoiremove"] = "gitignore",
    [".prettierignore"] = "gitignore",
    [".styluaignore"] = "gitignore",
    [".zshenv"] = "sh",
    [".zprofile"] = "sh",
    [".zshrc"] = "sh",
    [".clang-format"] = "yaml",
  },
  extension = {
    mdx = "mdx",
    pyx = "cython",
    pxd = "cython",
    xaml = "xml",
    zsh = "sh",
  },
  pattern = {
    ["tsconfig*.json"] = "jsonc",
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
    [".*%.tmpl"] = function(path, buf)
      local content_ft = vim.filetype.match({ buf = buf, filename = path:gsub("%.tmpl", "") })
      if not content_ft then return "gotmpl" end

      local lang = vim.treesitter.language.get_lang(content_ft)
      local scm = string.format(
        [[
          ((text) @injection.content
          (#set! injection.language "%s")
          (#set! injection.combined))
        ]],
        lang
      )
      return "gotmpl",
        function(bufnr)
          vim.treesitter.query.set("gotmpl", "injections", scm)
          vim.treesitter.start(bufnr, "gotmpl")
        end
    end,
  },
})
