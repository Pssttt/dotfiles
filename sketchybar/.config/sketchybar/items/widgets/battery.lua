local constants = require("constants")
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette

local battery = sbar.add("item", constants.items.BATTERY, settings.widget(palette.green))
battery:set({
  position = "right",
  update_freq = 60,
  popup = popup.container("right"),
})

-- Card ---------------------------------------------------------------------
local header = popup.header(battery, { name = "battery.card.header", icon = settings.icons.text.battery._100, title = "Battery", color = palette.green })
local meter = popup.meter(battery, { name = "battery.card.meter", color = palette.green })
popup.divider(battery)
local statusRow = popup.row(battery, { name = "battery.card.status", key = "Status" })
local timeRow = popup.row(battery, { name = "battery.card.time", key = "Time left" })
local sourceRow = popup.row(battery, { name = "battery.card.source", key = "Power" })
local cyclesRow = popup.row(battery, { name = "battery.card.cycles", key = "Cycles" })
local healthRow = popup.row(battery, { name = "battery.card.health", key = "Health" })
popup.button(battery, {
  name = "battery.card.settings",
  icon = settings.icons.text.gear,
  label = "Battery settings…",
  color = palette.subtext,
  on_click = function()
    battery:set({ popup = { drawing = false } })
    sbar.exec("open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'")
  end,
})

-- State --------------------------------------------------------------------
local function levelStyle(charge, charging)
  local icons = settings.icons.text.battery
  if charging then return icons.charging, palette.yellow end
  if charge > 80 then return icons._100, palette.green end
  if charge > 60 then return icons._75, palette.green end
  if charge > 40 then return icons._50, palette.green end
  if charge > 30 then return icons._50, palette.yellow end
  if charge > 20 then return icons._25, palette.peach end
  return icons._0, palette.red
end

local function parse(batteryInfo)
  local charge = tonumber(batteryInfo:match("(%d+)%%")) or 0
  local onAC = batteryInfo:find("AC Power") ~= nil
  local state = batteryInfo:match("%d+%%; ([^;]+);") or "unknown"
  local remaining = batteryInfo:match("(%d+:%d+) remaining")
  return charge, onAC, state, remaining
end

local function updateBar()
  sbar.exec("pmset -g batt", function(batteryInfo)
    local charge, onAC = parse(batteryInfo)
    local icon, color = levelStyle(charge, onAC)
    local lead = charge < 10 and "0" or ""

    battery:set({
      icon = { string = icon, color = color },
      label = { string = lead .. charge .. "%" },
    })
  end)
end

local function updateCard()
  sbar.exec("pmset -g batt", function(batteryInfo)
    local charge, onAC, state, remaining = parse(batteryInfo)
    local icon, color = levelStyle(charge, onAC)

    header:set({ icon = { string = icon, color = color }, label = { string = "Battery  " .. charge .. "%" } })
    popup.set_meter(meter, charge, color)
    statusRow:set({ label = { string = state:gsub("^%l", string.upper) } })
    timeRow:set({ label = { string = remaining and (remaining .. " h") or "—" } })
    sourceRow:set({ label = { string = onAC and "Adapter" or "Battery", color = onAC and palette.yellow or palette.text } })
  end)

  -- slower, only fetched while the card is open
  sbar.exec("system_profiler SPPowerDataType", function(info)
    local cycles = info:match("Cycle Count: (%d+)") or "—"
    local condition = info:match("Condition: ([^\n]+)") or "—"
    local capacity = info:match("Maximum Capacity: (%d+%%)")
    cyclesRow:set({ label = { string = cycles } })
    healthRow:set({
      label = {
        string = capacity and (condition .. " · " .. capacity) or condition,
        color = condition == "Normal" and palette.green or palette.peach,
      },
    })
  end)
end

battery:subscribe({ "routine", "forced", "power_source_change", "system_woke" }, updateBar)

battery:subscribe("mouse.clicked", function()
  local shouldDraw = battery:query().popup.drawing == "off"
  battery:set({ popup = { drawing = shouldDraw } })
  if shouldDraw then updateCard() end
end)

battery:subscribe("mouse.exited.global", function()
  battery:set({ popup = { drawing = false } })
end)
