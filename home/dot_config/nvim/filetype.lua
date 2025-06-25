vim.filetype.add({
  filename = {
    [".chezmoiignore"] = "gitignore",
    [".chezmoiremove"] = "gitignore",
  },
  extension = {
    mdx = "mdx",
    pyx = "cython",
    pxd = "cython",
  },
  pattern = {
    ["tsconfig*.json"] = "jsonc",
    [".*"] = function(path, bufnr)
      return vim.bo[bufnr]
          and vim.bo[bufnr].filetype ~= "bigfile"
          and path
          and vim.fn.getfsize(path) > (1024 * 1024 * 10)
          and "bigfile"
        or nil
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
