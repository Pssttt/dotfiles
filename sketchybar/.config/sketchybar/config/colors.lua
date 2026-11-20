-- Catppuccin Mocha
local palette <const> = {
  base = 0xff1e1e2e,
  mantle = 0xff181825,
  crust = 0xff11111b,
  surface0 = 0xff313244,
  surface1 = 0xff45475a,
  surface2 = 0xff585b70,
  overlay = 0xff6c7086,
  subtext = 0xffa6adc8,
  text = 0xffcdd6f4,

  rosewater = 0xfff5e0dc,
  flamingo = 0xfff2cdcd,
  pink = 0xfff5c2e7,
  mauve = 0xffcba6f7,
  red = 0xfff38ba8,
  maroon = 0xffeba0ac,
  peach = 0xfffab387,
  yellow = 0xfff9e2af,
  green = 0xffa6e3a1,
  teal = 0xff94e2d5,
  sky = 0xff89dceb,
  sapphire = 0xff74c7ec,
  blue = 0xff89b4fa,
  lavender = 0xffb4befe,
}

local colors <const> = {
  palette = palette,

  -- Legacy names used across the items
  black = palette.crust,
  white = palette.text,
  red = palette.red,
  green = palette.green,
  blue = palette.blue,
  yellow = palette.yellow,
  orange = palette.peach,
  magenta = palette.pink,
  purple = palette.mauve,
  other_purple = palette.lavender,
  cyan = palette.teal,
  grey = palette.overlay,
  dirty_white = palette.subtext,
  dark_grey = palette.surface0,
  transparent = 0x00000000,
  accent = palette.mauve,

  bar = {
    bg = 0xf2181825, -- mantle
    border = palette.surface0,
    transparent = 0x00000000,
  },
  popup = {
    bg = 0xff1e1e2e,
    border = palette.surface1,
    hover = palette.surface1,
  },
  slider = {
    bg = palette.surface0,
    border = palette.surface1,
  },
  bg1 = 0xeb1e1e2e,
  bg2 = palette.surface0,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
