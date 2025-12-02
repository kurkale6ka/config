local wezterm = require('wezterm')
local config = {}

config.font = wezterm.font('JetBrains Mono')
config.font_size = 10
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' } -- disable ligatures

config.color_scheme = 'Atom One Dark'

return config
