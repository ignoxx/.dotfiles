require("ignoxx.set")
require("ignoxx.remap")
require("ignoxx.lazy_init")
require("ignoxx.custom.autorun")

-- surpress the error when selecting code actions
do
	local original_select = vim.ui.select
	vim.ui.select = function(items, opts, on_choice)
		local _, _ = pcall(function()
			original_select(items, opts, on_choice)
		end)
	end
end

local augroup = vim.api.nvim_create_augroup
local ignoxx_group = augroup("ignoxx", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

-- :W should behave just as :w
vim.api.nvim_create_user_command("W", "w", {})

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- removes trailing whitespace
autocmd({ "BufWritePre" }, {
	group = ignoxx_group,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

autocmd("LspAttach", {
	group = ignoxx_group,
	callback = function(args)
		local telescope = require("telescope.builtin")

		-- stylua: ignore start
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gr", telescope.lsp_references, opts)
		vim.keymap.set("n", "gi", function() telescope.lsp_implementations({ path_display = { "truncate" } }) end, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "<leader>vca",vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
		vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
		vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1 }) end, opts)

		local trouble = require("trouble")
		vim.keymap.set("n", "<leader>tt", function()
			trouble.toggle()
		end)

		vim.keymap.set("n", "[t", function()
			trouble.next({ skip_groups = true, jump = true })
		end)

		vim.keymap.set("n", "]t", function()
			trouble.previous({ skip_groups = true, jump = true })
		end)
	end,
})
