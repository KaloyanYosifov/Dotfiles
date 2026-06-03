local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local claude_session = sbar.add("item", "widgets.claude.session", {
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.claude.session,
    color = colors.grey,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.grey,
    string = "–%",
  },
  y_offset = 4,
  update_freq = 60,
})

local claude_week = sbar.add("item", "widgets.claude.week", {
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.claude.week,
    color = colors.grey,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.grey,
    string = "–%",
  },
  y_offset = -4,
})

local claude_padding = sbar.add("item", "widgets.claude.padding", {
  position = "right",
  label = { drawing = false },
})

sbar.add("bracket", "widgets.claude.bracket", {
  claude_padding.name,
  claude_session.name,
  claude_week.name,
}, {
  background = { color = colors.bg1 },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local function pct_color(pct)
  if pct < 50 then return colors.green
  elseif pct < 75 then return colors.yellow
  elseif pct < 90 then return colors.orange
  else return colors.red
  end
end

local function update()
  sbar.exec("$CONFIG_DIR/plugins/claude_usage.sh", function(result)
    local session_str, week_str = result:match("([%d%.]+)%s+([%d%.]+)")
    if not session_str then return end

    local session_pct = tonumber(session_str)
    local week_pct = tonumber(week_str)

    local session_color = pct_color(session_pct)
    claude_session:set({
      icon = { color = session_color },
      label = {
        string = string.format("%g%%", session_pct),
        color = session_color,
      },
    })

    local week_color = pct_color(week_pct)
    claude_week:set({
      icon = { color = week_color },
      label = {
        string = string.format("%g%%", week_pct),
        color = week_color,
      },
    })
  end)
end

claude_session:subscribe({ "routine", "system_woke" }, update)
