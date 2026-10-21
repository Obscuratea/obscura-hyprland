--!nonstrict
-- Claude usage meter. Bar text = 5-hour limit; hover tooltip = weekly limit.
-- Data comes from the statusline hook's cache file, so this does no network calls.
-- A window whose reset time has passed is shown as 0%: usage restarts from zero.

local dataFile = "~/.cache/obscura/claude-usage.json"

local function span(s)
  local d, h, m = s // 86400, (s % 86400) // 3600, (s % 3600) // 60
  if d > 0 then return `{d}d {h}h` end
  if h > 0 then return `{h}h {m}m` end
  return `{m}m`
end

-- Effective percentage for a window, treating an expired window as empty.
local function pct(win, now)
  if win == nil or win.used_percentage == nil then return nil end
  if win.resets_at ~= nil and win.resets_at <= now then return 0 end
  return math.floor(win.used_percentage + 0.5)
end

local function describe(win, now)
  local p = pct(win, now)
  if p == nil then return "no data" end
  if win.resets_at ~= nil and win.resets_at > now then
    return `{p}% · {span(win.resets_at - now)}`
  end
  return `{p}%`
end

function update()
  noctalia.setUpdateInterval(30000)
  barWidget.setGlyph("gauge")

  local raw = noctalia.readFile(dataFile)
  local data = nil
  if raw ~= nil then data = noctalia.json.decode(raw) end
  if data == nil then
    barWidget.setText("5h --")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setTooltip("No usage data yet. Send a message in Claude Code to record it.")
    return
  end

  local now = os.time()
  local five = pct(data.five_hour, now)
  barWidget.setText(five ~= nil and `5h {five}%` or "5h --")

  local role = "primary"
  if five ~= nil and five >= 90 then role = "error"
  elseif five ~= nil and five >= 75 then role = "tertiary" end
  barWidget.setGlyphColor(role)

  local age = now - (data.updated or now)
  local fresh = age < 90 and "just now" or `{span(age)} ago`
  barWidget.setTooltip({
    { key = "Weekly · resets", value = describe(data.seven_day, now) },
    { key = "5-hour · resets", value = describe(data.five_hour, now) },
    { key = "Updated", value = fresh },
  })
end
