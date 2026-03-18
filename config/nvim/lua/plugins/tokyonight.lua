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
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  transparent = true,
  opts = {},
  config = function()
    local bg = "#1e1e2e"

    local palettef = require("catppuccin.palettes.frappe")
    local palettem = require("catppuccin.palettes.macchiato")
    local palette = require("catppuccin.palettes.mocha")
    local tk = require("tokyonight.colors.night")
    local tkm = require("tokyonight.colors.moon")

    require("tokyonight").setup({
      style = "night",
      on_colors = function(colors)
        -- colors.bg = "#1a1b26"
        colors.bg_dark = colors.bg
        colors.blue = tkm.blue
        -- colors.bg_dark1 = "#24283b"
        -- colors.bg_popup = tkm.bg
        -- colors.magenta = tkm.purple
        -- colors.green1 = tkm.green2
        colors.bg_sidebar = colors.bg
        colors.bg_float = colors.bg

        colors.blue5 = palettem.sapphire
        colors.yellow = tkm.yellow
      end,

      on_highlights = function(h, c)
        h["FloatBorder"] = { fg = c.border_highlight, bg = c.bg }
        h["FloatTitle"] = { fg = c.fg, bg = c.bg, bold = true }

        -- Noice cmdline/confirm borders — same treatment as FloatBorder
        h["NoiceCmdlinePopupBorder"] = { fg = c.border_highlight, bg = c.bg }
        h["NoiceCmdlinePopupBorderSearch"] = { fg = c.yellow, bg = c.bg }
        h["NoiceCmdlinePopupBorderInput"] = { fg = c.yellow, bg = c.bg }
        h["NoiceCmdlinePopupBorderLua"] = { fg = c.blue1, bg = c.bg }
        h["NoiceCmdlinePopupBorderHelp"] = { fg = c.green1, bg = c.bg }
        h["NoiceCmdlinePopupBorderFilter"] = { fg = c.magenta, bg = c.bg }
        h["NoiceConfirmBorder"] = { fg = c.border_highlight, bg = c.bg }
        h["NoiceCmdlinePopupTitle"] = { fg = c.border_highlight, bg = c.bg }
        h["NoicePopupBorder"] = { fg = c.border_highlight, bg = c.bg }
        h["NoicePopup"] = { bg = c.bg }
        h["NormalFloat"] = { bg = c.bg }

        -- h["Type"] = { fg = dp.pink }
        h["Type"] = { fg = c.blue5 }
        h["@constructor"] = { fg = c.blue5 }
        -- h["Constant"] = { fg = tk.orange }
        -- h["Special"] = { fg = tk.blue }
        -- -- h["Function"] = { fg = palettef.yellow }
        --
        -- -- h["String"] = { fg = "#4da97b" }
        --
        -- h["PreProc"] = { fg = tk.purple }
        -- h["@operator"] = { fg = tk.purple }
        -- h["Statement"] = { fg = tk.purple }
        h["@keyword"] = { fg = c.purple }
        h["@keyword.function"] = { fg = c.purple }
        h["Statement"] = { fg = c.purple }
        h["@lsp.mod.controlFlow"] = { fg = c.magenta }
        h["@string.special.symbol.ruby"] = { fg = c.orange }
        h["PreProc"] = { fg = c.red }
        h["@lsp.type.interface"] = { fg = palette.yellow }
        --
        -- h["@property"] = { fg = palettef.sapphire }
        -- h["@lsp.type.fieldName"] = { fg = palettef.sapphire }
        -- h["@variable.member"] = { fg = palettef.sapphire }
        -- h["@variable.member.ruby"] = { fg = palettef.sapphire }
        --
        -- h["@variable.parameter"] = { fg = tk.yellow }
        --
        -- h["Interface"] = { fg = palettem.peach }
        -- h["@lsp.type.interface"] = { fg = palettem.peach }
        -- h["@lsp.type.namespace"] = { fg = palettem.peach }
        --
        -- h["Conditional"] = { fg = tk.purple }
        -- h["Repeat"] = { fg = tk.purple }
        -- h["Exception"] = { fg = tk.purple }
        -- h["@keyword.return"] = { fg = tk.purple }
      end,
    })

    vim.api.nvim_set_hl(0, "MyCustomType", { fg = palettem.peach })
    -- vim.api.nvim_set_hl(0, "Decorators", { fg = palettef.blue })
    vim.api.nvim_set_hl(0, "Decorators", { link = "@type.builtin" })
    vim.api.nvim_set_hl(0, "get", { fg = palettef.flamingo })
    vim.api.nvim_set_hl(0, "post", { fg = palettef.flamingo })
    vim.api.nvim_set_hl(0, "put", { fg = palettef.flamingo })
    vim.api.nvim_set_hl(0, "delete", { fg = palettef.flamingo })
    vim.api.nvim_set_hl(0, "sign", { fg = palettef.flamingo })
    vim.api.nvim_set_hl(0, "inject", { fg = palettef.flamingo })
    vim.fn.matchadd("MyCustomType", "\\<I[A-Z]\\w\\+\\>")
    vim.fn.matchadd("Decorators", "@\\w\\+\\(?:\\.\\w\\+\\)*")
    vim.fn.matchadd("get", "^\\s*get\\> ")
    vim.fn.matchadd("post", "^\\s*post\\> ")
    vim.fn.matchadd("put", "^\\s*put\\> ")
    vim.fn.matchadd("delete", "^\\s*delete\\> ")
    vim.fn.matchadd("sign", "^\\s*sign\\> ")
    vim.fn.matchadd("inject", "^\\s*inject\\> ")
  end,
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin-frappe",
      -- colorscheme = "catppuccin-macchiato",
      -- colorscheme = "catppuccin",
      -- colorscheme = "tokyonight-night",
    },
  },
}
