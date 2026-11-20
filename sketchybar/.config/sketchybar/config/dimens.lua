local padding <const> = {
	background = 8,
	icon = 10,
	label = 8,
	bar = 10,
	left = 0,
	right = 0,
	item = 6,
	chip_gap = 3,
	popup = 8,
}

local graphics <const> = {
	bar = {
		height = 38,
		offset = 5,
	},
	background = {
		height = 28,
		corner_radius = 9,
	},
	chip = {
		height = 28,
		corner_radius = 9,
	},
	island = {
		height = 28,
		corner_radius = 9,
	},
	slider = {
		height = 20,
	},
	popup = {
		width = 200,
		large_width = 300,
	},
	blur_radius = 20,
}

local text <const> = {
	icon = 15.0,
	label = 13.0,
}

return {
	padding = padding,
	graphics = graphics,
	text = text,
}
