local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette
local ISLAND <const> = "island.front_apps"

-- Dock-style island: app icons only, the focused app also shows its name.
local frontApps = {}

local frontAppWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local function selectFocusedWindow(frontAppName)
	sbar.animate("tanh", 15, function()
		for appName, app in pairs(frontApps) do
			local isSelected = appName == frontAppName
			app:set({
				icon = { color = isSelected and palette.mauve or palette.overlay },
				label = {
					color = palette.text,
					width = isSelected and "dynamic" or 0,
				},
			})
		end
	end)
end

local function updateWindows(windows)
	sbar.remove("/" .. constants.items.FRONT_APPS .. "\\..*/")
	sbar.remove(ISLAND)

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
				padding_left = 0,
				padding_right = 0,
				icon = {
					string = icon,
					font = settings.fonts.icons(15),
					color = palette.overlay,
					padding_left = 8,
					padding_right = 8,
				},
				label = {
					string = windowName,
					width = 0,
					padding_left = 0,
					padding_right = 10,
					font = { style = settings.fonts.styles.bold },
				},
				click_script = "aerospace focus --window-id " .. windowId,
			})

			frontApps[windowName]:subscribe(constants.events.FRONT_APP_SWITCHED, function(env)
				selectFocusedWindow(env.INFO)
			end)
		end
	end

	if next(frontApps) ~= nil then
		local container = settings.island()
		container.background.padding_left = 3
		container.background.padding_right = 3
		sbar.add("bracket", ISLAND, { "/" .. constants.items.FRONT_APPS .. "\\..*/" }, container)
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
