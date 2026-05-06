require("nvim-treesitter").setup({
    ensure_installed = {
        "json", "python", "ron", "javascript", "haskell", "d", "query",
        "typescript", "tsx", "rust", "zig", "php", "yaml", "html", "css",
        "markdown", "markdown_inline", "bash", "lua", "vim", "vimdoc", "c",
        "dockerfile", "gitignore", "astro", "go", "templ"
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
    },
})

vim.keymap.set({ "x", "o" }, "af", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)

require("treesitter-context").setup({})
