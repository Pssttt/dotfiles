local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

-- Waybar-style clock module, rightmost in the right group
local calendar = sbar.add("item", constants.items.CALENDAR, settings.widget(palette.mauve))
calendar:set({
  position = "right",
  update_freq = 1,
  padding_right = 12,
  icon = { string = "\u{f0954}" }, -- nf-md-clock_outline
  label = {
    color = palette.text,
    font = { style = settings.fonts.styles.bold },
  },
})

calendar:subscribe({ "forced", "routine", "system_woke" }, function()
  calendar:set({ label = os.date("%a %d %b  %H:%M") })
end)

calendar:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Calendar'")
end)
