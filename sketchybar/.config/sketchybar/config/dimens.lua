local padding <const> = {
	background = 8,
	icon = 10,
	label = 8,
	bar = 0,
	left = 10,
	right = 12,
	item = 6,
	widget = 9,
	chip_gap = 9,
	popup = 6,
}

local graphics <const> = {
	bar = {
		height = 32,
		offset = 0,
	},
	background = {
		height = 24,
		corner_radius = 8,
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
