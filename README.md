# cligh.nvim

A Neovim plugin for GitHub CLI (`gh`) with a beautiful inline editor for creating and managing pull requests. Edit PRs directly in Vim with full markdown support and native editing power.

## ✨ Demo

<!-- TODO: Add screenshot/demo GIF here -->
```
┌─── ✅ Create Pull Request (Ready for Review) ───────────┐
│ # Pull Request                                          │
│                                                          │
│ ## Title                                                 │
│                                                          │
│ feat: add new feature                                   │
│                                                          │
│ ## Description                                           │
│                                                          │
│ This PR adds a new feature that...                      │
│ - Implements X                                           │
│ - Fixes Y                                                │
│                                                          │
│ ─────────────────────────────────────────────────────── │
│ :wq Submit | :w Submit | :q Cancel | Ctrl-s Submit     │
└─────────────────────────────────────────────────────────┘
```

## Features

- 🚀 **Create Pull Requests** with a beautiful inline editor
  - **Full Vim editing** - Edit title and description directly in a real Vim buffer
  - **Markdown support** - Syntax highlighting for PR descriptions
  - **Inline editing** - Use all Vim commands, motions, and keybindings
  - Toggle between Draft and Ready for Review
  - **Automatic branch preparation**: Handles uncommitted changes and pushes branches automatically
  
- 📋 **List Pull Requests** in your repository
- 👁️ **View PR Details** in a formatted markdown buffer
- ✅ **Check PR Status** and CI checks
- 🔄 **Checkout PRs** locally with a single command
- 🔧 **Smart Git Operations**: Automatically commits and pushes changes when needed
- ✨ **Native Vim Experience**: No compromise on editing power

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
  'pravinbashyal/cligh.nvim',
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
  'pravinbashyal/cligh.nvim',
  config = function()
    require('cligh').setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'pravinbashyal/cligh.nvim'

lua << EOF
require('cligh').setup()
EOF
```

## Usage

### The PR Creation Experience

When you run `:ClighPRCreate`, you first choose the status (Draft or Ready for Review), then you get a beautiful floating window with a markdown-formatted template:

```markdown
# Pull Request

## Title

<!-- Enter your PR title below -->


## Description

<!-- Enter your PR description below. Markdown is fully supported! -->



---

**Instructions:**
- Edit the title and description above using Vim commands
- Submit: :w or :wq or <Ctrl-s>
- Cancel: :q or :q!
```

You can:
- Use **any Vim command** to edit (`hjkl`, `dd`, `yy`, `p`, etc.)
- Write **markdown** with syntax highlighting
- Use **visual mode**, **macros**, and all Vim features
- **Navigate naturally** with Vim motions
- **Save with `:w` or `:wq`** to create the PR (just like a regular file!)
- The window title shows whether it's a Draft or Ready for Review
- **`:wq` works perfectly** - submit and close in one command!

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
2. The plugin will automatically check:
   - **Uncommitted changes**: If found, you'll be prompted to commit them
   - **Unpushed branch**: If the branch isn't pushed to remote, you'll be prompted to push it
3. Choose **PR status**: Select "Ready for Review" or "Draft"
4. A beautiful floating window opens with an **inline editable buffer**
5. Edit the PR directly in Vim with full editing capabilities:
   - **Title**: Edit in the Title section using all Vim commands
   - **Description**: Write markdown with full syntax highlighting
   - The window title shows your selected status (Draft or Ready for Review)
6. Use all your favorite Vim motions, commands, and keybindings
7. Submit the PR:
   - `:w` - Save and submit PR
   - `:wq` - Save, submit PR, and close (natural Vim workflow!)
   - `Ctrl+s` - Quick submit shortcut
8. Cancel/Quit:
   - `:q` - Quit (prompts if there are unsaved changes)
   - `:q!` - Force quit without saving
   - `Esc` - Only exits insert mode (standard Vim behavior)

**Smart Branch Management**: The plugin automatically handles uncommitted changes and ensures your branch is pushed to remote before creating the PR, eliminating the common "branch not pushed" error.

**Inline Editing**: Unlike traditional forms, the PR editor is a real Vim buffer with markdown support. Use `dd`, `yy`, `p`, visual mode, macros, and any Vim feature you love!

### Keyboard Shortcuts in PR Form

- **All Vim commands** - Full Vim editing support (hjkl, w, b, dd, yy, p, etc.)
- `i/a/o/O` - Enter insert mode (standard Vim)
- `Esc` - Return to normal mode (standard Vim behavior)
- `:w` - Submit PR
- `:wq` - Submit PR and quit (just like saving a file!)
- `Ctrl+s` - Quick submit shortcut
- `:q` - Quit (prompts if unsaved changes)
- `:q!` - Force quit without saving

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

Full configuration with all available options:

```lua
require('cligh').setup({
  -- UI appearance
  ui = {
    border = 'rounded',      -- 'single', 'double', 'rounded', 'solid', 'shadow'
    winblend = 0,            -- Window transparency (0-100)
    width = 0.75,            -- Window width as percentage of screen (0.0-1.0)
    height = 0.75,           -- Window height as percentage of screen (0.0-1.0)
  },
  
  -- PR settings
  pr = {
    default_base = nil,      -- Default base branch (nil = repository default)
    auto_commit = true,      -- Prompt to commit uncommitted changes
    auto_push = true,        -- Prompt to push unpushed branches
    template = nil,          -- Path to custom PR template file
  },
  
  -- Git settings
  git = {
    commit_message_template = "chore: prepare for PR", -- Default commit message
  },
  
  -- Optional keybindings
  keymaps = {
    { '<leader>gpc', ':ClighPRCreate<CR>', desc = 'Create PR' },
    { '<leader>gpl', ':ClighPRList<CR>', desc = 'List PRs' },
    { '<leader>gps', ':ClighPRStatus<CR>', desc = 'PR Status' },
  },
})
```

### Minimal Configuration

If you're happy with the defaults, just call setup:

```lua
require('cligh').setup()
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

If you encounter any issues or have questions, please [open an issue](https://github.com/pravinbashyal/cligh.nvim/issues).

