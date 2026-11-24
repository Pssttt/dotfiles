-- Now playing: a group to the left of the right-hand modules, plus a card
-- with artwork, a seekable progress bar and controls.
--
-- Source: nowplaying-cli (works with Pine Player). Notes from testing:
--  * sketchybar's media_change event never fires here, so we poll.
--  * get-raw reports ElapsedTime only as a snapshot taken at the last
--    play/pause/seek/track change, with no timestamp. We anchor the snapshot
--    to the moment we first see it and count forward while playing. After a
--    reload mid-song the position can be off until the next play/pause/seek.
local settings = require("config.settings")
local popup = require("config.popup")

local palette <const> = settings.colors.palette

local NAME <const> = "media"
-- A check costs ~35ms CPU while playing; when nothing is playing
-- nowplaying-cli waits ~2.8s for MediaRemote to time out. Poll fast only
-- while playing.
local POLL_PLAYING <const> = 1
local POLL_IDLE <const> = 5
local ART_DIR <const> = "/tmp/sketchybar-media"
local ART_SIZE <const> = popup.WIDTH - 24 -- points, inset like the text rows
local ART_SCALE <const> = 0.5 -- artwork is fetched at 2x for retina
local SEPARATOR <const> = "\u{2219}" -- Pine Player joins artist and album with "∙"

local ICON_PLAYING <const> = "\u{f075a}" -- nf-md-music
local ICON_PAUSED <const> = "\u{f03e4}" -- nf-md-pause
local ICON_PREVIOUS <const> = "\u{f04ae}" -- nf-md-skip_previous
local ICON_NEXT <const> = "\u{f04ad}" -- nf-md-skip_next
local ICON_PLAY <const> = "\u{f040a}" -- nf-md-play
local ICON_ALBUM <const> = "\u{f0025}" -- nf-md-album

-- Raw output minus the (large) artwork blob. The "raw:" prefix stops
-- sbar.exec from JSON-decoding it: an empty "{ }" result made SbarLua
-- re-fire unrelated startup callbacks (duplicate workspace items).
local INFO_CMD <const> = "printf 'raw:'; nowplaying-cli get-raw 2>/dev/null | grep -v ArtworkData"

-- Bar ----------------------------------------------------------------------
-- gap between this group and the right group (added first = sits rightmost)
settings.spacer(NAME .. ".gap", "right", 8)

local media = sbar.add("item", NAME, settings.widget(palette.mauve))
media:set({
  position = "right",
  drawing = false,
  updates = true, -- keep polling while hidden so it can reappear
  update_freq = POLL_IDLE,
  padding_left = 12,
  padding_right = 12,
  icon = { string = ICON_PLAYING },
  label = {
    color = palette.text,
    max_chars = 40,
    font = { style = settings.fonts.styles.bold },
  },
  popup = popup.container("right"),
})

local group = sbar.add("bracket", "group.media", { media.name }, settings.group())
group:set({ drawing = false })

-- Card ---------------------------------------------------------------------
-- Artwork: item padding does the horizontal inset (background x_offset is
-- ignored for images); the taller background leaves room above and below.
local art = sbar.add("item", NAME .. ".card.art", {
  position = "popup." .. media.name,
  width = ART_SIZE,
  padding_left = 12,
  padding_right = 12,
  icon = { drawing = false },
  label = { drawing = false },
  drawing = false,
  background = {
    drawing = true,
    color = settings.colors.transparent,
    height = ART_SIZE + 16,
    image = { drawing = true, scale = ART_SCALE, corner_radius = 10 },
  },
})

local header = popup.header(media, { name = NAME .. ".card.header", icon = ICON_ALBUM, title = "Nothing playing" })
local artistRow = popup.row(media, { name = NAME .. ".card.artist", key = "Artist" })
local albumRow = popup.row(media, { name = NAME .. ".card.album", key = "Album" })

-- Seekable progress bar + elapsed / total
local progress = sbar.add("slider", NAME .. ".card.progress", ART_SIZE, {
  position = "popup." .. media.name,
  padding_left = 12,
  padding_right = 12,
  -- sliders still get the default icon/label padding, which widened the card
  icon = { drawing = false, padding_left = 0, padding_right = 0 },
  label = { drawing = false, padding_left = 0, padding_right = 0 },
  slider = {
    highlight_color = palette.mauve,
    percentage = 0,
    knob = { drawing = true, color = palette.text, font = { size = 14.0 } },
    background = { height = 4, corner_radius = 2, color = palette.surface1 },
  },
  background = { drawing = true, color = settings.colors.transparent, height = 18 },
})

local times = popup.row(media, { name = NAME .. ".card.times", key = "0:00", value = "0:00" })
times:set({ label = { color = palette.overlay, font = { style = settings.fonts.styles.regular } } })
popup.divider(media)

local state = {
  title = nil,
  playing = false,
  duration = 0,
  -- position tracking (see header comment)
  snapshot = nil, -- last raw ElapsedTime seen
  snapshotRate = nil,
  baseElapsed = 0,
  anchor = os.time(),
  artCounter = 0,
}

local refresh -- forward declaration, used by the buttons

local function control(command)
  sbar.exec("nowplaying-cli " .. command, function()
    sbar.delay(0.3, function() refresh() end)
  end)
end

local playPause = popup.button(media, {
  name = NAME .. ".card.playpause",
  icon = ICON_PAUSED,
  color = palette.mauve,
  label = "Pause",
})
popup.button(media, {
  name = NAME .. ".card.next",
  icon = ICON_NEXT,
  color = palette.lavender,
  label = "Next",
  on_click = function() control("next") end,
})
popup.button(media, {
  name = NAME .. ".card.previous",
  icon = ICON_PREVIOUS,
  color = palette.lavender,
  label = "Previous",
  on_click = function() control("previous") end,
})

-- Helpers ------------------------------------------------------------------
-- sbar.exec hands JSON output over already decoded as a table; fall back to
-- pattern matching if it ever arrives as a string.
local function rawValue(raw, key)
  local fullKey = "kMRMediaRemoteNowPlayingInfo" .. key
  if type(raw) == "table" then
    return raw[fullKey]
  end
  if type(raw) ~= "string" then return nil end
  local number = raw:match('"' .. fullKey .. '"%s*:%s*([%d%.%-]+)')
  if number then return tonumber(number) end
  local text = raw:match('"' .. fullKey .. '"%s*:%s*"(.-)"%s*[,\n}]')
  if text then
    -- undo JSON escapes for quotes, slashes and backslashes
    text = text:gsub('\\"', '"'):gsub('\\/', '/'):gsub('\\\\', '\\')
  end
  return text
end

local function rawNumber(raw, key)
  return tonumber(rawValue(raw, key))
end

local function rawString(raw, key)
  local value = rawValue(raw, key)
  if value == nil or value == "" then return nil end
  return tostring(value)
end

-- Fit the bar label into the free space between the center group (or the
-- left group when the center is empty) and the right group, so long titles
-- scroll instead of sliding under the center box.
local CHAR_WIDTH <const> = 7.8 -- Hack Nerd Font Bold at 13pt
local CHROME_WIDTH <const> = 12 + 15 + 6 + 12 + 12 -- paddings, icon, group gaps
local MIN_CHARS <const> = 8
local MAX_CHARS <const> = 40

-- bounding rects per display ("display-1" = { origin, size }), hidden ones dropped
local function rects(query)
  local out = {}
  if type(query) ~= "table" or type(query.bounding_rects) ~= "table" then return out end
  for display, rect in pairs(query.bounding_rects) do
    if rect.origin and rect.origin[1] > -9000 then out[display] = rect end
  end
  return out
end

local function fitLabel()
  local bar = sbar.query("bar")
  local present = {}
  for _, name in ipairs((type(bar) == "table" and bar.items) or {}) do
    present[name] = true
  end
  if not present["group.right"] then return end

  local right = rects(sbar.query("group.right"))
  local neighbour = present["group.center"] and rects(sbar.query("group.center"))
    or (present["group.left"] and rects(sbar.query("group.left")))
    or {}

  -- compare rects on the same display (coordinates are global, so mixing
  -- displays gives nonsense) and fit the tightest one
  local available
  for display, r in pairs(right) do
    local n = neighbour[display]
    if n then
      local space = r.origin[1] - (n.origin[1] + n.size[1]) - CHROME_WIDTH
      if not available or space < available then available = space end
    end
  end
  if not available then return end

  local chars = math.floor(available / CHAR_WIDTH)
  chars = math.max(MIN_CHARS, math.min(MAX_CHARS, chars))
  media:set({ label = { max_chars = chars } })
end

local function formatTime(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, secs)
  end
  return string.format("%d:%02d", minutes, secs)
end

local function splitArtist(artist, album)
  if artist and not album then
    local cut = artist:find(SEPARATOR, 1, true)
    if cut then
      return artist:sub(1, cut - 1), artist:sub(cut + #SEPARATOR)
    end
  end
  return artist, album
end

local function currentElapsed()
  local elapsed = state.baseElapsed
  if state.playing then
    elapsed = elapsed + (os.time() - state.anchor)
  end
  if state.duration > 0 then
    elapsed = math.min(elapsed, state.duration)
  end
  return elapsed
end

-- Bar item + play/pause button reflect `state.playing`
local function renderPlayState()
  local accent = state.playing and palette.mauve or palette.overlay
  media:set({
    icon = { string = state.playing and ICON_PLAYING or ICON_PAUSED, color = accent },
    label = { color = state.playing and palette.text or palette.overlay },
  })
  header:set({ icon = { color = accent } })
  playPause:set({
    icon = { string = state.playing and ICON_PAUSED or ICON_PLAY },
    label = { string = state.playing and "Pause" or "Play" },
  })
end

local function renderProgress()
  local elapsed = currentElapsed()
  -- streams/web video may report no duration: show elapsed only, no bar
  local hasDuration = state.duration > 0
  progress:set({
    drawing = hasDuration,
    slider = { percentage = hasDuration and math.floor(elapsed / state.duration * 100) or 0 },
  })
  times:set({
    icon = { string = formatTime(elapsed) },
    label = { string = hasDuration and formatTime(state.duration) or "" },
  })
end

-- New artwork file per track: sketchybar caches images by path.
-- Keeps the aspect ratio (YouTube thumbnails are 16:9, album covers square)
-- and sizes/centers the row to match.
local function loadArtwork()
  state.artCounter = state.artCounter + 1
  local file = ART_DIR .. "/cover-" .. state.artCounter .. ".jpg"
  local maxPixels = math.floor(ART_SIZE / ART_SCALE)
  local command = "mkdir -p " .. ART_DIR
    .. " && rm -f " .. ART_DIR .. "/*.jpg"
    .. " && nowplaying-cli get artworkData | base64 -D -o " .. file .. " 2>/dev/null"
    .. " && sips -Z " .. maxPixels .. " " .. file .. " >/dev/null 2>&1"
    .. " && printf 'art:%s %s' $(sips -g pixelWidth -g pixelHeight " .. file .. " | awk '/pixel/ {print $2}')"

  sbar.exec(command, function(result)
    local width, height
    if type(result) == "string" then
      width, height = result:match("art:(%d+) (%d+)")
    end
    width, height = tonumber(width), tonumber(height)
    if not width or not height then
      art:set({ drawing = false })
      return
    end

    local shownWidth = math.floor(width * ART_SCALE)
    local inset = 12 + math.floor((ART_SIZE - shownWidth) / 2)
    art:set({
      drawing = true,
      width = shownWidth,
      padding_left = inset,
      padding_right = inset,
      background = {
        height = math.floor(height * ART_SCALE) + 16,
        image = { string = file },
      },
    })
  end)
end

local function hide()
  state.title = nil
  state.playing = false
  media:set({ drawing = false, update_freq = POLL_IDLE, popup = { drawing = false } })
  group:set({ drawing = false })
end

-- Persist the snapshot anchor so a sketchybar reload doesn't lose the position.
-- If the saved snapshot matches what the player reports, reuse its anchor time.
local ANCHOR_FILE <const> = ART_DIR .. "/anchor"

local function restoreAnchor(title, snapshot, rate)
  local key = title .. "\n" .. tostring(snapshot) .. "\n" .. tostring(rate)
  local file = io.open(ANCHOR_FILE, "r")
  if file then
    local saved = file:read("a")
    file:close()
    local savedKey, savedAnchor = saved:match("^(.*)\n(%d+)$")
    if savedKey == key and tonumber(savedAnchor) then
      state.anchor = tonumber(savedAnchor)
      return
    end
  end
  os.execute("mkdir -p " .. ART_DIR)
  file = io.open(ANCHOR_FILE, "w")
  if file then
    file:write(key .. "\n" .. state.anchor)
    file:close()
  end
end

-- Update -------------------------------------------------------------------
local inFlight = false

refresh = function()
  -- never stack checks: an idle check can take ~3s
  if inFlight then return end
  inFlight = true
  sbar.exec(INFO_CMD, function(raw)
    inFlight = false
    local title = rawString(raw, "Title")
    if not title then
      hide()
      return
    end

    local artist, album = splitArtist(rawString(raw, "Artist"), rawString(raw, "Album"))
    local rate = rawNumber(raw, "PlaybackRate") or 0
    local snapshot = rawNumber(raw, "ElapsedTime") or 0

    -- re-anchor whenever the player publishes a new snapshot
    if title ~= state.title or snapshot ~= state.snapshot or rate ~= state.snapshotRate then
      state.baseElapsed = snapshot
      state.anchor = os.time()
      state.snapshot = snapshot
      state.snapshotRate = rate
      restoreAnchor(title, snapshot, rate)
    end

    state.playing = rate > 0
    state.duration = rawNumber(raw, "Duration") or 0

    media:set({
      drawing = true,
      update_freq = state.playing and POLL_PLAYING or POLL_IDLE,
      label = { string = artist and (title .. " · " .. artist) or title },
    })
    group:set({ drawing = true })
    fitLabel()
    header:set({ label = { string = title } })
    artistRow:set({ label = { string = artist or "—" } })
    albumRow:set({ label = { string = album or "—" } })

    renderPlayState()
    renderProgress()

    if title ~= state.title then
      state.title = title
      loadArtwork()
    end
  end)
end

-- Play/pause: update the UI immediately, then confirm with the player
local function togglePlayPause()
  local wasPlaying = state.playing
  state.baseElapsed = currentElapsed()
  state.anchor = os.time()
  state.playing = not wasPlaying
  renderPlayState()
  control(wasPlaying and "pause" or "play")
end

playPause:subscribe("mouse.clicked", togglePlayPause)

progress:subscribe("mouse.clicked", function(env)
  if state.duration <= 0 then return end
  local target = math.floor(state.duration * (tonumber(env.PERCENTAGE) or 0) / 100)
  state.baseElapsed = target
  state.anchor = os.time()
  renderProgress()
  control("seek " .. target)
end)

media:subscribe({ "routine", "forced", "system_woke", "media_change" }, refresh)

-- The center group is rebuilt whenever windows open, close or move. Refit
-- after it has been laid out, otherwise the label keeps its old width and
-- overlaps the new group.
local function refitSoon()
  sbar.delay(0.6, fitLabel)
end
media:subscribe({ "front_app_switched", "update_windows", "aerospace_workspace_changed" }, refitSoon)

media:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    togglePlayPause()
    return
  end
  media:set({ popup = { drawing = "toggle" } })
end)

media:subscribe("mouse.exited.global", function()
  media:set({ popup = { drawing = false } })
end)

refresh()
