return {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-e>"] = {
					function(cmp)
						cmp.show()
					end,
				},
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				menu = { border = "rounded" },
				documentation = { window = { border = "rounded" }, auto_show = false },
			},

			signature = { window = { border = "single" } },

			fuzzy = {
				implementation = "prefer_rust_with_warning",
				sorts = {
					"exact",
					-- defaults
					"score",
					"sort_text",
				},
			},

			-- freakycrazymfker

			sources = {
				-- add lazydev to your completion providers
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					buffer = {
						opts = {
							-- get_bufnrs = vim.api.nvim_list_bufs
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.bo[bufnr].buftype == ""
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
		},
	},
}
