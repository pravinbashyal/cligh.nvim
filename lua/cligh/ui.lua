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

-- Create PR form in a floating window with inline editing
function M.create_pr_form(callback)
  -- First, ask for draft status
  vim.ui.select(
    { "Ready for Review", "Draft" },
    { 
      prompt = "PR Status:",
      format_item = function(item)
        if item == "Draft" then
          return "📝 Draft - Work in progress"
        else
          return "✅ Ready for Review - Ready to merge"
        end
      end
    },
    function(choice)
      if not choice then
        vim.notify("PR creation cancelled", vim.log.levels.WARN)
        return
      end
      
      local is_draft = choice == "Draft"
      
      -- Now open the editor
      M.open_pr_editor(is_draft, callback)
    end
  )
end

-- Open the PR editor buffer
function M.open_pr_editor(is_draft, callback)
  local config = require('cligh').config
  local width = math.floor(vim.o.columns * (config.ui.width or 0.75))
  local height = math.floor(vim.o.lines * (config.ui.height or 0.75))
  
  -- Create main buffer for the form
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_name(buf, 'PR-FORM')
  
  -- Calculate position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  -- Window options
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = config.ui.border or 'rounded',
    title = is_draft and " 📝 Create Pull Request (Draft) " or " ✅ Create Pull Request (Ready for Review) ",
    title_pos = "center",
  }
  
  -- Create window
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, 'winblend', config.ui.winblend or 0)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
  
  -- Form state
  local form_state = {
    draft = is_draft,
    buf = buf,
    win = win,
  }
  
  -- Initial template
  local template = {
    "# Pull Request",
    "",
    "## Title",
    "",
    "<!-- Enter your PR title below -->",
    "",
    "",
    "## Description",
    "",
    "<!-- Enter your PR description below. Markdown is fully supported! -->",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "---",
    "",
    "**Instructions:**",
    "- Edit the title and description above using Vim commands",
    "- Submit: <Ctrl-s> or :w",
    "- Cancel: :q",
  }
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)
  
  -- Move cursor to title line
  vim.api.nvim_win_set_cursor(win, {6, 0})
  
  -- Function to parse form data from buffer
  local function parse_form_data()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local title_lines = {}
    local desc_lines = {}
    local in_title = false
    local in_desc = false
    
    for i, line in ipairs(lines) do
      if line:match("^## Title") then
        in_title = true
        in_desc = false
      elseif line:match("^## Description") then
        in_title = false
        in_desc = true
      elseif line:match("^%-%-%-") or line:match("^%*%*Instructions:") then
        -- Stop parsing at the instructions section
        break
      elseif in_title and not line:match("^<!%-%-") and line ~= "" then
        table.insert(title_lines, line)
      elseif in_desc and not line:match("^<!%-%-") and line ~= "" then
        table.insert(desc_lines, line)
      end
    end
    
    -- Clean up title (take first non-empty line)
    local title = ""
    for _, line in ipairs(title_lines) do
      if line:match("%S") then
        title = line
        break
      end
    end
    
    -- Clean up description (remove empty lines at start/end)
    while #desc_lines > 0 and not desc_lines[1]:match("%S") do
      table.remove(desc_lines, 1)
    end
    while #desc_lines > 0 and not desc_lines[#desc_lines]:match("%S") do
      table.remove(desc_lines)
    end
    
    local description = table.concat(desc_lines, "\n")
    
    return {
      title = title,
      body = description,
      draft = form_state.draft,  -- Use the draft status from form_state
    }
  end
  
  -- Submit handler
  local function submit()
    local form_data = parse_form_data()
    
    if form_data.title == "" then
      vim.notify("PR title is required!", vim.log.levels.ERROR)
      return
    end
    
    -- Close window
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    
    -- Call callback with form data
    callback(form_data)
  end
  
  -- Cancel handler
  local function cancel()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    vim.notify("PR creation cancelled", vim.log.levels.WARN)
  end
  
  -- Set up keymaps
  local opts = { noremap = true, silent = true, buffer = buf }
  
  -- Submit with Ctrl-s
  vim.keymap.set('n', '<C-s>', submit, opts)
  vim.keymap.set('i', '<C-s>', function()
    vim.cmd('stopinsert')
    submit()
  end, opts)
  
  -- Prevent actual write, use it as submit
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = submit,
  })
  
  -- Handle quit
  vim.api.nvim_create_autocmd("QuitPre", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        local form_data = parse_form_data()
        if form_data.title ~= "" or form_data.body ~= "" then
          vim.ui.select(
            { "Save and create PR", "Discard changes" },
            { prompt = "You have unsaved changes:" },
            function(choice)
              if choice == "Save and create PR" then
                submit()
              else
                cancel()
              end
            end
          )
          return true -- Prevent default quit
        end
      end
    end,
  })
  
  -- Add syntax highlighting for better UX
  vim.api.nvim_buf_call(buf, function()
    vim.cmd([[
      syntax match ClighHeader "^##.*$"
      syntax match ClighComment "^<!--.*-->$"
      syntax match ClighInstructions "^\*\*Instructions:\*\*$"
      syntax match ClighSeparator "^---$"
      
      highlight default link ClighHeader Title
      highlight default link ClighComment Comment
      highlight default link ClighInstructions Question
      highlight default link ClighSeparator Comment
    ]])
  end)
  
  -- Enter insert mode automatically
  vim.cmd('startinsert')
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
