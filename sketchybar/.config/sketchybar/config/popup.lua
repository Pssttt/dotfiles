-- Shared building blocks for every popup ("card") on the bar.
--
--   ┌──────────────────────────────┐
--   │ 󰂄  Battery                    │  header : accent icon + bold title
--   │ ████████████░░░░░░░░          │  meter  : read-only progress bar
--   │ ──────────────────────────── │  divider
--   │ Status              Charging │  row    : muted key, bright value
--   │ 󰒲  Sleep                      │  button : hover highlight, click action
--   └──────────────────────────────┘
--
-- Item names are optional; pass one when the item is updated later.

local colors <const> = require("config.colors")
local fonts <const> = require("config.fonts")
local dimens <const> = require("config.dimens")

local palette <const> = colors.palette

local WIDTH <const> = 260
local INSET <const> = 12
local KEY_WIDTH <const> = 100

local popup = { WIDTH = WIDTH }

local function target(parent)
  return "popup." .. (type(parent) == "string" and parent or parent.name)
end

local function add(name, props)
  if name then
    return sbar.add("item", name, props)
  end
  return sbar.add("item", props)
end

local function font(style, size)
  return { family = fonts.text, style = style, size = size or dimens.text.label }
end

-- Popup container props, merged into the owning item/bracket.
-- align: "left" for items on the left of the bar, "right" for the right side.
function popup.container(align)
  return {
    align = align or "right",
    y_offset = 6,
    background = {
      color = colors.popup.bg,
      border_color = colors.popup.border,
      border_width = 1,
      corner_radius = 14,
      shadow = { drawing = true },
    },
    blur_radius = dimens.graphics.blur_radius,
  }
end

function popup.header(parent, opts)
  return add(opts.name, {
    position = target(parent),
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = opts.icon,
      color = opts.color or palette.mauve,
      font = font(fonts.styles.bold, 16.0),
      width = 34,
      padding_left = INSET,
      padding_right = 0,
    },
    label = {
      string = opts.title,
      color = palette.text,
      font = font(fonts.styles.bold, 14.0),
      max_chars = 24,
      padding_left = 0,
      padding_right = INSET,
    },
    background = { drawing = true, color = colors.transparent, height = 36 },
  })
end

function popup.divider(parent)
  return add(nil, {
    position = target(parent),
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = {
      string = "",
      padding_left = 0,
      padding_right = 0,
    },
    background = {
      drawing = true,
      color = palette.surface0,
      height = 1,
      x_offset = INSET,
    },
  })
end

-- Key on the left (muted), value on the right (bright)
function popup.row(parent, opts)
  return add(opts.name, {
    position = target(parent),
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = opts.key,
      color = palette.overlay,
      font = font(fonts.styles.regular),
      align = "left",
      width = KEY_WIDTH,
      padding_left = INSET,
      padding_right = 0,
    },
    label = {
      string = opts.value or "…",
      color = opts.color or palette.text,
      font = font(fonts.styles.bold),
      align = "right",
      max_chars = 20,
      width = WIDTH - KEY_WIDTH,
      padding_left = 0,
      padding_right = INSET,
    },
    background = { drawing = true, color = colors.transparent, height = 24 },
  })
end

-- Read-only progress bar: filled segments in the accent colour (icon),
-- empty segments in surface0 (label). Update with popup.set_meter().
local METER_SEGMENTS <const> = 26
local METER_GLYPH <const> = "━"

function popup.meter(parent, opts)
  return add(opts.name, {
    position = target(parent),
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = "",
      color = opts.color or palette.mauve,
      font = font(fonts.styles.bold, 12.0),
      padding_left = INSET,
      padding_right = 0,
    },
    label = {
      string = string.rep(METER_GLYPH, METER_SEGMENTS),
      color = palette.surface0,
      font = font(fonts.styles.bold, 12.0),
      padding_left = 0,
      padding_right = INSET,
    },
    background = { drawing = true, color = colors.transparent, height = 18 },
  })
end

function popup.set_meter(item, percentage, color)
  local filled = math.floor((math.max(0, math.min(100, percentage)) / 100) * METER_SEGMENTS + 0.5)
  item:set({
    icon = { string = string.rep(METER_GLYPH, filled), color = color, drawing = filled > 0 },
    label = { string = string.rep(METER_GLYPH, METER_SEGMENTS - filled) },
  })
end

-- Clickable row with hover highlight.
-- opts: name, icon, color, label, detail (optional right-hand hint), on_click
function popup.button(parent, opts)
  local accent = opts.color or palette.mauve
  local item = add(opts.name, {
    position = target(parent),
    width = WIDTH,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = opts.icon,
      color = accent,
      font = font(fonts.styles.bold, 15.0),
      width = 34,
      padding_left = INSET,
      padding_right = 0,
    },
    label = {
      string = opts.label,
      color = palette.text,
      font = font(fonts.styles.regular),
      max_chars = 24,
      padding_left = 0,
      padding_right = INSET,
    },
    background = {
      drawing = true,
      color = colors.transparent,
      height = 30,
      corner_radius = 8,
    },
  })

  item:subscribe("mouse.entered", function()
    item:set({
      background = { color = palette.surface0 },
      label = { color = accent },
    })
  end)
  item:subscribe("mouse.exited", function()
    item:set({
      background = { color = colors.transparent },
      label = { color = palette.text },
    })
  end)
  if opts.on_click then
    item:subscribe("mouse.clicked", opts.on_click)
  end

  return item
end

-- Small vertical breathing room at the bottom of a card
function popup.spacer(parent)
  return add(nil, {
    position = target(parent),
    width = WIDTH,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = true, color = colors.transparent, height = 6 },
  })
end

return popup
