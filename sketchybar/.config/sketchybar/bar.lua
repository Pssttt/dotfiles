local settings = require("config.settings")

-- Transparent floating bar; left/center/right groups draw their own boxes
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
	shadow = false,
})
