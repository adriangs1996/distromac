local tk_pink = "#fca7ea"
local tkn_palette = require("tokyonight.colors.night")
local tkm_palette = require("tokyonight.colors.moon")

local dp = {
  green = "#8AFF80",
  purple = "#9580FF",
  red = "#E46876",
  pink = "#FF80BF",
  pink2 = "#FF82AF",
  pink3 = "#ff8cc6",
  yellow = "#FFFF80",
  orange = "#FFCA80",
  cyan = "#80FFEA",
  mutedBlue = "#658594",
  peach = "#FFA066",
}

return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      float = {
        transparent = false,
        solid = false,
      },
      no_italic = false,
      transparent_background = true,
      color_overrides = {
        mocha = {
          pink = tkm_palette.purple,
          dpink = tkm_palette.purple,
          green1 = "#4fd6be",
          mauve = tkn_palette.purple,
        },
        macchiato = {
          pink = tk_pink,
          dpink = "#E46876",
        },
      },
      highlight_overrides = {
        all = function(colors)
          return {
            NvimTreeNormal = { fg = colors.none },
            CmpBorder = { fg = "#3e4145" },
          }
        end,
        latte = function(latte)
          return {
            Normal = { fg = latte.base },
          }
        end,

        mocha = function(colors)
          local rp = require("rose-pine.palette")
          return {

            Constant = { fg = colors.peach }, -- (preferred) any constant
            PreProc = { fg = colors.red },

            ["@module"] = { fg = colors.sapphire },
            ["@lsp.type.namespace"] = { fg = colors.sapphire, style = {} },
            ["@tag.tsx"] = { fg = colors.yellow },
            Type = { fg = colors.yellow }, -- (preferred) int, long, char, etcp.
            TSField = { fg = colors.yellow }, -- For fields.
            TSType = { fg = colors.yellow }, -- For types.
            ["@type"] = { fg = colors.yellow }, -- For types.
            TSTypeBuiltin = { fg = colors.yellow }, -- For builtin types.
            ["@type.builtin"] = { fg = colors.yellow }, -- For builtin types.

            ["@lsp.type.enumMember"] = { fg = colors.sky },
            ["@lsp.type.interface"] = { fg = colors.maroon },

            ["@parameter"] = { fg = colors.peach }, -- For parameters of a function.
            ["@variable.parameter"] = { fg = colors.peach }, -- For parameters of a function.

            Conditional = { fg = colors.pink, style = {} },
            Repeat = { fg = colors.pink },
            Exception = { fg = colors.pink },
            ["@keyword.return"] = { fg = colors.pink },
            ["@lsp.mod.controlFlow"] = { fg = colors.pink },

            ["@variable.member.ruby"] = { fg = colors.red },

            ["@field"] = { fg = colors.green1 },
            TSProperty = { fg = colors.green1 },
            ["@property"] = { fg = colors.green1 },
            ["@string.special.symbol.ruby"] = { fg = colors.peach },
            ["@tag.attribute"] = { fg = colors.lavender },

            ["@lsp.type.fieldName"] = { fg = colors.yellow },
          }
        end,
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        bufferline = true,
      },
    },
  },
}
