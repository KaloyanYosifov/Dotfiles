local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local cursor_plan = sbar.add("item", "widgets.cursor.plan", {
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.cursor.plan,
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

local cursor_demand = sbar.add("item", "widgets.cursor.demand", {
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.cursor.demand,
    color = colors.grey,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.grey,
    string = "–",
  },
  y_offset = -4,
})

local cursor_padding = sbar.add("item", "widgets.cursor.padding", {
  position = "right",
  label = { drawing = false },
})

sbar.add("bracket", "widgets.cursor.bracket", {
  cursor_padding.name,
  cursor_plan.name,
  cursor_demand.name,
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
  sbar.exec("$CONFIG_DIR/plugins/cursor_usage.sh", function(result)
    local plan_str, od_str = result:match("([%d%.]+)%s+([%d%.]+)")
    if not plan_str then return end

    local plan_pct = tonumber(plan_str)
    local od_pct = tonumber(od_str)

    local plan_color = pct_color(plan_pct)
    cursor_plan:set({
      icon = { color = plan_color },
      label = {
        string = string.format("%.1f%%", plan_pct),
        color = plan_color,
      },
    })

    if od_pct > 0 then
      local od_color = pct_color(od_pct)
      cursor_demand:set({
        icon = { color = od_color },
        label = {
          string = string.format("%.1f%%", od_pct),
          color = od_color,
        },
      })
    else
      cursor_demand:set({
        icon = { color = colors.grey },
        label = { string = "–", color = colors.grey },
      })
    end
  end)
end

cursor_plan:subscribe({ "routine", "system_woke" }, update)
