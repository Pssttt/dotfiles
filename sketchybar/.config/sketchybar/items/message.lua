local constants = require("constants")
local settings = require("config.settings")

local message = sbar.add("item", constants.items.MESSAGE, {
  width = 0,
  position = "center",
  popup = { align = "center" },
  label = {
    padding_left = 0,
    padding_right = 0,
  },
  background = {
    padding_left = 0,
    padding_right = 0,
  }
})

local messagePopup = sbar.add("item", {
  position = "popup." .. message.name,
  width = "dynamic",
  label = {
    color = settings.colors.palette.text,
    font = { style = settings.fonts.styles.bold },
    padding_left = 0,
    padding_right = 14,
  },
  icon = {
    string = "\u{f009a}", -- nf-md-bell
    color = settings.colors.palette.mauve,
    padding_left = 14,
    padding_right = 10,
  },
  background = { drawing = true, color = settings.colors.transparent, height = 36 },
})

local function hideMessage()
  message:set({ popup = { drawing = false } })
end

local function showMessage(content, hold)
  hideMessage()

  message:set({ popup = { drawing = true } })
  messagePopup:set({ label = { string = content } })

  if hold == false then
    sbar.delay(5, function()
      if hold then return end
      hideMessage()
    end)
  end
end

message:subscribe(constants.events.SEND_MESSAGE, function(env)
  local content = env.MESSAGE
  local hold = env.HOLD ~= nil and env.HOLD == "true" or false
  showMessage(content, hold)
end)

message:subscribe(constants.events.HIDE_MESSAGE, hideMessage)
