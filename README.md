# cligh.nvim

A Neovim plugin for GitHub CLI (`gh`) with a beautiful floating window interface for creating and managing pull requests.

## Features

- 🚀 **Create Pull Requests** with an intuitive floating window form
  - Enter PR title and description
  - Toggle between Draft and Ready for Review
  - Easy keyboard navigation
  
- 📋 **List Pull Requests** in your repository
- 👁️ **View PR Details** in a formatted buffer
- ✅ **Check PR Status** and CI checks
- 🔄 **Checkout PRs** locally with a single command

## Prerequisites

- Neovim >= 0.7.0
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
  ```bash
  # Install gh (macOS)
  brew install gh
  
  # Authenticate
  gh auth login
  ```

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/cligh.nvim',
  config = function()
    require('cligh').setup({
      -- Optional configuration
      ui = {
        border = 'rounded',  -- 'single', 'double', 'rounded', 'solid', 'shadow'
        winblend = 0,        -- 0-100 transparency
      },
      keymaps = {
        -- Optional keybindings
        { '<leader>gpc', ':ClighPRCreate<CR>', desc = 'Create PR' },
        { '<leader>gpl', ':ClighPRList<CR>', desc = 'List PRs' },
        { '<leader>gps', ':ClighPRStatus<CR>', desc = 'PR Status' },
      },
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/cligh.nvim',
  config = function()
    require('cligh').setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'yourusername/cligh.nvim'

lua << EOF
require('cligh').setup()
EOF
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:ClighPRCreate` | Open the PR creation form |
| `:ClighPRList` | List all pull requests |
| `:ClighPRView [number]` | View details of a specific PR |
| `:ClighPRStatus` | Show PR status for current branch |
| `:ClighPRChecks [number]` | View CI checks for a PR |
| `:ClighPRCheckout [number]` | Checkout a PR locally |

### Creating a Pull Request

1. Run `:ClighPRCreate`
2. A floating window will appear with a form
3. Press `Enter` or `i` on each field to edit:
   - **Title**: Enter your PR title
   - **Description**: Enter your PR description
   - **Status**: Press `Space` to toggle between Draft and Ready for Review
4. Navigate fields with `Tab` / `Shift+Tab`
5. Press `Ctrl+s` to submit the PR
6. Press `Esc` or `q` to cancel

### Keyboard Shortcuts in PR Form

- `Tab` - Move to next field
- `Shift+Tab` - Move to previous field
- `Enter` or `i` - Edit current field
- `Space` - Toggle Draft/Ready (when on Status field)
- `Ctrl+s` - Submit PR
- `Esc` or `q` - Cancel

### Viewing PRs

Run `:ClighPRList` to see all pull requests. Use arrow keys to navigate and press `Enter` to view details.

### Example Keybindings

Add these to your Neovim configuration:

```lua
-- Using lazy.nvim setup
require('cligh').setup({
  keymaps = {
    { '<leader>gpc', ':ClighPRCreate<CR>', desc = 'Create PR' },
    { '<leader>gpl', ':ClighPRList<CR>', desc = 'List PRs' },
    { '<leader>gpv', ':ClighPRView<CR>', desc = 'View PR' },
    { '<leader>gps', ':ClighPRStatus<CR>', desc = 'PR Status' },
    { '<leader>gpk', ':ClighPRChecks<CR>', desc = 'PR Checks' },
    { '<leader>gpo', ':ClighPRCheckout<CR>', desc = 'Checkout PR' },
  },
})

-- Or set them manually
vim.keymap.set('n', '<leader>gpc', ':ClighPRCreate<CR>', { desc = 'Create PR' })
vim.keymap.set('n', '<leader>gpl', ':ClighPRList<CR>', { desc = 'List PRs' })
```

## Configuration

```lua
require('cligh').setup({
  -- UI appearance
  ui = {
    border = 'rounded',     -- Window border style
    winblend = 0,           -- Window transparency (0-100)
  },
  
  -- Default PR settings
  pr = {
    default_base = nil,     -- Default base branch (nil = repo default)
  },
  
  -- Optional keybindings
  keymaps = {
    -- Add your preferred keybindings here
  },
})
```

## Troubleshooting

### "GitHub CLI (gh) is not installed"

Install the GitHub CLI:
```bash
# macOS
brew install gh

# Linux (Debian/Ubuntu)
sudo apt install gh

# Windows
winget install GitHub.cli
```

### "You are not authenticated with GitHub CLI"

Authenticate with GitHub:
```bash
gh auth login
```

### "Current directory is not a git repository"

Make sure you're in a git repository:
```bash
git init
# or
cd /path/to/your/repo
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Built on top of [GitHub CLI (`gh`)](https://cli.github.com/)
- Inspired by the Neovim plugin ecosystem

## Related Projects

- [octo.nvim](https://github.com/pwntester/octo.nvim) - Edit and review GitHub issues and pull requests
- [gh.nvim](https://github.com/ldelossa/gh.nvim) - A fully featured GitHub integration

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/yourusername/cligh.nvim/issues).

