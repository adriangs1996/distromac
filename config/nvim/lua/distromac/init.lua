-- Watch for theme changes and auto-reload colorscheme
local theme_file = vim.fn.expand("~/.config/distromac/current/theme.name")

local function load_distromac_theme()
  -- Invalidate cached module so we re-read the file
  package.loaded["distromac.theme"] = nil
  local ok, theme_lua = pcall(require, "distromac.theme")
  if ok and theme_lua and theme_lua.colorscheme then
    vim.cmd.colorscheme(theme_lua.colorscheme)
  end
end

-- Watch theme.name for changes
local w = vim.uv.new_fs_event()
if w then
  w:start(theme_file, {}, vim.schedule_wrap(function()
    load_distromac_theme()
  end))
end

-- Load on startup
load_distromac_theme()
