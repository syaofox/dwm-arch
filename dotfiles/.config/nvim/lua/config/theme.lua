local M = {}

function M.apply()
    local f = vim.fn.expand("~/.config/nvim/theme.lua")
    if vim.fn.filereadable(f) == 1 then
        vim.cmd("source " .. f)
    else
        vim.cmd.colorscheme("tokyonight")
    end

    vim.cmd("hi Directory guibg=NONE")
    vim.cmd("hi SignColumn guibg=NONE")
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })

    local theme = vim.g.current_theme or "tokyonight"
    pcall(function()
        require("lualine").setup({ options = { theme = theme } })
    end)
end

return M
