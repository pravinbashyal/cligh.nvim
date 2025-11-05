-- Main plugin entry point
local M = {}

M.config = {
  -- UI settings
  ui = {
    border = 'rounded',      -- 'single', 'double', 'rounded', 'solid', 'shadow'
    winblend = 0,            -- 0-100, transparency
    width = 0.75,            -- 0.0-1.0, percentage of screen width
    height = 0.75,           -- 0.0-1.0, percentage of screen height
  },
  -- Default PR settings
  pr = {
    default_base = nil,      -- nil means use repository default branch
    auto_commit = true,      -- Prompt to commit uncommitted changes
    auto_push = true,        -- Prompt to push unpushed branches
    template = nil,          -- Custom PR template file path
  },
  -- Git settings
  git = {
    commit_message_template = "chore: prepare for PR", -- Default commit message
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

-- Get configuration value
function M.get_config(key)
  local keys = vim.split(key, '.', { plain = true })
  local value = M.config
  
  for _, k in ipairs(keys) do
    if value[k] == nil then
      return nil
    end
    value = value[k]
  end
  
  return value
end

return M

