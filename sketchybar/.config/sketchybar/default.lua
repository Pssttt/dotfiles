local settings = require("config.settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.fonts.text,
      style = settings.fonts.styles.bold,
      size = settings.dimens.text.icon,
    },
    color = settings.colors.white,
    padding_left = settings.dimens.padding.icon,
    padding_right = settings.dimens.padding.icon,
  },
  label = {
    font = {
      family = settings.fonts.text,
      style = settings.fonts.styles.regular,
      size = settings.dimens.text.label,
    },
    color = settings.colors.white,
    padding_left = settings.dimens.padding.label,
    padding_right = settings.dimens.padding.label,
  },
  background = {
    height = settings.dimens.graphics.background.height,
    corner_radius = settings.dimens.graphics.background.corner_radius,
    border_width = 0,
    image = {
      corner_radius = settings.dimens.graphics.background.corner_radius
    }
  },
  -- rofi-style popups: solid base, accent border, soft shadow
  popup = {
    y_offset = settings.dimens.padding.popup,
    align = "center",
    background = {
      border_width = 2,
      border_color = settings.colors.popup.border,
      corner_radius = 12,
      color = settings.colors.popup.bg,
      shadow = { drawing = true },
      padding_left = settings.dimens.padding.icon,
      padding_right = settings.dimens.padding.icon,
    },
    blur_radius = settings.dimens.graphics.blur_radius,
  },
  slider = {
    highlight_color = settings.colors.accent,
    background = {
      height = 8,
      corner_radius = 4,
      color = settings.colors.slider.bg,
      border_width = 0,
    },
    knob = {
      font = {
        family = settings.fonts.text,
        style = settings.fonts.styles.regular,
        size = 24,
      },
      string = settings.icons.text.slider.knob,
      color = settings.colors.accent,
      drawing = true,
    },
  },
  scroll_texts = true,
})
