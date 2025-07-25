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
				list = { selection = { preselect = true, auto_insert = false } },
				menu = {
					border = "rounded",
					draw = {
						columns = {
							{ "kind_icon", gap = 1 },
							{ "label", "label_description", gap = 1 },
						},
					},
				},

				documentation = { window = { border = "rounded" }, auto_show = false },
			},

			signature = { window = { border = "rounded" }, enabled = true },

			fuzzy = {
				implementation = "prefer_rust_with_warning",
				sorts = {
					-- "exact",
					"score",
					"sort_text",
				},
			},

			sources = {
				-- add lazydev to your completion providers
				default = { "lsp", "path", "snippets", "lazydev", "buffer" },
				providers = {
					-- defaults to `{ 'buffer' }`
					lsp = { fallbacks = {} },
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
		opts_extend = { "sources.default" },
	},
}
