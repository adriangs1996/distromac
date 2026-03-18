local dp = {
  green = "#8AFF80",
  purple = "#9580FF",
  red = "#E46876",
  pink = "#FF80BF",
  pink2 = "#FF82AF",
  -- pink3 = "#F872DE",
  pink3 = "#ff8cc6",
  yellow = "#FFFF80",
  orange = "#FFCA80",
  cyan = "#80FFEA",
  mutedBlue = "#658594",
  peach = "#FFA066",
}
return {
  "gbprod/nord.nvim",
  config = function()
    -- local tk = require("tokyonight.colors.storm")
    -- local cp = require("catppuccin.palettes.frappe")
    -- local rp = require("rose-pine.palette")

    require("nord").setup({

      -- Override the default colors
      ---@param colors Nord.Palette
      on_colors = function(colors)
        colors.polar_night.origin = "#1e2127"
        -- colors.polar_night.origin = "#191c22"
        colors.polar_night.bright = "#242933"
        colors.polar_night.brighter = "#191c22"
      end,

      transparent = false, -- Enable this to disable setting the background color

      ---@param c Nord.Palette
      on_highlights = function(h, c)
        h["@type.builtin"] = { fg = c.frost.polar_water }
        -- h["@string.special.symbol.ruby"] = { fg = "#7B88A1" }
        h["@string.special.symbol.ruby"] = { fg = c.aurora.yellow }
        h["@variable.parameter"] = { fg = c.snow_storm.origin, italic = true }
        -- h["@variable.parameter"] = { fg = "#7D7C9B", italic = true }

        h["Interface"] = { fg = c.aurora.yellow }
        h["@constant"] = { fg = c.aurora.yellow }
        h["@lsp.type.interface"] = { fg = c.aurora.yellow }
        h["@lsp.type.namespace.ruby"] = { fg = c.aurora.yellow }
        h["@variable.member.ruby"] = { fg = c.aurora.yellow }

        h["@tag.builtin"] = { fg = c.frost.artic_ocean }

        -- h["@variable.member"] = { fg = "#7B88A1" }
        -- h["@property"] = { fg = "#7B88A1" }

        h["Repeat"] = { fg = c.aurora.red, italic = true }
        h["Conditional"] = { fg = c.aurora.red, italic = true }
        h["Exception"] = { fg = c.aurora.red, italic = true }
        h["@keyword.return"] = { fg = c.aurora.red, italic = true }
        h["@keyword.repeat"] = { fg = c.aurora.red, italic = true }
        h["@keyword.conditional"] = { fg = c.aurora.red, italic = true }

        -- h["LineNr"] = { bg = "#1e2127", fg = "#7b88a1" }
        -- h["SignColumn"] = { bg = "#1e2127", fg = "#7b88a1" }
        -- h["FoldColumn"] = { bg = "#1e2127", fg = "#7b88a1" }

        h["Visual"] = { fg = c.none, bg = c.polar_night.brightest } -- Visual mode selection
        h["VisualNOS"] = { fg = c.none, bg = c.polar_night.brightest } -- Visual mode selection when vim is "Not Owning the Selection".
        h["CursorLine"] = { fg = c.snow_storm.brightest, bg = c.polar_night.brighter }
      end,
    })
  end,
}
