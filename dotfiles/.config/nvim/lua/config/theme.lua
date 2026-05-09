local M = {}

function M.apply()
    local theme_file = vim.fn.expand("~/.config/nvim/theme.lua")
    if vim.fn.filereadable(theme_file) == 1 then
        vim.cmd("source " .. theme_file)
    end

    local theme = vim.g.current_theme or "tokyonight"

    if theme == "catppuccin" then
        require("catppuccin").setup({
            flavour = vim.g.catppuccin_flavor or "mocha",
        })
    end

    vim.cmd.colorscheme(theme)

    vim.cmd("hi Directory guibg=NONE")
    vim.cmd("hi SignColumn guibg=NONE")
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })

    pcall(function()
        require("lualine").setup({
            options = { theme = theme },
        })
    end)
end

return M
