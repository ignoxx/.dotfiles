return {
	"barrettruth/diffs.nvim",
	dependencies = { "tpope/vim-fugitive" },
	config = function()
		vim.g.diffs = {
			hide_prefix = false,
			highlights = {
				background = true,
				gutter = false,
			},
			fugitive = {
				horizontal = "du",
				vertical = "dU",
			},
		}
	end,
}
