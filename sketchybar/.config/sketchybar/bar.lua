local settings = require("config.settings")

-- Full-width bar flush with the top edge of the screen
sbar.bar({
	topmost = "window",
	height = settings.dimens.graphics.bar.height,
	color = settings.colors.bar.bg,
	blur_radius = 0,
	padding_left = settings.dimens.padding.left,
	padding_right = settings.dimens.padding.right,
	margin = settings.dimens.padding.bar,
	corner_radius = 0,
	y_offset = settings.dimens.graphics.bar.offset,
	border_width = 0,
	shadow = true,
})
