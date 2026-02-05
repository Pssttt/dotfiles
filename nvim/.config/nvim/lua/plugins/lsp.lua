return {
	-- tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
			})
		end,
	},

	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				eslint = {
					settings = {
						run = "onSave",
					},
				},
				cssls = {},
				tailwindcss = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(
							"tailwind.config.js",
							"tailwind.config.ts",
							"postcss.config.js"
						)(fname)
					end,
				},
				vtsls = {
					settings = {
						typescript = {
							inlayHints = {
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = false },
								variableTypes = { enabled = false },
								propertyDeclarationTypes = { enabled = false },
								functionLikeReturnTypes = { enabled = false },
								enumMemberValues = { enabled = false },
							},
						},
						javascript = {
							inlayHints = {
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = false },
								variableTypes = { enabled = false },
								propertyDeclarationTypes = { enabled = false },
								functionLikeReturnTypes = { enabled = false },
								enumMemberValues = { enabled = false },
							},
						},
					},
				},
				html = {},
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
						},
					},
				},
				lua_ls = {
					enabled = false,
					single_file_support = true,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {
									-- "--log-level=trace",
								},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								-- enable = false,
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},
			},
			setup = {},
		},
	},
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts)
			local lint = require("lint")

			lint.linters_by_ft.env = {}

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { ".env", "*.env" },
				callback = function()
					vim.bo.filetype = "env"
				end,
			})
		end,
	},
}
