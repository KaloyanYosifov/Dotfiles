local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

-- Workspaces that are always shown even when empty
local persistent = { ["1"] = true, ["2"] = true, ["3"] = true }

local spaces = {}
local brackets = {}
local prev_workspace = nil


local function remove_space(sid)
  if not spaces[sid] or persistent[sid] then return end
  sbar.exec("sketchybar --remove space." .. sid
    .. " --remove " .. brackets[sid]
    .. " --remove space.padding." .. sid)
  spaces[sid] = nil
  brackets[sid] = nil
end

local function add_space(sid)
  if spaces[sid] then return end

  local space = sbar.add("item", "space." .. sid, "left", {
    icon = {
      font = { family = settings.font.numbers },
      string = sid,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
    popup = { background = { border_width = 5, border_color = colors.black } }
  })

  spaces[sid] = space

  local bracket_name = "space.bracket." .. sid
  local space_bracket = sbar.add("bracket", bracket_name, { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })
  brackets[sid] = bracket_name

  sbar.add("item", "space.padding." .. sid, "left", {
    script = "",
    width = settings.group_paddings,
  })

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left = 5,
    padding_right = 0,
    background = {
      drawing = true,
      image = { corner_radius = 9, scale = 0.2 }
    }
  })

  space:subscribe("aerospace_workspace_change", function(env)
    local selected = env.FOCUSED_WORKSPACE == sid
    space:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 }
    })
    space_bracket:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      space_popup:set({ background = { image = "space." .. sid } })
      space:set({ popup = { drawing = "toggle" } })
    else
      if env.BUTTON ~= "right" then
        sbar.exec("aerospace workspace " .. sid)
      end
    end
  end)

  space:subscribe("mouse.exited", function(_)
    space:set({ popup = { drawing = false } })
  end)
end

-- Add existing workspaces at startup
local handle = io.popen("aerospace list-workspaces --all")
local result = handle:read("*a")
handle:close()

for sid in result:gmatch("[^\n]+") do
  add_space(sid)
end

-- Watch for workspace changes
local space_watcher = sbar.add("item", { drawing = false, updates = true })

space_watcher:subscribe("aerospace_workspace_change", function(env)
  local new_sid = env.FOCUSED_WORKSPACE
  local old_sid = prev_workspace
  prev_workspace = new_sid

  -- New workspace: add it, then wait until it's registered before moving it
  if new_sid and not spaces[new_sid] then
    add_space(new_sid)

    -- Defer move to next tick after sbar.add calls are flushed to the server
    sbar.delay(0, function()
      local sorted = {}
      for s in pairs(spaces) do table.insert(sorted, s) end
      table.sort(sorted, function(a, b) return (tonumber(a) or a) < (tonumber(b) or b) end)

      local idx = nil
      for i, s in ipairs(sorted) do
        if s == new_sid then idx = i; break end
      end

      if idx and idx > 1 then
        local prev = sorted[idx - 1]
        sbar.exec("sketchybar"
          .. " --move space." .. new_sid .. " after space.padding." .. prev
          .. " --move " .. brackets[new_sid] .. " after space." .. new_sid
          .. " --move space.padding." .. new_sid .. " after " .. brackets[new_sid])
      end
    end)
    return
  end

  -- Check if the previous workspace is now empty and remove it
  if old_sid and not persistent[old_sid] and spaces[old_sid] then
    sbar.exec("aerospace list-windows --workspace " .. old_sid .. " --count", function(count)
      if tonumber(count) == 0 then
        remove_space(old_sid)
      end
    end)
  end
end)

-- App icons per workspace
local space_window_observer = sbar.add("item", { drawing = false, updates = true })

space_window_observer:subscribe("space_windows_change", function(env)
  local icon_line = ""
  local no_app = true
  for app, _ in pairs(env.INFO.apps) do
    no_app = false
    local lookup = app_icons[app]
    icon_line = icon_line .. (lookup or app_icons["Default"])
  end

  if no_app then icon_line = " —" end

  local sid = tostring(env.INFO.space)
  if spaces[sid] then
    sbar.animate("tanh", 10, function()
      spaces[sid]:set({ label = icon_line })
    end)
  end
end)

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = currently_on and icons.switch.off or icons.switch.on
  })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = { color = { alpha = 1.0 }, border_color = { alpha = 1.0 } },
      icon = { color = colors.bg1 },
      label = { width = "dynamic" }
    })
  end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = { color = { alpha = 0.0 }, border_color = { alpha = 0.0 } },
      icon = { color = colors.grey },
      label = { width = 0 }
    })
  end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
