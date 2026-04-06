-- Custom LspRestart that properly kills old clients to avoid duplicates
vim.api.nvim_create_user_command("LspRestartClean", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  -- Collect client names before stopping
  local client_names = {}
  for _, client in ipairs(clients) do
    client_names[client.name] = true
  end

  -- Stop all clients attached to current buffer (force = true)
  for _, client in ipairs(clients) do
    client.stop(true)
  end

  -- Also kill any orphaned clients with same names (no attached buffers)
  vim.defer_fn(function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client_names[client.name] then
        local attached = vim.lsp.get_buffers_by_client_id(client.id)
        if #attached == 0 then
          client.stop(true)
        end
      end
    end

    -- Now restart by reloading the buffer
    vim.defer_fn(function()
      vim.cmd("edit")
    end, 300)
  end, 300)
end, { desc = "Restart LSP cleanly without duplicates" })

-- Kill all orphaned LSP clients (those with no attached buffers)
vim.api.nvim_create_user_command("LspKillOrphans", function()
  local killed = 0
  for _, client in ipairs(vim.lsp.get_clients()) do
    local attached = vim.lsp.get_buffers_by_client_id(client.id)
    if #attached == 0 then
      vim.notify("Killing orphaned: " .. client.name .. " (id: " .. client.id .. ")")
      client.stop(true)
      killed = killed + 1
    end
  end
  if killed == 0 then
    vim.notify("No orphaned LSP clients found")
  end
end, { desc = "Kill LSP clients with no attached buffers" })
local clipboard_group = vim.api.nvim_create_augroup("ClipboardCommands", { clear = true })
-- Add a keymap to copy the current file path to clipboard
vim.api.nvim_create_autocmd("BufEnter", {
  group = clipboard_group,
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>cp", function()
      -- Get the full path of the current file
      local file_path = vim.fn.expand("%:p")
      -- Copy to system clipboard
      vim.fn.setreg("+", file_path)
      vim.notify("Copied to clipboard: " .. file_path, vim.log.levels.INFO)
    end, { buffer = true, desc = "Copy file path to clipboard" })

    -- Add a keymap to copy the relative file path to clipboard
    vim.keymap.set("n", "<leader>cr", function()
      -- Get the relative path of the current file
      local file_path = vim.fn.expand("%")
      -- Copy to system clipboard
      vim.fn.setreg("+", file_path)
      vim.notify("Copied to clipboard: " .. file_path, vim.log.levels.INFO)
    end, { buffer = true, desc = "Copy relative file path to clipboard" })
  end,
})
