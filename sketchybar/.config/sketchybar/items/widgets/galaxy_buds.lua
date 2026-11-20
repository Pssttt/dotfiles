local constants = require("constants")
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette

local CLI_PATH <const> = "'/Applications/Galaxy Buds Manager.app/Contents/MacOS/Galaxy Buds Manager'"
local QUERY_CMD <const> = CLI_PATH .. [[ device -G -j 2>/dev/null | jq -r 'if .BatteryLeft != null then "\(.BatteryLeft)|\(.BatteryRight)|\(.BatteryCase)|\(.WearStateLeft)|\(.WearStateRight)|\(.Name)" else empty end' 2>/dev/null]]
local NOISE_MODE_CMD <const> = [[sqlite3 -batch -list "$HOME/Library/Application Support/GalaxyBudsClient/battery_stats_b04a6ad29ade.db" "SELECT NoiseControlMode FROM Records WHERE NoiseControlMode IS NOT NULL ORDER BY Id DESC LIMIT 1;" 2>/dev/null]]

local currentNoiseMode = -1

-- Noise mode map: 0=Off, 1=ANC, 2=Ambient
local noiseModes = {
  [0] = { icon = "󰋑", name = "Off",     color = settings.colors.grey   },
  [1] = { icon = "󰋋", name = "ANC",     color = settings.colors.blue   },
  [2] = { icon = "󰂰", name = "Ambient", color = settings.colors.yellow },
}

local galaxyBuds = sbar.add("item", constants.items.GALAXY_BUDS, settings.widget(settings.colors.palette.teal))
galaxyBuds:set({
  position = "right",
  update_freq = 30,
  drawing = false,
  icon = { string = settings.icons.text.earbuds or "󰥰" },
  label = { string = "" },
})

galaxyBuds:set({ popup = popup.container("right") })

-- Card ---------------------------------------------------------------------
local GB <const> = constants.items.GALAXY_BUDS
local budsTitle = popup.header(galaxyBuds, {
  name = GB .. ".card.header",
  icon = settings.icons.text.earbuds,
  title = "Galaxy Buds",
  color = palette.teal,
})
popup.divider(galaxyBuds)
local budsLeft = popup.row(galaxyBuds, { name = GB .. ".card.left", key = "Left" })
local budsRight = popup.row(galaxyBuds, { name = GB .. ".card.right", key = "Right" })
local budsCase = popup.row(galaxyBuds, { name = GB .. ".card.case", key = "Case" })
popup.divider(galaxyBuds)
local budsNoise = popup.button(galaxyBuds, {
  name = GB .. ".card.noise",
  icon = noiseModes[0].icon,
  color = palette.blue,
  label = "Noise control",
})
local budsManager = popup.button(galaxyBuds, {
  name = GB .. ".card.manager",
  icon = settings.icons.text.gear,
  color = palette.subtext,
  label = "Open Buds Manager",
})

local function updateNoiseDisplay(mode)
  local m = noiseModes[mode]
  if not m then return end
  currentNoiseMode = mode

  budsNoise:set({
    icon = { string = m.icon, color = m.color },
    label = { string = "Noise control  " .. m.name },
  })
end

local function updateGalaxyBuds()
  sbar.exec(QUERY_CMD, function(result)
    local left, right, case, wearL, wearR, name = result:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|\r\n]+)")

    if left and right then
      local nLeft = tonumber(left) or 0
      local nRight = tonumber(right) or 0
      local nCase = tonumber(case) or 0

      local batt = 0
      if nLeft > 0 and nRight > 0 then
        batt = math.min(nLeft, nRight)
      else
        batt = math.max(nLeft, nRight)
      end

      local color = settings.colors.palette.teal
      if batt <= 15 then
        color = settings.colors.red
      elseif batt <= 30 then
        color = settings.colors.yellow
      end

      local lead = ""
      if batt < 10 then lead = "0" end

      galaxyBuds:set({
        drawing = true,
        icon = { string = settings.icons.text.earbuds or "󰥰", color = color },
        label = { string = lead .. batt .. "%", drawing = true },
      })

      budsTitle:set({ label = { string = name or "Galaxy Buds" } })
      local function levelColor(value)
        if value <= 15 then return palette.red end
        if value <= 30 then return palette.yellow end
        return palette.text
      end
      budsLeft:set({ label = { string = nLeft .. "%  " .. wearL, color = levelColor(nLeft) } })
      budsRight:set({ label = { string = nRight .. "%  " .. wearR, color = levelColor(nRight) } })
      budsCase:set({ label = { string = (nCase > 0) and (nCase .. "%") or "Closed", color = nCase > 0 and levelColor(nCase) or palette.overlay } })

      sbar.exec(NOISE_MODE_CMD, function(noiseResult)
        local mode = tonumber(noiseResult:match("%d+"))
        if mode then
          updateNoiseDisplay(mode)
        end
      end)
    else
      -- Disconnected: hide entirely from status bar and close popup
      galaxyBuds:set({ drawing = false, popup = { drawing = false } })
    end
  end)
end

-- Left click: toggle popup. Right click: toggle Manager window
galaxyBuds:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec(CLI_PATH .. ' action -e ToggleManagerVisibility')
    return
  end

  local shouldDraw = galaxyBuds:query().popup.drawing == "off"
  galaxyBuds:set({ popup = { drawing = "toggle" } })

  if shouldDraw then
    updateGalaxyBuds()
  end
end)

-- Click cycles: ANC (1) -> Ambient (2) -> Off (0) -> ANC (1)
budsNoise:subscribe("mouse.clicked", function()
  local nextMode
  local action
  if currentNoiseMode == 1 then
    nextMode = 2
    action = "AmbientToggle"
  elseif currentNoiseMode == 2 then
    nextMode = 0
    action = "AmbientToggle"
  else
    nextMode = 1
    action = "AncToggle"
  end

  -- Immediate optimistic UI feedback (no perceptible delay)
  updateNoiseDisplay(nextMode)

  -- Execute action via CLI
  sbar.exec(CLI_PATH .. ' action -e ' .. action)

  -- Verify with database after 0.8s
  sbar.delay(0.8, function()
    sbar.exec(NOISE_MODE_CMD, function(noiseResult)
      local actualMode = tonumber(noiseResult:match("%d+"))
      if actualMode and actualMode ~= currentNoiseMode then
        updateNoiseDisplay(actualMode)
      end
    end)
  end)
end)

-- Manager button click
galaxyBuds:subscribe("mouse.exited.global", function()
  galaxyBuds:set({ popup = { drawing = false } })
end)

budsManager:subscribe("mouse.clicked", function()
  galaxyBuds:set({ popup = { drawing = false } })
  sbar.exec(CLI_PATH .. ' action -e ToggleManagerVisibility')
end)

galaxyBuds:subscribe({ "routine", "forced", "system_woke" }, updateGalaxyBuds)

updateGalaxyBuds()
