local attach_to_buffer = function(buf, pattern, cmd)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "**output:**" })

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("mawife", { clear = true }),
		pattern = pattern,
		callback = function()
			local append_data = function(_, data)
				if data then
					for index, value in ipairs(data) do
						if value == "" then
							table.remove(data, index)
						end
					end

					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end

			vim.fn.jobstart(cmd, {
				stdout_buffered = true,
				on_stdout = append_data,
				on_stderr = append_data,
			})
		end,
	})
end

vim.api.nvim_create_user_command("AutoRun", function()
	local pattern = vim.fn.input("file pattern: ")
	local cmd = vim.fn.split(vim.fn.input("cmd: "), " ")
	local bufnr = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_open_win(bufnr, false, {
		split = "right",
		width = 40,
	})

	attach_to_buffer(bufnr, pattern, cmd)
end, {})
