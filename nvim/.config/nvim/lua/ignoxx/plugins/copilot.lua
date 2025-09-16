return {
	{
		"zbirenbaum/copilot.lua",
		lazy = true,
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = false,
				keymap = {
					accept = "<C-a>",
					next = "<C-]>",
					prev = "<C-[>",
					dismiss = "<C-L>",
				},
			},
		},
	},
	-- {
	-- 	"supermaven-inc/supermaven-nvim",
	-- 	config = function()
	-- 		require("supermaven-nvim").setup({
	-- 			keymaps = {
	-- 				accept_suggestion = "<Tab>",
	-- 				accept_word = "<C-a>",
	-- 			},
	-- 			ignore_filetypes = {},
	-- 			condition = function()
	-- 				return false
	-- 			end,
	-- 			log_level = "off",
	-- 			disable_inline_completion = false,
	-- 			disable_keymaps = false,
	-- 		})
	--
	-- 		-- local api = require("supermaven-nvim.api")
	-- 		local completion_preview = require("supermaven-nvim.completion_preview")
	-- 		completion_preview.disable_inline_completion = true
	--
	-- 		vim.keymap.set("i", "<C-]>", function()
	-- 			completion_preview.disable_inline_completion = not completion_preview.disable_inline_completion
	-- 		end, { silent = true, noremap = true })
	-- 	end,
	-- },
}
