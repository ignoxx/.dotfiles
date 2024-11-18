return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			notify_on_error = false,
			format_on_save = {
				timeout_ms = 300,
				lsp_fallback = true,
			},
			formatters_by_ft = {
				templ = { "templ", "html" },
				go = { "goimports", "gofmt" },
				gdscript = { "gdformat" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				lua = { "stylua" },
			},
		},
	},
	{ "tpope/vim-sleuth" },
}
