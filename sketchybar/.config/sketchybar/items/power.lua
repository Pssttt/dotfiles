-- Power menu card, opened from the Apple logo
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette

local power = sbar.add("item", "power", {
  padding_left = 6,
  padding_right = 2,
  icon = {
    string = settings.icons.text.apple,
    color = palette.mauve,
    font = { size = 16.0 },
    padding_left = 6,
    padding_right = 6,
  },
  label = { drawing = false },
  background = { drawing = false },
  popup = popup.container("left"),
})

local function closeMenu()
  power:set({ popup = { drawing = false } })
end

local header = popup.header(power, {
  name = "power.card.header",
  icon = "\u{f0004}", -- nf-md-account
  title = os.getenv("USER") or "session",
  color = palette.mauve,
})
local uptimeRow = popup.row(power, { name = "power.card.uptime", key = "Uptime" })
local hostRow = popup.row(power, { name = "power.card.host", key = "Host" })
popup.divider(power)

-- Restart, shut down and log out go through loginwindow, so macOS still
-- shows its own confirmation dialog.
local actions <const> = {
  { icon = "\u{f033e}", label = "Lock screen", color = palette.blue,
    cmd = [[osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}']] },
  { icon = "\u{f04b2}", label = "Sleep", color = palette.teal, cmd = "pmset sleepnow" },
  { icon = "\u{f0343}", label = "Log out", color = palette.yellow,
    cmd = [[osascript -e 'tell app "loginwindow" to «event aevtlogo»']] },
  { icon = "\u{f0709}", label = "Restart", color = palette.peach,
    cmd = [[osascript -e 'tell app "loginwindow" to «event aevtrrst»']] },
  { icon = "\u{f0425}", label = "Shut down", color = palette.red,
    cmd = [[osascript -e 'tell app "loginwindow" to «event aevtrsdn»']] },
}

for index, action in ipairs(actions) do
  popup.button(power, {
    name = "power.action." .. index,
    icon = action.icon,
    color = action.color,
    label = action.label,
    on_click = function()
      closeMenu()
      sbar.exec(action.cmd)
    end,
  })
end

local function updateCard()
  sbar.exec([[uptime | sed -E 's/.*up +//; s/, +[0-9]+ users?.*//; s/,//g']], function(result)
    uptimeRow:set({ label = { string = (result:gsub("[\r\n]", "")) } })
  end)
  sbar.exec("scutil --get ComputerName", function(result)
    hostRow:set({ label = { string = (result:gsub("[\r\n]", "")) } })
  end)
end

power:subscribe("mouse.clicked", function()
  local shouldDraw = power:query().popup.drawing == "off"
  power:set({ popup = { drawing = shouldDraw } })
  if shouldDraw then updateCard() end
end)
power:subscribe("mouse.entered", function()
  power:set({ icon = { color = palette.pink } })
end)
power:subscribe("mouse.exited", function()
  power:set({ icon = { color = palette.mauve } })
end)
power:subscribe("mouse.exited.global", closeMenu)
