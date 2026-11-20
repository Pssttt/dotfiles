local settings = require("config.settings")

-- Transparent bar: every item draws its own floating block
sbar.bar({
	topmost = "window",
	height = settings.dimens.graphics.bar.height,
	color = settings.colors.bar.transparent,
	padding_left = settings.dimens.padding.left,
	padding_right = settings.dimens.padding.right,
	margin = settings.dimens.padding.bar,
	corner_radius = settings.dimens.graphics.background.corner_radius,
	y_offset = settings.dimens.graphics.bar.offset,
	border_width = 0,
})
