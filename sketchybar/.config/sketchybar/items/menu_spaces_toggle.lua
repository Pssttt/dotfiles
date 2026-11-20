local constants = require("constants")
local settings = require("config.settings")

sbar.add("event", constants.events.SWAP_MENU_AND_SPACES)

local function switchToggle(menuToggle)
  local isShowingMenu = menuToggle:query().icon.value == settings.icons.text.switch.on

  menuToggle:set({
    icon = isShowingMenu and settings.icons.text.switch.off or settings.icons.text.switch.on,
    label = isShowingMenu and "Menus" or "Spaces",
  })

  sbar.trigger(constants.events.SWAP_MENU_AND_SPACES, { isShowingMenu = isShowingMenu })
end

local function addToggle()
  local menuToggle = sbar.add("item", constants.items.MENU_TOGGLE, {
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = settings.icons.text.switch.on,
      color = settings.colors.palette.overlay,
      padding_left = 6,
      padding_right = 6,
    },
    label = {
      width = 0,
      padding_left = 0,
      color = settings.colors.palette.lavender,
      padding_right = 6,
      string = "Spaces",
      font = { style = settings.fonts.styles.bold },
    },
    background = { drawing = false },
  })

  sbar.add("item", constants.items.MENU_TOGGLE .. ".padding", {
    width = 0
  })
  settings.separator(constants.items.MENU_TOGGLE .. ".separator")

  menuToggle:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
      menuToggle:set({
        icon = { color = settings.colors.palette.lavender },
        label = { width = "dynamic" }
      })
    end)
  end)

  menuToggle:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
      menuToggle:set({
        icon = { color = settings.colors.palette.overlay },
        label = { width = 0 }
      })
    end)
  end)

  menuToggle:subscribe("mouse.clicked", function(env)
    switchToggle(menuToggle)
  end)

  menuToggle:subscribe(constants.events.AEROSPACE_SWITCH, function(env)
    switchToggle(menuToggle)
  end)
end

addToggle()
