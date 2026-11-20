local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

local spaces = {}
local focusedSpace = nil

local swapWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local currentWorkspaceWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Modify this file with Visual Studio Code - at least vim does have problems with the icons
-- copy "Icons" from the nerd fonts cheat sheet and replace icon and name accordingly below
-- https://www.nerdfonts.com/cheat-sheet
-- Each workspace has its own Catppuccin accent (Hyprland-style rainbow).
local spaceConfigs <const> = {
	["1"] = { icon = "󰌾", name = "Secrets", color = palette.red },
	["2"] = { icon = "󰊻", name = "Teams", color = palette.lavender },
	["3"] = { icon = "\u{f472}", name = "Database", color = palette.peach },
	["B"] = { icon = "󰖟", name = "Browser", color = palette.sapphire },
	["C"] = { icon = "\u{eac4}", name = "Code", color = palette.mauve },
	["D"] = { icon = "\u{f1ff}", name = "Discord", color = palette.blue },
	["M"] = { icon = "\u{f001}", name = "Music", color = palette.green },
	["N"] = { icon = "󱞁", name = "Notes", color = palette.yellow },
	["T"] = { icon = "\u{ea85}", name = "Terminal", color = palette.teal },
}

local function configFor(workspaceName)
	return spaceConfigs[workspaceName]
		or { icon = workspaceName, name = workspaceName, color = palette.subtext }
end

local function styleWorkspace(item, config, isSelected)
	item:set({
		icon = { color = isSelected and palette.crust or config.color },
		label = {
			color = palette.crust,
			width = isSelected and "dynamic" or 0,
		},
		background = { color = isSelected and config.color or settings.colors.transparent },
	})
end

local function selectCurrentWorkspace(focusedWorkspaceName)
	focusedSpace = constants.items.SPACES .. "." .. (focusedWorkspaceName or "")
	sbar.animate("tanh", 15, function()
		for sid, space in pairs(spaces) do
			styleWorkspace(space.item, space.config, sid == focusedSpace)
		end
	end)

	sbar.trigger(constants.events.UPDATE_WINDOWS)
end

local function findAndSelectCurrentWorkspace()
	sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedWorkspaceOutput)
		local focusedWorkspaceName = focusedWorkspaceOutput:match("[^\r\n]+")
		selectCurrentWorkspace(focusedWorkspaceName)
	end)
end

local function addWorkspaceItem(workspaceName)
	local spaceName = constants.items.SPACES .. "." .. workspaceName
	local spaceConfig = configFor(workspaceName)

	local item = sbar.add("item", spaceName, {
		padding_left = 2,
		padding_right = 2,
		label = {
			width = 0,
			padding_left = 0,
			padding_right = 10,
			string = spaceConfig.name,
			font = { style = settings.fonts.styles.bold },
		},
		icon = {
			string = spaceConfig.icon,
			color = spaceConfig.color,
			padding_left = 9,
			padding_right = 9,
		},
		background = {
			drawing = true,
			color = settings.colors.transparent,
			height = 22,
			corner_radius = 7,
		},
		click_script = "aerospace workspace " .. workspaceName,
	})

	spaces[spaceName] = { item = item, config = spaceConfig }

	-- Hover peeks the workspace name
	item:subscribe("mouse.entered", function()
		if spaceName == focusedSpace then return end
		sbar.animate("tanh", 20, function()
			item:set({
				label = { width = "dynamic", color = spaceConfig.color },
				background = { color = settings.colors.palette.surface0 },
			})
		end)
	end)

	item:subscribe("mouse.exited", function()
		if spaceName == focusedSpace then return end
		sbar.animate("tanh", 20, function()
			styleWorkspace(item, spaceConfig, false)
		end)
	end)
end

local function createWorkspaces()
	sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
		for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
			addWorkspaceItem(workspaceName)
		end

		local container = settings.island()
		container.background.padding_left = 3
		container.background.padding_right = 3
		sbar.add("bracket", "island.spaces", { "/" .. constants.items.SPACES .. "\\..*/" }, container)

		-- gap between the spaces island and the apps island
		sbar.add("item", constants.items.SPACES .. "_gap", { width = settings.dimens.padding.item })

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

createWorkspaces()
