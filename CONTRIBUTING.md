# Contributing to cligh.nvim

Thank you for your interest in contributing to cligh.nvim! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/pravinbashyal/cligh.nvim.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes in Neovim
6. Commit your changes: `git commit -am 'Add some feature'`
7. Push to the branch: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Setup

### Prerequisites

- Neovim >= 0.7.0
- GitHub CLI (`gh`) installed and authenticated
- Git repository for testing

### Testing Locally

1. Clone the repository to your local machine
2. Add the plugin path to your Neovim config:

```lua
-- In your Neovim config
vim.opt.runtimepath:append('~/path/to/cligh.nvim')
require('cligh').setup()
```

3. Restart Neovim and test the commands

## Code Style

- Use 2 spaces for indentation
- Follow Lua naming conventions (snake_case for functions, PascalCase for modules)
- Add comments for complex logic
- Keep functions focused and small

## Project Structure

```
cligh.nvim/
├── lua/cligh/
│   ├── init.lua       # Main plugin entry point
│   ├── gh.lua         # GitHub CLI wrapper functions
│   ├── ui.lua         # UI components (floating windows, forms)
│   └── commands.lua   # Command implementations
├── plugin/
│   └── cligh.vim      # Vim command definitions
├── doc/
│   └── cligh.txt      # Help documentation
└── examples/
    └── init.lua       # Example configuration
```

## Adding New Features

### Adding a New GitHub CLI Command

1. Add the wrapper function in `lua/cligh/gh.lua`:
```lua
function M.your_new_function(opts)
  -- Call gh CLI command
  -- Parse and return results
end
```

2. Add the command implementation in `lua/cligh/commands.lua`:
```lua
function M.your_new_command()
  -- Validate prerequisites
  -- Call gh function
  -- Display results
end
```

3. Add the Vim command in `plugin/cligh.vim`:
```vim
command! YourNewCommand lua require('cligh.commands').your_new_command()
```

4. Update documentation in `doc/cligh.txt` and `README.md`

### Adding UI Components

1. Add UI functions in `lua/cligh/ui.lua`
2. Follow the existing patterns for floating windows
3. Ensure proper keyboard navigation
4. Add close handlers (Esc, q)

## Testing

Before submitting a PR, please test:

1. All existing commands still work
2. Your new feature works as expected
3. Error handling works properly
4. UI is responsive and keyboard navigation works
5. No Lua errors appear in `:messages`

## Documentation

- Update `README.md` for user-facing changes
- Update `doc/cligh.txt` for help documentation
- Add code comments for complex logic
- Update `CHANGELOG.md` if present

## Commit Messages

Use clear, descriptive commit messages:

- `feat: add support for PR reviews`
- `fix: handle empty PR descriptions`
- `docs: update installation instructions`
- `refactor: simplify UI rendering logic`

## Pull Request Guidelines

- Provide a clear description of the changes
- Reference any related issues
- Include screenshots for UI changes
- Ensure all tests pass
- Keep PRs focused on a single feature/fix

## Feature Requests

- Open an issue with the `enhancement` label
- Describe the feature and use case
- Discuss implementation approach if possible

## Bug Reports

Include:
- Neovim version (`:version`)
- GitHub CLI version (`gh --version`)
- Operating system
- Steps to reproduce
- Error messages (check `:messages`)
- Minimal config to reproduce

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## Questions?

- Open an issue with the `question` label
- Check existing issues and documentation first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉

