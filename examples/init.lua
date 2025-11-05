-- Example configuration for cligh.nvim
-- Place this in your Neovim config (e.g., ~/.config/nvim/lua/plugins/cligh.lua)

return {
  'yourusername/cligh.nvim',
  config = function()
    require('cligh').setup({
      -- UI appearance
      ui = {
        border = 'rounded',     -- Options: 'single', 'double', 'rounded', 'solid', 'shadow'
        winblend = 0,           -- Window transparency (0-100)
      },
      
      -- Default PR settings
      pr = {
        default_base = nil,     -- Default base branch (nil uses repository default)
      },
      
      -- Optional keybindings
      keymaps = {
        -- PR Management
        { '<leader>gpc', ':ClighPRCreate<CR>', desc = 'Create PR' },
        { '<leader>gpl', ':ClighPRList<CR>', desc = 'List PRs' },
        { '<leader>gpv', ':ClighPRView<CR>', desc = 'View PR' },
        { '<leader>gps', ':ClighPRStatus<CR>', desc = 'PR Status' },
        { '<leader>gpk', ':ClighPRChecks<CR>', desc = 'PR Checks' },
        { '<leader>gpo', ':ClighPRCheckout<CR>', desc = 'Checkout PR' },
      },
    })
  end,
  
  -- Optional: Lazy load on command
  cmd = {
    'ClighPRCreate',
    'ClighPRList',
    'ClighPRView',
    'ClighPRStatus',
    'ClighPRChecks',
    'ClighPRCheckout',
  },
}

