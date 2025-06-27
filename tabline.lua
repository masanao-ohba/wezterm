-- tabline.wez
local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        -- theme = "catppuccin-mocha",
        theme = "cyberpunk",
        -- theme = "Cobalt Neon",
        section_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        component_separators = {
            left = wezterm.nerdfonts.ple_forwardslash_separator,
            right = wezterm.nerdfonts.ple_forwardslash_separator,
        },
        tab_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        -- color_overrides = {
        theme_overrides = {
            tab = {
                active = { fg = "#091833", bg = "#59c2c6" },
            },
        },
    },
    sections = {
        tab_active = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
        tab_inactive = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "󰉋",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
    },
})
