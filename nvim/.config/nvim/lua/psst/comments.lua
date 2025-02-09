local M = {}

function M.removeTreesitterComments()
	local ts_utils = require("nvim-treesitter.ts_utils")
	local parser = vim.treesitter.get_parser(0)
	if not parser then
		print("No Treesitter parser available for the current buffer!")
		return
	end
	local tree = parser:parse()[1]
	local root = tree:root()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Get selected range (using vim.fn.getpos, which returns a table like {bufnum, lnum, col, off})
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local ls, cs = start_pos[2], start_pos[3]
	local le, ce = end_pos[2], end_pos[3]

	local function traverse(node)
		if node:type() == "comment" then
			local start_row, start_col, end_row, end_col = node:range()
			-- Note: node:range() returns 0-indexed positions, while getpos() returns 1-indexed lines.
			if start_row >= (ls - 1) and end_row <= (le - 1) then
				vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, { "" })
			end
		end

		-- Recursively traverse children
		for child in node:iter_children() do
			traverse(child)
		end
	end

	traverse(root)
end

return M
