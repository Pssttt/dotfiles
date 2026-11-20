local colors <const> = require("config.colors")
local fonts <const> = require("config.fonts")
local icons <const> = require("config.icons")
local dimens <const> = require("config.dimens")

local palette <const> = colors.palette

-- Plain status widget: coloured icon, muted label, no background.
local function widget(color)
  return {
    padding_left = dimens.padding.widget,
    padding_right = dimens.padding.widget,
    background = { drawing = false },
    icon = {
      color = color,
      padding_left = 0,
      padding_right = 6,
    },
    label = {
      color = palette.subtext,
      padding_left = 0,
      padding_right = 0,
    },
  }
end

-- Thin vertical divider between groups
local function separator(name, position)
  return sbar.add("item", name, {
    position = position or "left",
    padding_left = 6,
    padding_right = 6,
    icon = { drawing = false },
    label = {
      string = "│",
      color = palette.surface1,
      padding_left = 0,
      padding_right = 0,
    },
    background = { drawing = false },
  })
end

return {
  fonts = fonts,
  dimens = dimens,
  colors = colors,
  icons = icons,
  widget = widget,
  separator = separator,
}
