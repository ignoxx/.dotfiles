return {
    {
        "tzachar/local-highlight.nvim",
        opts = {
            hlgroup = 'LocalHighlight',
            cw_hlgroup = nil,
        }
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = false,
            keywords = {
                TODO = { icon = " ", color = "error" },
            }
        },
    },
    {
        'numToStr/Comment.nvim',
        lazy = false,
        opts = {
            toggler = {
                line = '<leader>/',
                block = '<leader>/'
            },
            opleader = {
                line = '<leader>/',
                block = '<leader>/'
            }
        },
        config = function()
            local api = require("Comment.api")

            -- comment single line
            vim.keymap.set("n", "<leader>/", api.toggle.linewise.current,
                { silent = true, noremap = true, desc = "Comment line" })

            -- comment multiple selected lines
            local esc = vim.api.nvim_replace_termcodes(
                '<ESC>', true, false, true
            )

            vim.keymap.set('x', '<leader>/', function()
                vim.api.nvim_feedkeys(esc, 'nx', false)
                api.toggle.linewise(vim.fn.visualmode())
            end)
        end
    }
}
