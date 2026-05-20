return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"fredrikaverpil/neotest-golang",
			version = "1.15.1", -- Optional, but recommended; track releases
		},
	},
	config = function()
		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				require("neotest-golang")(),
			},
		})

		-- stylua: ignore start
		vim.keymap.set("n", "<leader>T", function() neotest.run.run() end)
		-- stylua: ignore end
	end,
}
