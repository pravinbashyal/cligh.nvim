# cligh.nvim - Feature Overview

## 🎯 Core Features

### 1. **Inline PR Editor** (⭐ Main Feature)
- Real Vim buffer for PR creation
- Full markdown syntax highlighting
- Complete Vim editing capabilities
- All motions and commands available (hjkl, dd, yy, p, visual mode, macros, etc.)
- Save with `:w` or `Ctrl-s`
- Cancel with `:q` or `Esc`

### 2. **Smart Git Operations**
- **Auto-detection of uncommitted changes**
  - Shows count of pending changes
  - Prompts to commit before creating PR
  - Customizable default commit message
  
- **Auto-detection of unpushed branches**
  - Checks if branch exists on remote
  - Prompts to push branch automatically
  - Uses `git push -u origin <branch>`

### 3. **PR Management**
- **Create PRs** - With full Vim editing
- **List PRs** - View all PRs in floating window
- **View PR Details** - See PR info with markdown formatting
- **Check PR Status** - See your PRs and review requests
- **View PR Checks** - See CI/CD status
- **Checkout PRs** - Switch to PR branch locally

### 4. **Beautiful UI**
- Floating windows with customizable borders
- Configurable size (width/height as percentage)
- Transparency support (winblend)
- Syntax highlighting for form elements
- Clean, modern interface

## 📋 Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `:ClighPRCreate` | Create a new pull request | `:ClighPRCreate` |
| `:ClighPRList` | List all pull requests | `:ClighPRList` |
| `:ClighPRView` | View specific PR details | `:ClighPRView 123` |
| `:ClighPRStatus` | Show PR status for current branch | `:ClighPRStatus` |
| `:ClighPRChecks` | View PR CI checks | `:ClighPRChecks 123` |
| `:ClighPRCheckout` | Checkout PR locally | `:ClighPRCheckout 123` |

## ⌨️ Keybindings in PR Editor

### Normal Mode
- `hjkl` - Navigate (all Vim motions work)
- `i/a/o/O` - Enter insert mode
- `dd/yy/p` - Delete/yank/paste lines
- `Space` - Toggle Draft/Ready (on Status line)
- `Ctrl-s` - Submit PR
- `Esc` - Cancel
- `:w` - Submit PR
- `:q` - Cancel

### Insert Mode
- Standard Vim insert mode
- `Ctrl-s` - Submit PR (from insert mode)

### Visual Mode
- All visual mode commands work
- Select, copy, paste, delete as normal

## ⚙️ Configuration Options

### UI Settings
```lua
ui = {
  border = 'rounded',      -- Border style
  winblend = 0,            -- Transparency
  width = 0.75,            -- Window width (%)
  height = 0.75,           -- Window height (%)
}
```

### PR Settings
```lua
pr = {
  default_base = nil,      -- Base branch
  auto_commit = true,      -- Auto-commit prompt
  auto_push = true,        -- Auto-push prompt
  template = nil,          -- Custom template
}
```

### Git Settings
```lua
git = {
  commit_message_template = "chore: prepare for PR"
}
```

## 🎨 PR Editor Template Structure

```markdown
# Create Pull Request

## Title
<your-pr-title>

## Description
<your-pr-description-with-markdown>

## Settings
Status: [ ] Draft  [x] Ready for Review
```

## 🚀 Workflow Example

1. Make changes to your code
2. Run `:ClighPRCreate`
3. Plugin checks for uncommitted changes → Prompts to commit
4. Plugin checks if branch is pushed → Prompts to push
5. Editor opens with template
6. Edit PR title and description using Vim
7. Toggle Draft/Ready with Space
8. Press `Ctrl-s` or `:w` to create PR
9. Done! 🎉

## 💡 Pro Tips

1. **Use Vim Macros**: Record macros for repetitive PR descriptions
2. **Visual Mode**: Select and format multiple lines easily
3. **Yank/Paste**: Copy common descriptions between PRs
4. **Markdown Preview**: Use your favorite markdown preview plugin
5. **Custom Template**: Create a PR template file and configure it
6. **Keybindings**: Set up custom keybindings for quick access

## 🔌 Integration

Works seamlessly with:
- GitHub CLI (`gh`)
- Git
- Any markdown preview plugin
- Your existing Neovim config
- All Vim plugins

## 📦 Dependencies

- Neovim >= 0.7.0
- GitHub CLI (`gh`) installed and authenticated
- Git repository

## 🎯 Design Philosophy

**Native Vim Experience**
- No compromise on editing power
- Leverage full Vim capabilities
- Feel natural to Vim users

**Smart Automation**
- Handle git operations automatically
- Reduce manual steps
- Prevent common errors

**Beautiful UI**
- Modern floating windows
- Clean, minimal interface
- Customizable appearance

**Developer Friendly**
- Simple commands
- Clear documentation
- Extensible configuration

