local M = {}

function M.generateEnvExample()
	local infile = ".env"
	local outfile = ".env.example"
	local lines = {}

	local f = io.open(infile, "r")
	if not f then
		vim.notify(".env file not found", vim.log.levels.ERROR)
		return
	end

	for line in f:lines() do
		local key = line:match("^%s*([A-Z_][A-Z0-9_]*)%s*=")
		if key then
			table.insert(lines, key .. "=YOUR_" .. key)
		end
	end
	f:close()

	local out = io.open(outfile, "w")
	for _, line in ipairs(lines) do
		out:write(line .. "\n")
	end
	out:close()

	vim.notify(".env.example generated!", vim.log.levels.INFO)
end

return M
