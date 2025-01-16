local wezterm = require("wezterm")
local config = wezterm.config_builder()
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]

custom.background = "#191724"
custom.cursor_bg = "#bac2de"

config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 1000 }
config.keys = {
	-- splitting
	{ mods = "LEADER", key = "s", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = "v", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = "LeftArrow", action = wezterm.action.ActivatePaneDirection("Left") },
	{ mods = "SUPER | SHIFT", key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
	{ mods = "LEADER", key = "RightArrow", action = wezterm.action.ActivatePaneDirection("Right") },
	{ mods = "SUPER | SHIFT", key = "l", action = wezterm.action.ActivatePaneDirection("Right") },
	{ mods = "LEADER", key = "UpArrow", action = wezterm.action.ActivatePaneDirection("Up") },
	{ mods = "SUPER | SHIFT", key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
	{ mods = "LEADER", key = "DownArrow", action = wezterm.action.ActivatePaneDirection("Down") },
	{ mods = "SUPER | SHIFT", key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
	{ mods = "SUPER | SHIFT", key = "p", action = wezterm.action.ActivateTabRelative(-1) },
	{ mods = "SUPER | SHIFT", key = "n", action = wezterm.action.ActivateTabRelative(1) },
	{ mods = "SUPER | SHIFT", key = "x", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ mods = "SUPER | SHIFT", key = "c", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{
		mods = "LEADER",
		key = "r",
		action = wezterm.action.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
	},
	{
		mods = "LEADER",
		key = "m",
		action = wezterm.action.ActivateKeyTable({ name = "move_tab", one_shot = false }),
	},
	{
		mods = "LEADER",
		key = "!",
		action = wezterm.action_callback(function(_win, pane)
			local _tab, _ = pane:move_to_new_tab()
		end),
	},
}

for i = 1, 9 do
	-- ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

config.key_tables = {
	resize_pane = {
		{ key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "H", action = wezterm.action.MoveTabRelative(-1) },
		{ key = "L", action = wezterm.action.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

config.color_scheme = "Psstuccin"
config.color_schemes = {
	["Psstuccin"] = custom,
}
config.font = wezterm.font({ family = "Hack Nerd Font" })
config.font_size = 16
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 180
config.initial_rows = 45
config.line_height = 1.2
config.macos_window_background_blur = 40
config.send_composed_key_when_left_alt_is_pressed = true -- MacOS Fix
config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.90
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.window_padding = {
	top = "0.5cell",
}

return config
