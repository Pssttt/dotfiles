local constants = require("constants")
local settings = require("config.settings")

local palette <const> = settings.colors.palette

local calendar = sbar.add("item", constants.items.CALENDAR, settings.chip(palette.mauve))
calendar:set({
  position = "right",
  update_freq = 1,
  icon = { string = "󰃭" },
})

calendar:subscribe({ "forced", "routine", "system_woke" }, function()
  calendar:set({ label = os.date("%a %d %b  %H:%M") })
end)

calendar:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Calendar'")
end)
