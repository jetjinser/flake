local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_prog = { "@nixFish@" }
config.color_scheme = "Tokyo Night Moon"
config.hide_tab_bar_if_only_one_tab = true

wezterm.on("gui-startup", function(cmd)
  local _tab, _pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.font = wezterm.font_with_fallback({
  {
    family = "MonoLisa Nasy",
    harfbuzz_features = {
      "calt=0", "clig=0", "liga=0",
      "ss02=0", "ss04", "ss06",
      -- ^ disable script variant (ss02) not working (may not configurable)
    },
  },
  "Monaco",
  "DejaVuSansM Nerd Font Mono",
})
config.font_size = 16

config.keys = {
  {
    key = "t",
    mods = "SUPER",
    action = act.SpawnTab("DefaultDomain"),
  },
}

return config
