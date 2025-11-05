-- Main plugin entry point
local M = {}

M.config = {
  -- UI settings
  ui = {
    border = 'rounded',
    winblend = 0,
  },
  -- Default PR settings
  pr = {
    default_base = nil, -- nil means use repository default
  },
  -- Keybindings (optional)
  keymaps = {
    -- Example: { '<leader>gpc', ':ClighPRCreate<CR>', desc = 'Create PR' }
  },
}

function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  
  -- Set up user keymaps if provided
  if M.config.keymaps then
    for _, keymap in ipairs(M.config.keymaps) do
      vim.keymap.set('n', keymap[1], keymap[2], { desc = keymap.desc, silent = true })
    end
  end
end

return M

