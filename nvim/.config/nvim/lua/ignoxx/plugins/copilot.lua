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
}
