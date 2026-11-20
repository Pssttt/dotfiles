local padding <const> = {
	background = 8,
	icon = 10,
	label = 8,
	bar = 6,
	left = 0,
	right = 0,
	item = 6,
	widget = 9,
	chip_gap = 9,
	popup = 6,
}

local graphics <const> = {
	bar = {
		height = 36,
		offset = 6,
	},
	background = {
		height = 24,
		corner_radius = 8,
	},
	group = {
		height = 32,
		corner_radius = 14,
		border_width = 2,
	},
	underline = {
		height = 3,
		-- sits on the bottom edge of the bar
		y_offset = -14,
	},
	slider = {
		height = 20,
	},
	popup = {
		width = 200,
		large_width = 300,
	},
	blur_radius = 0,
}

local text <const> = {
	icon = 14.0,
	label = 13.0,
}

return {
	padding = padding,
	graphics = graphics,
	text = text,
}
