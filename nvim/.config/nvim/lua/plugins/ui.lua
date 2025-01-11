return {
    {
        "folke/noice.nvim",
        opts = function(_, opts)
            table.insert(opts.routes, {
                filter = {
                    event = "notify",
                    find = "No information available",
                },
                opts = { skip = true },
            })
            local focused = true
            vim.api.nvim_create_autocmd("FocusGained", {
                callback = function()
                    focused = true
                end,
            })
            vim.api.nvim_create_autocmd("FocusLost", {
                callback = function()
                    focused = false
                end,
            })
            table.insert(opts.routes, 1, {
                filter = {
                    cond = function()
                        return not focused
                    end,
                },
                view = "notify_send",
                opts = { stop = false },
            })

            opts.commands = {
                all = {
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {},
                },
            }

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(event)
                    vim.schedule(function()
                        require("noice.text.markdown").keys(event.buf)
                    end)
                end,
            })

            opts.presets.lsp_doc_border = true
        end,
    },
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 3000,
        },
    },

    {
        "snacks.nvim",
        opts = {
            scroll = {
                enabled = false,
            },
        },
        keys = {},
    },

    -- bufferline
    {
        "akinsho/nvim-bufferline.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Tab" },
        },
        opts = {
            options = {
                mode = "tabs",
                show_close_icon = false,
                show_buffer_close_icons = false,
            },
        },
    },

    {},
}
