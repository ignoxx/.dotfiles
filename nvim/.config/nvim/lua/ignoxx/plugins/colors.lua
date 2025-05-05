function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "Visual", { bg = "#3c3c47", fg = "none" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "none" })

	vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#0F0F10", bg = "none" })
	vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#171718", bg = "none" })
	vim.api.nvim_set_hl(0, "SnacksIndentChunk", { fg = "#171718", bg = "none" })

	vim.api.nvim_set_hl(0, "OilFile", { bg = "none", fg = "#7a7a8c" })
	vim.api.nvim_set_hl(0, "OilDirHidden", { link = "OilDir" })

	-- cursor hover hightlight same word
	vim.api.nvim_set_hl(0, "LocalHighlight", { bg = "#3c3c47" })

	-- quick yank hightlight flash
	vim.api.nvim_set_hl(0, "IncSearch", { bg = "#f3b28e" })

	-- Telescope
	vim.api.nvim_set_hl(0, "PMenu", { bg = "none", fg = "#c1c1c8" })
	vim.api.nvim_set_hl(0, "PMenuSel", { bg = "#3c3c47" })
	vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { fg = "#646477" })
end

return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "moon",
				dark_variant = "moon",
				disable_background = true,
				styles = {
					italic = false,
					transparency = true,
					bold = true,
				},
				highlight_groups = {
					-- String = { fg = "#f3b28e" },
					-- Function = { fg = "#ebadae" }
					-- Comment = { fg = "foam" },
					-- VertSplit = { fg = "muted", bg = "muted" },
				},
			})

			ColorMyPencils("roseprime")
		end,
	},
	{
		"vague2k/vague.nvim",
		name = "vague",
		opts = {
			transparent = true,
			style = {
				comments = "none",
				conditionals = "none",
				functions = "none",
				headings = "bold",
				operators = "none",
				strings = "none",
			},
		},
	},
	{ "erikbackman/brightburn.vim", name = "brightburn" },
	{
		"cdmill/neomodern.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,

			-- highlights. For example, `bold`, `italic`, `underline`, `none`.
			code_style = {
				comments = "none",
				strings = "none",
			},
		},
	},
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		config = function()
			require("tokyonight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				transparent = false, -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = false },
					keywords = { italic = false },
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "dark", -- style for sidebars, see below
					floats = "dark", -- style for floating windows
				},
			})
		end,
	},
}
