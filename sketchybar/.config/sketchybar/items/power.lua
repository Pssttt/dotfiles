-- rofi-style power menu, opened from the Apple logo block
local settings = require("config.settings")

local colors <const> = settings.colors
local palette <const> = colors.palette

local power = sbar.add("item", "power", {
  padding_left = settings.dimens.padding.chip_gap,
  padding_right = settings.dimens.padding.chip_gap,
  icon = {
    string = settings.icons.text.apple,
    color = palette.crust,
    font = { size = 16.0 },
    padding_left = 11,
    padding_right = 12,
  },
  label = { drawing = false },
  background = {
    drawing = true,
    color = palette.mauve,
    height = settings.dimens.graphics.chip.height,
    corner_radius = settings.dimens.graphics.chip.corner_radius,
    shadow = { drawing = true, color = colors.chip.shadow, distance = 3, angle = 90 },
  },
  popup = { align = "left", y_offset = 6 },
})

sbar.add("item", "power.header", {
  position = "popup." .. power.name,
  icon = { string = "󰣇", color = palette.mauve, padding_left = 8 },
  label = {
    string = os.getenv("USER") or "session",
    color = palette.subtext,
    font = { style = settings.fonts.styles.bold },
  },
})

-- Restart, shut down and log out go through loginwindow, so macOS still
-- shows its own confirmation dialog.
local actions <const> = {
  { icon = "󰌾", name = "Lock", color = palette.blue, cmd = "pmset displaysleepnow" },
  { icon = "󰒲", name = "Sleep", color = palette.teal, cmd = "pmset sleepnow" },
  { icon = "󰍃", name = "Log out", color = palette.yellow, cmd = [[osascript -e 'tell app "loginwindow" to «event aevtlogo»']] },
  { icon = "󰜉", name = "Restart", color = palette.peach, cmd = [[osascript -e 'tell app "loginwindow" to «event aevtrrst»']] },
  { icon = "󰐥", name = "Shut down", color = palette.red, cmd = [[osascript -e 'tell app "loginwindow" to «event aevtrsdn»']] },
}

local function closeMenu()
  power:set({ popup = { drawing = false } })
end

for index, action in ipairs(actions) do
  local row = sbar.add("item", "power.action." .. index, {
    position = "popup." .. power.name,
    width = 170,
    icon = {
      string = action.icon,
      color = action.color,
      width = 30,
      padding_left = 8,
    },
    label = { string = action.name, color = palette.text },
    background = {
      drawing = true,
      color = colors.transparent,
      height = 30,
      corner_radius = 8,
    },
  })

  row:subscribe("mouse.entered", function()
    row:set({ background = { color = colors.popup.hover } })
  end)
  row:subscribe("mouse.exited", function()
    row:set({ background = { color = colors.transparent } })
  end)
  row:subscribe("mouse.clicked", function()
    closeMenu()
    sbar.exec(action.cmd)
  end)
end

power:subscribe("mouse.clicked", function()
  power:set({ popup = { drawing = "toggle" } })
end)
power:subscribe("mouse.exited.global", closeMenu)
