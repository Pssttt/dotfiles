return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_b = {
					"branch",
					"diff",
				},
				lualine_c = {
					require("lazyvim.util").lualine.pretty_path({
						length = 0,
						relative = "cwd",
						modified_hl = "MatchParen",
						directory_hl = "",
						filename_hl = "Bold",
						modified_sign = "",
						readonly_icon = " 󰌾 ",
					}),
				},
				lualine_x = {
					{
						"diagnostics",
						sections = { "error", "warn", "info", "hint" },
					},
				},
				lualine_y = { "encoding", "filetype" },
			},
		},
	},
}
