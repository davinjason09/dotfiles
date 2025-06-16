vim.filetype.add({
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
  },
})
