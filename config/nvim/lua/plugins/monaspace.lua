return {
  "hydepwns/mona.nvim",
  lazy = false,
  build = ":MonaInstall variable all",
  opts = {
    font_features = {
      texture_healing = true,
      ligatures = { enable = true, stylistic_sets = { equals = true, arrows = true } },
      character_variants = { zero_style = 2 },
    },
    terminal_config = { auto_generate = true, terminals = { "ghostty" } },
  },
}
