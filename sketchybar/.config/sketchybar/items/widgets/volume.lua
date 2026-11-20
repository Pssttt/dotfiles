local constants = require("constants")
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette
local DEVICE_PREFIX <const> = constants.items.VOLUME .. ".device."
local CHECK <const> = "\u{f012c}" -- nf-md-check
local SPEAKER <const> = "\u{f04c3}" -- nf-md-speaker

local volumeValue = sbar.add("item", constants.items.VOLUME .. ".value", settings.widget(palette.peach))
volumeValue:set({
  position = "right",
  label = { string = "??%" },
})

local volumeBracket = sbar.add("bracket", constants.items.VOLUME .. ".bracket", { volumeValue.name }, {
  popup = popup.container("right"),
})

-- Card ---------------------------------------------------------------------
local header = popup.header(volumeBracket, {
  name = constants.items.VOLUME .. ".card.header",
  icon = settings.icons.text.volume._100,
  title = "Sound",
  color = palette.peach,
})

local volumeSlider = sbar.add("slider", constants.items.VOLUME .. ".slider", popup.WIDTH - 24, {
  position = "popup." .. volumeBracket.name,
  padding_left = 12,
  padding_right = 12,
  -- sliders still get the default icon/label padding, which widened the card
  icon = { drawing = false, padding_left = 0, padding_right = 0 },
  label = { drawing = false, padding_left = 0, padding_right = 0 },
  slider = {
    highlight_color = palette.peach,
    knob = { drawing = true, color = palette.text, font = { size = 18.0 } },
    background = { height = 6, corner_radius = 3, color = palette.surface0 },
  },
  background = { drawing = true, color = settings.colors.transparent, height = 26 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

popup.divider(volumeBracket)

-- Bar item -----------------------------------------------------------------
local function volumeIcon(volume)
  local icons = settings.icons.text.volume
  if volume > 60 then return icons._100 end
  if volume > 30 then return icons._66 end
  if volume > 10 then return icons._33 end
  if volume > 0 then return icons._10 end
  return icons._0
end

volumeValue:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO) or 0
  local hasVolume = volume ~= 0
  local lead = volume < 10 and "0" or ""

  volumeSlider:set({ slider = { percentage = volume } })
  header:set({ icon = { string = volumeIcon(volume) }, label = { string = "Sound  " .. volume .. "%" } })
  volumeValue:set({
    icon = {
      string = volumeIcon(volume),
      color = hasVolume and palette.peach or palette.overlay,
    },
    label = { string = hasVolume and lead .. volume .. "%" or "mute" },
  })
end)

-- Output devices (rebuilt each time the card opens) -------------------------
local hasDevices = false

local function clearDevices()
  -- skip when empty: removing a regex with no match is logged every time
  if not hasDevices then return end
  hasDevices = false
  sbar.remove("/" .. DEVICE_PREFIX:gsub("%.", "\\.") .. ".*/")
end

local function buildDevices()
  clearDevices()
  hasDevices = true

  sbar.exec("SwitchAudioSource -t output -c", function(currentResult)
    local current = currentResult:gsub("[\r\n]+$", "")

    sbar.exec("SwitchAudioSource -a -t output", function(available)
      local index = 0
      for device in available:gmatch("[^\r\n]+") do
        index = index + 1
        local isCurrent = device == current
        popup.button(volumeBracket, {
          name = DEVICE_PREFIX .. index,
          icon = isCurrent and CHECK or SPEAKER,
          color = isCurrent and palette.peach or palette.overlay,
          label = device,
          on_click = function()
            sbar.exec('SwitchAudioSource -s "' .. device:gsub('"', '\\"') .. '"', buildDevices)
          end,
        })
      end

      popup.button(volumeBracket, {
        name = DEVICE_PREFIX .. "settings",
        icon = settings.icons.text.gear,
        color = palette.subtext,
        label = "Sound settings…",
        on_click = function()
          volumeBracket:set({ popup = { drawing = false } })
          sbar.exec("open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'")
        end,
      })
    end)
  end)
end

local function hideVolumeDetails()
  if volumeBracket:query().popup.drawing ~= "on" then return end
  volumeBracket:set({ popup = { drawing = false } })
  clearDevices()
end

local function toggleVolumeDetails(env)
  if env.BUTTON == "right" then
    sbar.exec("open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'")
    return
  end

  if volumeBracket:query().popup.drawing == "off" then
    volumeBracket:set({ popup = { drawing = true } })
    buildDevices()
  else
    hideVolumeDetails()
  end
end

local function changeVolume(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volumeValue:subscribe("mouse.clicked", toggleVolumeDetails)
volumeValue:subscribe("mouse.scrolled", changeVolume)
volumeValue:subscribe("mouse.exited.global", hideVolumeDetails)
