local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

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

-- Hyprland-style indicators:
-- active: stretched mauve pill, occupied: bright icon, empty: dim icon
local function styleWorkspace(space, isSelected)
	local iconColor = palette.surface2
	if isSelected then
		iconColor = palette.crust
	elseif occupied[space.workspace] then
		iconColor = palette.text
	end

	space.item:set({
		icon = {
			color = iconColor,
			padding_left = isSelected and 18 or 8,
			padding_right = isSelected and 18 or 8,
		},
		background = { color = isSelected and palette.mauve or settings.colors.transparent },
	})
end

local function restyleAll()
	sbar.animate("sin", 18, function()
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
			padding_left = 8,
			padding_right = 8,
		},
		label = { drawing = false },
		background = {
			drawing = true,
			color = settings.colors.transparent,
			height = 22,
			corner_radius = 11,
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
				background = { color = palette.surface0 },
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
		settings.spacer(constants.items.SPACES .. "_end", "left", 5)

		-- left group: logo, menu toggle, app menus and workspaces in one box
		-- (members listed by name: regex members proved unreliable here)
		local members = { "power", constants.items.MENU_TOGGLE }
		for index = 1, 15 do
			table.insert(members, constants.items.MENU .. "." .. index)
		end
		for spaceName in pairs(spaces) do
			table.insert(members, spaceName)
		end
		table.insert(members, constants.items.SPACES .. "_end")
		sbar.add("bracket", "group.left", members, settings.group())

		findAndSelectCurrentWorkspace()
	end)
end

swapWatcher:subscribe(constants.events.SWAP_MENU_AND_SPACES, function(env)
	local isShowingSpaces = env.isShowingMenu == "off" and true or false
	sbar.set("/" .. constants.items.SPACES .. "\\..*/", { drawing = isShowingSpaces })
end)

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	selectCurrentWorkspace(env.FOCUSED_WORKSPACE)
end)

-- windows opening/closing changes which workspaces are occupied
currentWorkspaceWatcher:subscribe(constants.events.FRONT_APP_SWITCHED, refreshOccupied)

createWorkspaces()
