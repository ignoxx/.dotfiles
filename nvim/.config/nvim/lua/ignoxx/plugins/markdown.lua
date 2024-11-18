return {
	"MeanderingProgrammer/render-markdown.nvim",
	opts = {
		heading = {
			-- Turn on / off heading icon & background rendering
			-- enabled = false,
			-- Turn on / off any sign column related rendering
			sign = false,
			-- Determines how icons fill the available space:
			--  inline:  underlying '#'s are concealed resulting in a left aligned icon
			--  overlay: result is left padded with spaces to hide any additional '#'
			-- position = 'inline',
			-- Width of the heading background:
			--  block: width of the heading text
			--  full:  full width of the window
			-- Can also be an array of the above values in which case the 'level' is used
			-- to index into the array using a clamp
			width = "full",
			-- border_virtual = true,
			-- The 'level' is used to index into the array using a clamp
			-- Highlight for the heading icon and extends through the entire line
			-- backgrounds = nil,
			-- foregrounds = nil
			-- Amount of padding to add to the left of headings
			left_pad = 0,
			-- Amount of padding to add to the right of headings when width is 'block'
			-- right_pad = 1,
			-- Minimum width to use for headings when width is 'block'
			min_width = 0,
			-- Determins if a border is added above and below headings
			border = false,
		},
		overrides = {
			buftype = {
				nofile = {
					code = { enabled = false },
					heading = { enabled = false },
					link = { enabled = true },
				},
			},
		},
		code = {
			-- Turn on / off code block & inline code rendering
			enabled = true,
			-- Determines how code blocks & inline code are rendered:
			--  none:     disables all rendering
			--  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
			--  language: adds language icon to sign column if enabled and icon + name above code blocks
			--  full:     normal + language
			style = "normal",
			-- An array of language names for which background highlighting will be disabled
			-- Likely because that language has background highlights itself
			disable_background = { "diff" },
			-- Width of the code block background:
			--  block: width of the code block
			--  full:  full width of the window
			width = "block",
			-- Amount of padding to add to the left of code blocks
			left_pad = 2,
			-- Amount of padding to add to the right of code blocks when width is 'block'
			right_pad = 2,
			-- Minimum width to use for code blocks when width is 'block'
			min_width = 8,
		},
	},
	dependencies = { "nvim-treesitter/nvim-treesitter" },
}
