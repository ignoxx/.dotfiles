return {
	"lewis6991/gitsigns.nvim",
	opts = {
	    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	    current_line_blame_opts = {
	        virt_text = true,
	        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
	        delay = 100,
	        ignore_whitespace = true,
	        virt_text_priority = 120,
	        use_focus = true,
	    },
	    current_line_blame_formatter = '<author>, <author_time:%R>',
	}
}
