function ClippedBranchName()
    local branch = vim.fn.FugitiveHead()

    if branch == nil then
        return ''
    end

    if string.len(branch) > 20 then
        return string.sub(branch, 1, 14) .. '..'
    end

    return branch
end

function LspNames()
    local lsps = vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
    if lsps and #lsps > 0 then
        local names = {}
        for _, lsp in ipairs(lsps) do
            table.insert(names, lsp.name)
        end
        return table.concat(names, ', ')
    else
        return ""
    end
end

return {
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = false,
                -- component_separators = { left = '', right = '' },
                -- section_separators = { left = '', right = '' },
                -- component_separators = { left = "", right = "" },
                -- section_separators = { left = "", right = "" },
                -- section_separators = { left = "", right = "" },

                refresh = {
                    statusline = 500,
                    tabline = 500,
                    winbar = 500,
                }
            },
            sections = {
                lualine_a = {
                    function()
                        return string.upper(vim.fn.mode())
                    end,
                },
                lualine_b = { ClippedBranchName },
                lualine_c = {
                    'filename'
                },
                lualine_x = {
                    LspNames,
                },
                lualine_y = {
                    {
                        "harpoon2",
                        color_active = { fg = "#95b1fc" }
                        -- indicators = { "a", "s", "q", "w" },
                        -- active_indicators = { "A", "S", "Q", "W" },
                        -- _separator = " ",
                    },
                },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = { "quickfix", "fugitive", "oil", "trouble", "toggleterm" }
        }
    },
    {
        "letieu/harpoon-lualine",
        dependencies = {
            {
                "ThePrimeagen/harpoon",
                branch = "harpoon2",
            }
        },
    }
}
