local M = {}

function M.cowboy()
	local ok = true
	for _, key in ipairs({ "h", "j", "k", "l" }) do
		local count = 0
		local timer = vim.loop.new_timer()
		vim.keymap.set("n", key, function()
			if vim.v.count > 0 then
				count = 0
			end
			if count >= 10 and vim.bo.buftype ~= "nofile" then
				ok = pcall(vim.notify, "Hold it there!", vim.log.levels.WARN, {
					icon = "🤠",
					id = "cowboy",
					keep = function()
						return count >= 10
					end,
				})
				if not ok then
					return key
				end
			else
				count = count + 1
				if timer:is_active() then
					timer:stop()
				end
				timer:start(2000, 0, function()
					count = 0
				end)
				return key
			end
		end, { expr = true, silent = true })
	end
end

return M
