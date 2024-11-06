return {
    'stevearc/oil.nvim',
    opts = {
        watch_for_changes = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
            ["<C-l>"] = "actions.preview",
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-r>"] = "actions.refresh",
            ["-"] = "actions.parent",
            -- ["gx"] = "actions.open_external",
            ["th"] = "actions.toggle_hidden",
            ["tt"] = "actions.toggle_trash",
        },
        columns = {
            -- "icon",
            -- "permissions",
            -- "size",
            -- "mtime",
        },
        use_default_keymaps = false,
        view_options = {
            -- Show files and directories that start with "."
            show_hidden = true,
        },
        preview = {
            -- preview_split: Split direction: "auto", "left", "right", "above", "below".
            preview_split = "left",
        },
        float = {
            -- Padding around the floating window
            padding = 2,
            max_width = 0,
            max_height = 0,
            border = "rounded",
            win_options = {
                winblend = 0,
            },
            -- preview_split: Split direction: "auto", "left", "right", "above", "below".
            preview_split = "down",
        },
    },
}
