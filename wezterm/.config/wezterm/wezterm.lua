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

local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["btm"] = "",
	["psql"] = "󱤢",
	["usql"] = "󱤢",
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["ssh"] = wezterm.nerdfonts.fa_exchange,
	["ssh-add"] = wezterm.nerdfonts.fa_exchange,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["node"] = wezterm.nerdfonts.mdi_hexagon,
	["go"] = wezterm.nerdfonts.seti_go,
	["python3"] = wezterm.nerdfonts.dev_python,
	["Python"] = wezterm.nerdfonts.dev_python,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["git"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
	["fish"] = wezterm.nerdfonts.md_fish,
	["spotify_player"] = wezterm.nerdfonts.fa_spotify,
	["lazygit"] = wezterm.nerdfonts.dev_git,
}

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane and tab.active_pane.current_working_dir or { file_path = "" }
	local HOME_DIR = os.getenv("HOME")

	return current_dir.file_path == HOME_DIR and "~" or string.gsub(current_dir.file_path, "(.*[/\\])(.*)", "%2")
end

local function get_process(tab)
	if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
		return nil
	end

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	return process_icons[process_name] or string.format("[%s]", process_name)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, hover, max_width)
	local has_unseen_output = false
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				has_unseen_output = true
				break
			end
		end
	end

	local tab_index = tab.tab_index + 1
	local number_prefix = string.format("%d: ", tab_index)

	local cwd = wezterm.format({
		{ Text = get_current_working_dir(tab) },
	})

	local process = get_process(tab)
	local title = process and string.format(" %s%s (%s) ", number_prefix, process, cwd)
		or string.format("%s[?] ", number_prefix)

	if has_unseen_output then
		return {
			{ Foreground = { Color = "#28719c" } },
			{ Text = title },
		}
	end

	return {
		{ Text = title },
	}
end)

return config
