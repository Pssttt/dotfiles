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

-- Hyprland/Waybar-style module group: rounded box with an accent border.
-- Used as bracket properties.
local function group()
  return {
    background = {
      drawing = true,
      color = colors.group.bg,
      border_color = colors.group.border,
      border_width = dimens.graphics.group.border_width,
      height = dimens.graphics.group.height,
      corner_radius = dimens.graphics.group.corner_radius,
    },
  }
end

-- Fixed-width empty gap. Icon/label must be switched off, otherwise their
-- default padding makes the item far wider than its width.
local function spacer(name, position, width)
  return sbar.add("item", name, {
    position = position or "left",
    width = width,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = false },
  })
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
  group = group,
  spacer = spacer,
  separator = separator,
}
