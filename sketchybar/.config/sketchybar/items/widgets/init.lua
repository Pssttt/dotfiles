local constants = require("constants")
local settings = require("config.settings")

-- Right items are laid out right-to-left in require order
require("items.widgets.calendar")
require("items.widgets.battery")
require("items.widgets.volume")
require("items.widgets.wifi")
require("items.widgets.galaxy_buds")

-- leading pad so the group's left edge isn't flush with the first module
settings.spacer("group.right.start", "right", 4)

sbar.add("bracket", "group.right", {
  constants.items.CALENDAR,
  constants.items.BATTERY,
  constants.items.VOLUME .. ".value",
  constants.items.WIFI .. ".padding",
  constants.items.WIFI .. ".up",
  constants.items.WIFI .. ".down",
  constants.items.GALAXY_BUDS,
  "group.right.start",
}, settings.group())
