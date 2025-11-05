-- Floating window UI for forms
local M = {}

-- Create a centered floating window
function M.create_float(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  
  -- Calculate position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', opts.filetype or 'cligh')
  
  -- Window options
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = opts.border or 'rounded',
  }
  
  -- Create window
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'winblend', opts.winblend or 0)
  
  return buf, win
end

-- Create PR form in a floating window
function M.create_pr_form(callback)
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.7)
  
  local buf, win = M.create_float({
    width = width,
    height = height,
    border = 'rounded',
  })
  
  -- Form state
  local form_data = {
    title = "",
    body = "",
    draft = false,
  }
  
  local current_field = 1
  local fields = {
    { name = "title", label = "PR Title", start_line = 3, height = 1 },
    { name = "body", label = "PR Description", start_line = 6, height = height - 12 },
    { name = "draft", label = "Status", start_line = height - 4, height = 1 },
  }
  
  -- Render the form
  local function render()
    local lines = {}
    table.insert(lines, "┌─ Create Pull Request " .. string.rep("─", width - 25))
    table.insert(lines, "")
    
    -- Title field
    table.insert(lines, "Title:")
    table.insert(lines, form_data.title)
    table.insert(lines, "")
    
    -- Body field
    table.insert(lines, "Description:")
    local body_lines = vim.split(form_data.body, "\n", { plain = true })
    for _, line in ipairs(body_lines) do
      table.insert(lines, line)
    end
    
    -- Pad to maintain consistent layout
    while #lines < height - 6 do
      table.insert(lines, "")
    end
    
    -- Draft toggle
    table.insert(lines, "")
    local status_text = form_data.draft and "[x] Draft  [ ] Ready for Review" or "[ ] Draft  [x] Ready for Review"
    table.insert(lines, "Status: " .. status_text)
    table.insert(lines, "")
    table.insert(lines, "[Tab] Next field  [Shift+Tab] Previous field  [Ctrl+s] Submit  [Esc] Cancel")
    
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  end
  
  -- Set up keymaps
  local opts_map = { noremap = true, silent = true, buffer = buf }
  
  -- Tab navigation
  vim.keymap.set('n', '<Tab>', function()
    current_field = current_field % #fields + 1
    vim.api.nvim_win_set_cursor(win, {fields[current_field].start_line, 0})
  end, opts_map)
  
  vim.keymap.set('n', '<S-Tab>', function()
    current_field = current_field - 1
    if current_field < 1 then current_field = #fields end
    vim.api.nvim_win_set_cursor(win, {fields[current_field].start_line, 0})
  end, opts_map)
  
  -- Edit fields
  vim.keymap.set('n', 'i', function()
    local field = fields[current_field]
    if field.name == "title" then
      vim.ui.input({ prompt = "PR Title: ", default = form_data.title }, function(input)
        if input then
          form_data.title = input
          render()
        end
      end)
    elseif field.name == "body" then
      vim.ui.input({ prompt = "PR Description: ", default = form_data.body }, function(input)
        if input then
          form_data.body = input
          render()
        end
      end)
    elseif field.name == "draft" then
      form_data.draft = not form_data.draft
      render()
    end
  end, opts_map)
  
  vim.keymap.set('n', '<CR>', function()
    local field = fields[current_field]
    if field.name == "title" then
      vim.ui.input({ prompt = "PR Title: ", default = form_data.title }, function(input)
        if input then
          form_data.title = input
          render()
        end
      end)
    elseif field.name == "body" then
      vim.ui.input({ prompt = "PR Description: ", default = form_data.body }, function(input)
        if input then
          form_data.body = input
          render()
        end
      end)
    elseif field.name == "draft" then
      form_data.draft = not form_data.draft
      render()
    end
  end, opts_map)
  
  -- Toggle draft status with space
  vim.keymap.set('n', '<Space>', function()
    if fields[current_field].name == "draft" then
      form_data.draft = not form_data.draft
      render()
    end
  end, opts_map)
  
  -- Submit
  vim.keymap.set('n', '<C-s>', function()
    if form_data.title == "" then
      vim.notify("PR title is required", vim.log.levels.ERROR)
      return
    end
    vim.api.nvim_win_close(win, true)
    callback(form_data)
  end, opts_map)
  
  -- Cancel
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, opts_map)
  
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, opts_map)
  
  -- Initial render
  render()
  
  -- Set cursor to first field
  vim.api.nvim_win_set_cursor(win, {fields[1].start_line, 0})
end

-- Display PR list in a floating window
function M.show_pr_list(prs)
  if not prs or #prs == 0 then
    vim.notify("No pull requests found", vim.log.levels.INFO)
    return
  end
  
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.min(#prs + 4, math.floor(vim.o.lines * 0.8))
  
  local buf, win = M.create_float({
    width = width,
    height = height,
    border = 'rounded',
  })
  
  local lines = {}
  table.insert(lines, "┌─ Pull Requests " .. string.rep("─", width - 18))
  table.insert(lines, "")
  
  for _, pr in ipairs(prs) do
    local status_icon = pr.state == "OPEN" and "●" or "○"
    local draft_text = pr.isDraft and "[DRAFT] " or ""
    local line = string.format("%s #%d %s%s (@%s)", status_icon, pr.number, draft_text, pr.title, pr.author.login)
    table.insert(lines, line)
  end
  
  table.insert(lines, "")
  table.insert(lines, "[Enter] View details  [q/Esc] Close")
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  
  -- Store PR data for selection
  vim.api.nvim_buf_set_var(buf, 'cligh_prs', prs)
  
  -- Keymaps
  local opts = { noremap = true, silent = true, buffer = buf }
  
  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local line_num = cursor[1]
    if line_num > 2 and line_num <= #prs + 2 then
      local pr_index = line_num - 2
      local pr = prs[pr_index]
      vim.api.nvim_win_close(win, true)
      require('cligh.commands').view_pr(pr.number)
    end
  end, opts)
  
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, opts)
end

-- Display PR details in a buffer
function M.show_pr_details(pr)
  -- Create a new buffer for PR details
  local buf = vim.api.nvim_create_buf(false, true)
  
  local lines = {}
  table.insert(lines, "# PR #" .. pr.number .. ": " .. pr.title)
  table.insert(lines, "")
  table.insert(lines, "**Author:** @" .. pr.author.login)
  table.insert(lines, "**State:** " .. pr.state)
  table.insert(lines, "**Branch:** " .. pr.headRefName .. " → " .. pr.baseRefName)
  
  if pr.isDraft then
    table.insert(lines, "**Status:** Draft")
  else
    table.insert(lines, "**Status:** Ready for Review")
  end
  
  if pr.reviewDecision then
    table.insert(lines, "**Review Decision:** " .. pr.reviewDecision)
  end
  
  if pr.mergeable then
    table.insert(lines, "**Mergeable:** " .. pr.mergeable)
  end
  
  table.insert(lines, "**URL:** " .. pr.url)
  table.insert(lines, "")
  table.insert(lines, "## Description")
  table.insert(lines, "")
  
  if pr.body and pr.body ~= "" then
    local body_lines = vim.split(pr.body, "\n", { plain = true })
    for _, line in ipairs(body_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "_No description provided_")
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_name(buf, "PR #" .. pr.number)
  
  -- Open in a split
  vim.cmd('split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  
  -- Set keymap to close
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { noremap = true, silent = true, buffer = buf })
end

-- Show PR checks in a floating window
function M.show_pr_checks(checks_text)
  local lines = vim.split(checks_text, "\n", { plain = true })
  
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.min(#lines + 4, math.floor(vim.o.lines * 0.7))
  
  local buf, win = M.create_float({
    width = width,
    height = height,
    border = 'rounded',
  })
  
  local display_lines = {}
  table.insert(display_lines, "┌─ PR Checks " .. string.rep("─", width - 14))
  table.insert(display_lines, "")
  
  for _, line in ipairs(lines) do
    table.insert(display_lines, line)
  end
  
  table.insert(display_lines, "")
  table.insert(display_lines, "[q/Esc] Close")
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  
  -- Keymaps
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })
  
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })
end

return M

