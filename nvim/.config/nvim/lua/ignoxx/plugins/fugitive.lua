return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", function()
			if not pcall(vim.cmd.Git, {}) then
				print("not a git repo")
			end
		end)

		local fugitive_augroup = vim.api.nvim_create_augroup("ignoxx_fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = fugitive_augroup,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end
			end,
		})
	end,
}
