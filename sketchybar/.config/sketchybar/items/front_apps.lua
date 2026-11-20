local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

-- Center group (Waybar "window" module): apps on the current workspace,
-- the focused one shows its name.
local frontApps = {}

local frontAppWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local function selectFocusedWindow(frontAppName)
	sbar.animate("tanh", 12, function()
		for appName, app in pairs(frontApps) do
			local isSelected = appName == frontAppName
			app:set({
				icon = { color = isSelected and palette.mauve or palette.overlay },
				label = { width = isSelected and "dynamic" or 0 },
			})
		end
	end)
end

local function updateWindows(windows)
	sbar.remove("/" .. constants.items.FRONT_APPS .. "\\..*/")
	sbar.remove("group.center")

	frontApps = {}
	local foundWindows = {}
	for window in string.gmatch(windows, "[^\n]+") do
		table.insert(foundWindows, window)
	end

	for i = #foundWindows, 1, -1 do
		local parsedWindow = {}
		for key, value in string.gmatch(foundWindows[i], "(%w+)=([%w%s]+)") do
			parsedWindow[key] = value
		end

		local windowId = parsedWindow["id"]
		local windowName = parsedWindow["name"]

		if windowName and not frontApps[windowName] then
			local icon = settings.icons.apps[windowName] or settings.icons.apps["Default"] or ":default:"

			frontApps[windowName] = sbar.add("item", constants.items.FRONT_APPS .. "." .. windowName, {
				position = "center",
				padding_left = 4,
				padding_right = 4,
				icon = {
					string = icon,
					font = settings.fonts.icons(14),
					color = palette.overlay,
					padding_left = 6,
					padding_right = 6,
				},
				label = {
					string = windowName,
					width = 0,
					color = palette.text,
					padding_left = 0,
					padding_right = 8,
					font = { style = settings.fonts.styles.bold },
				},
				background = { drawing = false },
				click_script = "aerospace focus --window-id " .. windowId,
			})

			frontApps[windowName]:subscribe(constants.events.FRONT_APP_SWITCHED, function(env)
				selectFocusedWindow(env.INFO)
			end)
		end
	end

	if next(frontApps) ~= nil then
		sbar.add("bracket", "group.center", { "/" .. constants.items.FRONT_APPS .. "\\..*/" }, settings.group())
	end

	sbar.exec(constants.aerospace.GET_CURRENT_WINDOW, function(frontAppName)
		selectFocusedWindow((frontAppName:gsub("[\n\r]", "")))
	end)
end

local function getWindows()
	sbar.exec(constants.aerospace.LIST_WINDOWS, updateWindows)
end

frontAppWatcher:subscribe(constants.events.UPDATE_WINDOWS, function()
	getWindows()
end)

getWindows()
