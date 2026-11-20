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
    padding_left = settings.dimens.padding.chip_gap,
    padding_right = settings.dimens.padding.chip_gap,
    icon = {
      string = settings.icons.text.switch.on,
      color = settings.colors.palette.lavender,
    },
    label = {
      width = 0,
      padding_left = 0,
      color = settings.colors.palette.crust,
      string = "Spaces",
      font = { style = settings.fonts.styles.bold },
    },
    background = settings.chip(settings.colors.palette.lavender).background,
  })

  sbar.add("item", constants.items.MENU_TOGGLE .. ".padding", {
    width = settings.dimens.padding.chip_gap
  })

  menuToggle:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
      menuToggle:set({
        background = { color = settings.colors.palette.lavender },
        icon = { color = settings.colors.palette.crust },
        label = { width = "dynamic" }
      })
    end)
  end)

  menuToggle:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
      menuToggle:set({
        background = { color = settings.colors.chip.bg },
        icon = { color = settings.colors.palette.lavender },
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
