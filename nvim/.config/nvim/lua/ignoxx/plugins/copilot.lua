return {
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	lazy = true,
	-- 	cmd = "Copilot",
	-- 	event = "InsertEnter",
	-- 	opts = {
	-- 		suggestion = {
	-- 			enabled = true,
	-- 			auto_trigger = false,
	-- 			keymap = {
	-- 				accept = "<C-a>",
	-- 				next = "<C-]>",
	-- 				prev = "<C-[>",
	-- 				dismiss = "<C-L>",
	-- 			},
	-- 		},
	-- 	},
	-- },
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					accept_word = "<C-a>",
				},
				ignore_filetypes = {},
				condition = function()
					return false
				end,
				log_level = "off", -- set to "off" to disable logging completely
				disable_inline_completion = false, -- disables inline completion for use with cmp
				disable_keymaps = false, -- disables built in keymaps for more manual control
			})
		end,
	},
}
