return {
	{
		"danymat/neogen",
		keys = {
			{
				"<leader>cc",
				function()
					require("neogen").generate({})
				end,
				desc = "Neogen Comment",
			},
		},
		opts = { snippet_engine = "luasnip" },
	},
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<c-\>]],
				direction = "float",
			})
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		keys = {
			{
				"<leader>r",
				function()
					require("refactoring").select_refactor()
				end,
				mode = "n",
				noremap = true,
				silent = true,
				expr = true,
			},
		},
		opts = {},
	},
	{
		"Pocco81/auto-save.nvim",
		config = function()
			require("auto-save").setup({
				trigger_events = { "FocusLost" },
			})
		end,
	},
	{
		"monaqa/dial.nvim",
		keys = {
			{
				"<C-q>",
				function()
					return require("dial.map").inc_normal()
				end,
				expr = true,
				desc = "Increment",
			},
			{
				"<C-x>",
				function()
					return require("dial.map").dec_normal()
				end,
				expr = true,
				desc = "Decrement",
			},
		},
		opts = function()
			local augend = require("dial.augend")

			local logical_alias = augend.constant.new({
				elements = { "&&", "||" },
				word = false,
				cyclic = true,
			})

			local ordinal_numbers = augend.constant.new({
				elements = {
					"first",
					"second",
					"third",
					"fourth",
					"fifth",
					"sixth",
					"seventh",
					"eighth",
					"ninth",
					"tenth",
				},
				word = false,
				cyclic = true,
			})

			local weekdays = augend.constant.new({
				elements = {
					"Monday",
					"Tuesday",
					"Wednesday",
					"Thursday",
					"Friday",
					"Saturday",
					"Sunday",
				},
				word = true,
				cyclic = true,
			})

			local months = augend.constant.new({
				elements = {
					"January",
					"February",
					"March",
					"April",
					"May",
					"June",
					"July",
					"August",
					"September",
					"October",
					"November",
					"December",
				},
				word = true,
				cyclic = true,
			})

			local capitalized_boolean = augend.constant.new({
				elements = {
					"True",
					"False",
				},
				word = true,
				cyclic = true,
			})

			return {
				dials_by_ft = {
					css = "css",
					vue = "vue",
					javascript = "typescript",
					typescript = "typescript",
					typescriptreact = "typescript",
					javascriptreact = "typescript",
					json = "json",
					lua = "lua",
					markdown = "markdown",
					sass = "css",
					scss = "css",
					python = "python",
				},
				groups = {
					default = {
						augend.integer.alias.decimal,
						augend.constant.new({ elements = { "public", "private" }, cyclic = true }),
						augend.integer.alias.decimal_int,
						augend.integer.alias.hex,
						augend.date.alias["%Y/%m/%d"],
						ordinal_numbers,
						weekdays,
						months,
						capitalized_boolean,
						augend.constant.alias.bool,
						logical_alias,
					},
					vue = {
						augend.constant.new({ elements = { "let", "const" } }),
						augend.hexcolor.new({ case = "lower" }),
						augend.hexcolor.new({ case = "upper" }),
					},
					typescript = {
						augend.constant.new({ elements = { "let", "const" } }),
					},
					css = {
						augend.hexcolor.new({
							case = "lower",
						}),
						augend.hexcolor.new({
							case = "upper",
						}),
					},
					markdown = {
						augend.constant.new({
							elements = { "[ ]", "[x]" },
							word = false,
							cyclic = true,
						}),
						augend.misc.alias.markdown_header,
					},
					json = {
						augend.semver.alias.semver, -- versioning (v1.1.2)
					},
					lua = {
						augend.constant.new({
							elements = { "and", "or" },
							word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
							cyclic = true, -- "or" is incremented into "and".
						}),
					},
					python = {
						augend.constant.new({
							elements = { "and", "or" },
						}),
					},
				},
			}
		end,
		config = function(_, opts)
			-- copy defaults to each group
			for name, group in pairs(opts.groups) do
				if name ~= "default" then
					vim.list_extend(group, opts.groups.default)
				end
			end
			require("dial.config").augends:register_group(opts.groups)
			vim.g.dials_by_ft = opts.dials_by_ft
		end,
	},
}
