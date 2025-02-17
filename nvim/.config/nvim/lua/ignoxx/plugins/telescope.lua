return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-live-grep-args.nvim", name = "live_grep_args", version = "^1.0.0" },
			{ "nvim-telescope/telescope-fzf-native.nvim", name = "fzf", build = "make" },
		},

		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				-- defaults = {
				-- 	layout_strategy = "vertical",
				-- 	layout_config = {
				-- 		vertical = {
				-- 			prompt_position = "bottom",
				-- 			mirror = false,
				-- 		},
				-- 	},
				-- },
				defaults = require("telescope.themes").get_ivy(),
				extensions = {
					auto_quoting = true,
				},
			})

			vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
			vim.keymap.set("n", "<C-f>", builtin.find_files, {})
			vim.keymap.set("n", "<C-p>", function()
				local success = pcall(builtin.git_files, {})
				if not success then
					pcall(builtin.find_files, {})
				end
			end)

			vim.keymap.set("n", "<leader>ps", function()
				-- builtin.live_grep()
				telescope.extensions.live_grep_args.live_grep_args()
			end)

			vim.keymap.set("v", "<leader>ps", function()
				-- Save the current selection to the unnamed register (")
				vim.cmd('normal! "vy')

				-- Get the content of the unnamed register, which is the visual selection
				--- @type string
				local selected_text = vim.fn.getreg('"')

				selected_text = selected_text.gsub(selected_text, "\n", " ")
				selected_text = selected_text:gsub("^%s*(.-)%s*$", "%1")

				telescope.extensions.live_grep_args.live_grep_args({
					default_text = selected_text,
				})
			end)

			-- NOTE: check if this is something NOICE
			vim.keymap.set("n", "<leader>pws", function()
				local word = vim.fn.expand("<cword>")
				builtin.grep_string({ search = word })
			end)
			vim.keymap.set("n", "<leader>pWS", function()
				vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
				local word = vim.fn.expand("<cWORD>")
				builtin.grep_string({ search = word })
			end)

			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
	},
}
