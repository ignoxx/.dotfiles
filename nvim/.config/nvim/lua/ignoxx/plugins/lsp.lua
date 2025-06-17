return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		-- "L3MON4D3/LuaSnip",
		-- "saadparwaiz1/cmp_luasnip",
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},

	config = function()
		-- override globally, to get borders on hover float windows.... shibagula
		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		require("mason").setup()
		require("mason-lspconfig").setup({
			automatic_enable = true,
			ensure_installed = {
				"lua_ls",
				"gopls",
				"ts_ls",
			},
			handlers = {
				["html"] = function()
					require("lspconfig").html.setup({
						filetypes = { "html", "templ" },
					})
				end,
			},
		})

		-- not sure if i still need this
		-- vim.diagnostic.config({
		-- 	update_in_insert = true,
		-- 	virtual_text = true,
		-- 	float = {
		-- 		style = "minimal",
		-- 		header = "",
		-- 		prefix = "",
		-- 		border = "rounded",
		-- 		focusable = true,
		-- 	},
		-- })
	end,
}
