local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local mullvad_bin = "/usr/local/bin/mullvad"

-- Only enable widget if mullvad command exists
local mullvad_exists = os.execute("command -v " .. mullvad_bin .. " >/dev/null 2>&1")
if not mullvad_exists then
    return
end

-- Mullvad VPN status widget
local mullvad = sbar.add("item", "widgets.mullvad", {
    position = "right",
    padding_left = 5,
    width = 100,
    icon = {
        font = {
            style = settings.font.style_map["Bold"],
            size = 13.0,
        },
        string = icons.switch.off,
    },
    label = {
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 11.0,
        },
        max_chars = 15,
        string = "off",
    },
    click_script = mullvad_bin .. " toggle",
})

local function update_mullvad_status()
    sbar.exec(mullvad_bin .. " status", function(result)
        -- Get the first line: "Connected" or "Disconnected"
        local state = result:match("(.-)\n")
        state = state:gsub("%s+", "")

        -- Extract country from "Visible location:       Switzerland, Zurich..."
        local country = result:match("Visible location:%s+(.-),")

        if state == "Connected" and country then
            mullvad:set({
                icon = { string = icons.switch.on, color = colors.green },
                label = { string = country, color = colors.green },
            })
        elseif state == "Connecting" or state == "Disconnecting" then
            mullvad:set({
                icon = { string = icons.loading, color = colors.orange },
                label = { string = "...", color = colors.orange },
            })
        else
            mullvad:set({
                icon = { string = icons.switch.off, color = colors.grey },
                label = { string = "off", color = colors.grey },
            })
        end
    end)
end

-- Update status on subscription events
mullvad:subscribe({ "mullvad_update", "system_woke", "force_update" }, function()
    update_mullvad_status()
end)

-- Initial update
update_mullvad_status()
