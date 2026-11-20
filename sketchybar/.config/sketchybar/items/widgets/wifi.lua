local constants = require("constants")
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette
local wifiIcons <const> = settings.icons.text.wifi
local VPN_ICON <const> = wifiIcons.vpn or "\u{f0991}" -- nf-md-vpn

sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/bridge/network_load/bin/network_load en0 network_update 2.0")

-- Bar items: wifi icon + stacked upload/download rates ------------------------
local function rateItem(name, icon, color, yOffset, width)
	return sbar.add("item", name, {
		position = "right",
		width = width,
		padding_left = 0,
		padding_right = settings.dimens.padding.widget,
		y_offset = yOffset,
		icon = {
			string = icon,
			color = color,
			padding_left = 0,
			padding_right = 2,
			font = { style = settings.fonts.styles.bold, size = 9.0 },
		},
		label = {
			string = "??? Bps",
			color = color,
			padding_left = 0,
			padding_right = 0,
			font = { family = settings.fonts.numbers, style = settings.fonts.styles.bold, size = 9.0 },
		},
		background = { drawing = false },
	})
end

local wifiUp = rateItem(constants.items.WIFI .. ".up", wifiIcons.upload, palette.peach, 5, 0)
local wifiDown = rateItem(constants.items.WIFI .. ".down", wifiIcons.download, palette.blue, -5, nil)

local wifiStyle = settings.widget(palette.blue)
local wifi = sbar.add("item", constants.items.WIFI .. ".padding", {
	position = "right",
	padding_left = settings.dimens.padding.widget,
	padding_right = 0,
	icon = wifiStyle.icon,
	label = { drawing = false },
	background = { drawing = false },
})

local wifiBracket = sbar.add("bracket", constants.items.WIFI .. ".bracket", {
	wifi.name,
	wifiUp.name,
	wifiDown.name,
}, {
	background = { drawing = false },
	popup = popup.container("right"),
})

-- Card ---------------------------------------------------------------------
local header = popup.header(wifiBracket, {
	name = constants.items.WIFI .. ".card.header",
	icon = wifiIcons.connected,
	title = "Wi-Fi",
	color = palette.blue,
})
popup.divider(wifiBracket)
local ipRow = popup.row(wifiBracket, { name = constants.items.WIFI .. ".card.ip", key = "IP" })
local routerRow = popup.row(wifiBracket, { name = constants.items.WIFI .. ".card.router", key = "Router" })
local hostnameRow = popup.row(wifiBracket, { name = constants.items.WIFI .. ".card.hostname", key = "Hostname" })
local vpnRow = popup.row(wifiBracket, { name = constants.items.WIFI .. ".card.vpn", key = "VPN" })
popup.button(wifiBracket, {
	name = constants.items.WIFI .. ".card.settings",
	icon = settings.icons.text.gear,
	label = "Wi-Fi settings…",
	color = palette.subtext,
	on_click = function()
		wifiBracket:set({ popup = { drawing = false } })
		sbar.exec("open 'x-apple.systempreferences:com.apple.wifi-settings-extension'")
	end,
})

-- Rates --------------------------------------------------------------------
wifiUp:subscribe("network_update", function(env)
	local upColor = (env.upload == "000 Bps") and palette.surface2 or palette.peach
	local downColor = (env.download == "000 Bps") and palette.surface2 or palette.blue

	wifiUp:set({ icon = { color = upColor }, label = { string = env.upload, color = upColor } })
	wifiDown:set({ icon = { color = downColor }, label = { string = env.download, color = downColor } })
end)

-- Connection state ---------------------------------------------------------
wifi:subscribe({ "wifi_change", "system_woke", "forced" }, function()
	wifi:set({ icon = { string = wifiIcons.disconnected, color = palette.red } })

	sbar.exec("ipconfig getifaddr en0", function(ip)
		if ip == "" then return end
		wifi:set({ icon = { string = wifiIcons.connected, color = palette.blue } })

		sbar.exec([[sleep 2; scutil --nwi | grep -m1 'utun' | awk '{ print $1 }']], function(vpn)
			if vpn ~= "" then
				wifi:set({ icon = { string = VPN_ICON, color = palette.green } })
			end
		end)
	end)
end)

-- Card contents ------------------------------------------------------------
local function trim(value)
	return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function fill(row, command)
	sbar.exec(command, function(result)
		local value = trim(result)
		row:set({ label = { string = value ~= "" and value or "—", color = palette.text } })
	end)
end

local function updateCard()
	sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
		local ssid = trim(result)
		header:set({ label = { string = ssid ~= "" and ssid or "Wi-Fi" } })
	end)
	fill(ipRow, "ipconfig getifaddr en0")
	fill(routerRow, "networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'")
	fill(hostnameRow, "scutil --get LocalHostName")
	sbar.exec("scutil --nwi | grep -m1 'utun' | awk '{ print $1 }'", function(vpn)
		local connected = trim(vpn) ~= ""
		vpnRow:set({ label = { string = connected and "Connected" or "Off", color = connected and palette.green or palette.overlay } })
	end)
end

local function hideDetails()
	wifiBracket:set({ popup = { drawing = false } })
end

local function toggleDetails()
	local shouldDraw = wifiBracket:query().popup.drawing == "off"
	wifiBracket:set({ popup = { drawing = shouldDraw } })
	if shouldDraw then updateCard() end
end

-- Click a row to copy its value
local function copyOnClick(row)
	row:subscribe("mouse.clicked", function()
		local value = row:query().label.value
		if value == "—" or value == "Copied" then return end
		sbar.exec("printf '%s' '" .. value:gsub("'", "") .. "' | pbcopy")
		row:set({ label = { string = "Copied", color = palette.green } })
		sbar.delay(1, function()
			row:set({ label = { string = value, color = palette.text } })
		end)
	end)
end

copyOnClick(ipRow)
copyOnClick(routerRow)
copyOnClick(hostnameRow)

wifiUp:subscribe("mouse.clicked", toggleDetails)
wifiDown:subscribe("mouse.clicked", toggleDetails)
wifi:subscribe("mouse.clicked", toggleDetails)
wifi:subscribe("mouse.exited.global", hideDetails)
