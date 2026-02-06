return {
	{
		"saghen/blink.cmp",
		dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
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

			snippets = { preset = "luasnip" },

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				list = { selection = { preselect = true, auto_insert = false } },
				accept = { auto_brackets = { enabled = false } },
				menu = {
					border = "rounded",
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon", gap = 1 },
							{ "label", "label_description", gap = 1 },
							{ "kind", "source_name", gap = 1 },
						},
					},
				},

				documentation = {
					window = { border = "rounded" },
					auto_show = true,
					auto_show_delay_ms = 0,
				},
			},

			signature = {
				enabled = true,
				window = { border = "single", show_documentation = false },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
				sorts = {
					"score",
					"sort_text",
					"exact",
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				per_filetype = {
					sql = { "snippets", "dadbod", "buffer" },
				},
				providers = {
					-- defaults to `{ 'buffer' }`
					lsp = { fallbacks = {}, score_offset = 100 },
					buffer = {
						score_offset = 1,
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
					dadbod = {
						name = "Dadbod",
						module = "vim_dadbod_completion.blink",
						min_keyword_length = 0,
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
