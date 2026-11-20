local constants = require("constants")
local settings = require("config.settings")

local CLI_PATH <const> = "'/Applications/Galaxy Buds Manager.app/Contents/MacOS/Galaxy Buds Manager'"
local QUERY_CMD <const> = CLI_PATH .. [[ device -G -j 2>/dev/null | jq -r 'if .BatteryLeft != null then "\(.BatteryLeft)|\(.BatteryRight)|\(.BatteryCase)|\(.WearStateLeft)|\(.WearStateRight)|\(.Name)" else empty end']]
local NOISE_MODE_CMD <const> = [[sqlite3 -batch -list "$HOME/Library/Application Support/GalaxyBudsClient/battery_stats_b04a6ad29ade.db" "SELECT NoiseControlMode FROM Records WHERE NoiseControlMode IS NOT NULL ORDER BY Id DESC LIMIT 1;" 2>/dev/null]]
local popupWidth <const> = settings.dimens.graphics.popup.width + 20

local currentNoiseMode = -1

-- Noise mode map: 0=Off, 1=ANC, 2=Ambient
local noiseModes = {
  [0] = { icon = "󰋑", name = "Off",     color = settings.colors.grey   },
  [1] = { icon = "󰋋", name = "ANC",     color = settings.colors.blue   },
  [2] = { icon = "󰂰", name = "Ambient", color = settings.colors.yellow },
}

local galaxyBuds = sbar.add("item", constants.items.GALAXY_BUDS, settings.chip(settings.colors.palette.teal))
galaxyBuds:set({
  position = "right",
  update_freq = 30,
  drawing = false,
  icon = { string = settings.icons.text.earbuds or "󰥰" },
  label = { string = "" },
})

local budsTitle = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  align = "center",
  icon = {
    string = settings.icons.text.earbuds or "󰥰",
    font = { style = settings.fonts.styles.bold },
    color = settings.colors.white,
  },
  label = {
    font = { style = settings.fonts.styles.bold, size = settings.dimens.text.label },
    max_chars = 22,
    string = "Galaxy Buds",
    color = settings.colors.white,
  },
})

local budsLeft = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  background = { height = 18 },
  icon = {
    align = "left",
    string = "Left:",
    width = 50,
    font = { size = settings.dimens.text.label },
    color = settings.colors.grey,
  },
  label = {
    align = "right",
    string = "--%",
    width = popupWidth - 50,
    color = settings.colors.white,
  },
})

local budsRight = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  background = { height = 18 },
  icon = {
    align = "left",
    string = "Right:",
    width = 50,
    font = { size = settings.dimens.text.label },
    color = settings.colors.grey,
  },
  label = {
    align = "right",
    string = "--%",
    width = popupWidth - 50,
    color = settings.colors.white,
  },
})

local budsCase = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  background = { height = 18 },
  icon = {
    align = "left",
    string = "Case:",
    width = 50,
    font = { size = settings.dimens.text.label },
    color = settings.colors.grey,
  },
  label = {
    align = "right",
    string = "--%",
    width = popupWidth - 50,
    color = settings.colors.white,
  },
})

-- Noise control toggle button
local budsNoise = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  background = {
    height = 24,
    corner_radius = 6,
    drawing = true,
    color = settings.colors.bg2,
  },
  icon = {
    string = "󰋑",
    color = settings.colors.grey,
    align = "left",
    width = 24,
  },
  label = {
    string = "Noise Control: Off",
    align = "left",
    color = settings.colors.white,
  },
})

-- Galaxy Buds Manager button
local budsManager = sbar.add("item", {
  position = "popup." .. galaxyBuds.name,
  width = popupWidth,
  background = {
    height = 24,
    corner_radius = 6,
    drawing = false,
    color = settings.colors.bg2,
  },
  icon = {
    string = settings.icons.text.gear or "",
    color = settings.colors.green,
    align = "left",
    width = 24,
  },
  label = {
    string = "Galaxy Buds Manager",
    align = "left",
    color = settings.colors.white,
  },
})

local function updateNoiseDisplay(mode)
  local m = noiseModes[mode]
  if not m then return end
  currentNoiseMode = mode

  budsNoise:set({
    icon = { string = m.icon, color = m.color },
    label = { string = "Noise Control: " .. m.name, color = settings.colors.white },
    background = { drawing = true, color = settings.colors.bg2 },
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
        icon = { string = settings.icons.text.earbuds or "󰥰", background = { color = color } },
        label = { string = lead .. batt .. "%", drawing = true },
      })

      budsTitle:set({ label = { string = name or "Galaxy Buds" } })
      budsLeft:set({ label = { string = nLeft .. "% (" .. wearL .. ")" } })
      budsRight:set({ label = { string = nRight .. "% (" .. wearR .. ")" } })
      budsCase:set({ label = { string = (nCase > 0) and (nCase .. "%") or "In use / Closed" } })

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

-- Hover feedback for noise control
budsNoise:subscribe("mouse.entered", function()
  budsNoise:set({
    background = { color = settings.colors.dark_grey or settings.colors.bg1 },
    label = { color = settings.colors.cyan },
  })
end)
budsNoise:subscribe("mouse.exited", function()
  budsNoise:set({
    background = { color = settings.colors.bg2 },
    label = { color = settings.colors.white },
  })
end)

-- Hover feedback for manager button
budsManager:subscribe("mouse.entered", function()
  budsManager:set({
    background = { drawing = true },
    label = { color = settings.colors.green },
  })
end)
budsManager:subscribe("mouse.exited", function()
  budsManager:set({
    background = { drawing = false },
    label = { color = settings.colors.white },
  })
end)

-- Manager button click
budsManager:subscribe("mouse.clicked", function()
  galaxyBuds:set({ popup = { drawing = false } })
  sbar.exec(CLI_PATH .. ' action -e ToggleManagerVisibility')
end)

galaxyBuds:subscribe({ "routine", "forced", "system_woke" }, updateGalaxyBuds)

updateGalaxyBuds()
