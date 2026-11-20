local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette
local underline <const> = settings.dimens.graphics.underline

local spaces = {}
local occupied = {}
local focusedSpace = nil

local swapWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local currentWorkspaceWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Icons are written as \u{...} escapes so editors and tools can't strip the
-- Nerd Font private-use glyphs. Look codes up at https://www.nerdfonts.com/cheat-sheet
local spaceConfigs <const> = {
	["1"] = { icon = "\u{f033e}", name = "Secrets" },
	["2"] = { icon = "\u{f02bb}", name = "Teams" },
	["3"] = { icon = "\u{f472}", name = "Database" },
	["B"] = { icon = "\u{f059f}", name = "Browser" },
	["C"] = { icon = "\u{eac4}", name = "Code" },
	["D"] = { icon = "\u{f1ff}", name = "Discord" },
	["M"] = { icon = "\u{f001}", name = "Music" },
	["N"] = { icon = "\u{f1781}", name = "Notes" },
	["T"] = { icon = "\u{ea85}", name = "Terminal" },
}

local function configFor(workspaceName)
	return spaceConfigs[workspaceName] or { icon = workspaceName, name = workspaceName }
end

-- active: bright icon + name + mauve underline
-- occupied: muted icon, empty: dim icon
local function styleWorkspace(space, isSelected)
	local iconColor = palette.surface2
	if isSelected then
		iconColor = palette.text
	elseif occupied[space.workspace] then
		iconColor = palette.subtext
	end

	space.item:set({
		icon = { color = iconColor },
		label = { width = isSelected and "dynamic" or 0 },
		background = { color = isSelected and palette.mauve or settings.colors.transparent },
	})
end

local function restyleAll()
	sbar.animate("tanh", 12, function()
		for sid, space in pairs(spaces) do
			styleWorkspace(space, sid == focusedSpace)
		end
	end)
end

-- One aerospace call tells us which workspaces have windows
local function refreshOccupied()
	sbar.exec("aerospace list-windows --all --format '%{workspace}'", function(output)
		occupied = {}
		for name in output:gmatch("[^\r\n]+") do
			occupied[name] = true
		end
		restyleAll()
	end)
end

local function selectCurrentWorkspace(focusedWorkspaceName)
	focusedSpace = constants.items.SPACES .. "." .. (focusedWorkspaceName or "")
	restyleAll()
	refreshOccupied()
	sbar.trigger(constants.events.UPDATE_WINDOWS)
end

local function findAndSelectCurrentWorkspace()
	sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedWorkspaceOutput)
		selectCurrentWorkspace(focusedWorkspaceOutput:match("[^\r\n]+"))
	end)
end

local function addWorkspaceItem(workspaceName)
	local spaceName = constants.items.SPACES .. "." .. workspaceName
	local spaceConfig = configFor(workspaceName)

	local item = sbar.add("item", spaceName, {
		padding_left = 1,
		padding_right = 1,
		icon = {
			string = spaceConfig.icon,
			color = palette.surface2,
			padding_left = 9,
			padding_right = 9,
		},
		label = {
			string = spaceConfig.name,
			width = 0,
			color = palette.text,
			padding_left = 0,
			padding_right = 10,
			font = { style = settings.fonts.styles.bold },
		},
		-- the "background" is drawn as a thin underline on the bar's bottom edge
		background = {
			drawing = true,
			color = settings.colors.transparent,
			height = underline.height,
			corner_radius = 1,
			y_offset = underline.y_offset,
		},
		click_script = "aerospace workspace " .. workspaceName,
	})

	local space = { item = item, workspace = workspaceName }
	spaces[spaceName] = space

	item:subscribe("mouse.entered", function()
		if spaceName == focusedSpace then return end
		sbar.animate("tanh", 12, function()
			item:set({
				icon = { color = palette.lavender },
				background = { color = palette.surface2 },
			})
		end)
	end)

	item:subscribe("mouse.exited", function()
		if spaceName == focusedSpace then return end
		sbar.animate("tanh", 12, function()
			styleWorkspace(space, false)
		end)
	end)
end

local function createWorkspaces()
	sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
		for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
			addWorkspaceItem(workspaceName)
		end

		settings.separator(constants.items.SPACES .. "_separator")

		findAndSelectCurrentWorkspace()
	end)
end

swapWatcher:subscribe(constants.events.SWAP_MENU_AND_SPACES, function(env)
	local isShowingSpaces = env.isShowingMenu == "off" and true or false
	sbar.set("/" .. constants.items.SPACES .. "\\..*/", { drawing = isShowingSpaces })
	sbar.set(constants.items.SPACES .. "_separator", { drawing = isShowingSpaces })
end)

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	selectCurrentWorkspace(env.FOCUSED_WORKSPACE)
end)

-- windows opening/closing changes which workspaces are occupied
currentWorkspaceWatcher:subscribe(constants.events.FRONT_APP_SWITCHED, refreshOccupied)

createWorkspaces()
