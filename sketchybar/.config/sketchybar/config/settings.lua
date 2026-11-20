local colors <const> = require("config.colors")
local fonts <const> = require("config.fonts")
local icons <const> = require("config.icons")
local dimens <const> = require("config.dimens")

local chipDimens <const> = dimens.graphics.chip

-- Dark rounded container (used as bracket properties)
local function island()
  return {
    background = {
      drawing = true,
      color = colors.island.bg,
      border_color = colors.island.border,
      border_width = 1,
      height = dimens.graphics.island.height,
      corner_radius = dimens.graphics.island.corner_radius,
      shadow = { drawing = true, color = colors.chip.shadow, distance = 3, angle = 90 },
    },
  }
end

-- Split "block": solid accent segment for the icon, dark segment for the label.
-- Pass the result straight to sbar.add / item:set.
local function chip(accent, opts)
  opts = opts or {}
  return {
    padding_left = dimens.padding.chip_gap,
    padding_right = dimens.padding.chip_gap,
    background = {
      drawing = true,
      color = colors.chip.bg,
      border_color = colors.chip.border,
      border_width = 1,
      height = chipDimens.height,
      corner_radius = chipDimens.corner_radius,
      shadow = { drawing = true, color = colors.chip.shadow, distance = 3, angle = 90 },
    },
    icon = {
      color = colors.palette.crust,
      padding_left = 10,
      padding_right = 10,
      background = {
        drawing = true,
        color = accent,
        height = chipDimens.height,
        corner_radius = chipDimens.corner_radius,
      },
    },
    label = {
      color = colors.palette.text,
      padding_left = 8,
      padding_right = opts.label_padding_right or 11,
      font = { family = fonts.text, style = fonts.styles.bold, size = dimens.text.label },
    },
  }
end

return {
  fonts = fonts,
  dimens = dimens,
  colors = colors,
  icons = icons,
  island = island,
  chip = chip,
}
