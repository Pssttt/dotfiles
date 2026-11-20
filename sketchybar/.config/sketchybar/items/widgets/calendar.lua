local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

-- Centered clock: muted date, bold time
local calendar = sbar.add("item", constants.items.CALENDAR, {
  position = "center",
  update_freq = 1,
  padding_left = 0,
  padding_right = 0,
  icon = {
    color = palette.overlay,
    padding_left = 0,
    padding_right = 8,
    font = {
      family = settings.fonts.text,
      style = settings.fonts.styles.regular,
      size = settings.dimens.text.label,
    },
  },
  label = {
    color = palette.text,
    padding_left = 0,
    padding_right = 0,
    font = {
      family = settings.fonts.text,
      style = settings.fonts.styles.bold,
      size = 14.0,
    },
  },
  background = { drawing = false },
})

calendar:subscribe({ "forced", "routine", "system_woke" }, function()
  calendar:set({
    icon = os.date("%a %d %b"),
    label = os.date("%H:%M"),
  })
end)

calendar:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Calendar'")
end)
