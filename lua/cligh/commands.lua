-- Command implementations
local gh = require('cligh.gh')
local ui = require('cligh.ui')

local M = {}

-- Validate prerequisites
local function validate()
  if not gh.is_installed() then
    vim.notify("GitHub CLI (gh) is not installed. Please install it first.", vim.log.levels.ERROR)
    return false
  end
  
  if not gh.is_authenticated() then
    vim.notify("You are not authenticated with GitHub CLI. Run 'gh auth login' first.", vim.log.levels.ERROR)
    return false
  end
  
  if not gh.is_git_repo() then
    vim.notify("Current directory is not a git repository.", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Prepare branch for PR (commit and push)
local function prepare_branch_for_pr(callback)
  local current_branch = gh.get_current_branch()
  
  -- Check for uncommitted changes
  if gh.has_uncommitted_changes() then
    local count = gh.get_uncommitted_changes_count()
    local message = string.format("You have %d uncommitted change%s. Commit them before creating PR?", 
                                  count, count > 1 and "s" or "")
    
    vim.ui.select(
      { "Yes, commit all changes", "No, create PR without committing", "Cancel" },
      { prompt = message },
      function(choice)
        if not choice or choice == "Cancel" then
          vim.notify("PR creation cancelled", vim.log.levels.WARN)
          return
        end
        
        if choice == "Yes, commit all changes" then
          local config = require('cligh').config
          local default_msg = config.git.commit_message_template or "chore: prepare for PR"
          vim.ui.input({ prompt = "Commit message: ", default = default_msg }, function(commit_msg)
            if not commit_msg or commit_msg == "" then
              vim.notify("Commit cancelled - no message provided", vim.log.levels.WARN)
              return
            end
            
            vim.notify("Committing changes...", vim.log.levels.INFO)
            local success, result = gh.commit_all_changes(commit_msg)
            
            if not success then
              vim.notify("Failed to commit changes:\n" .. result, vim.log.levels.ERROR)
              return
            end
            
            vim.notify("Changes committed successfully", vim.log.levels.INFO)
            
            -- Now check if branch needs to be pushed
            check_and_push_branch(callback)
          end)
        else
          -- User chose to create PR without committing
          check_and_push_branch(callback)
        end
      end
    )
  else
    -- No uncommitted changes, just check if we need to push
    check_and_push_branch(callback)
  end
end

-- Check if branch is pushed and push if needed
function check_and_push_branch(callback)
  local current_branch = gh.get_current_branch()
  
  if not gh.has_remote_tracking() then
    local message = string.format("Branch '%s' has not been pushed to remote. Push it now?", current_branch)
    
    vim.ui.select(
      { "Yes, push branch", "Cancel" },
      { prompt = message },
      function(choice)
        if not choice or choice == "Cancel" then
          vim.notify("PR creation cancelled", vim.log.levels.WARN)
          return
        end
        
        vim.notify("Pushing branch to remote...", vim.log.levels.INFO)
        local success, result = gh.push_current_branch()
        
        if not success then
          vim.notify("Failed to push branch:\n" .. result, vim.log.levels.ERROR)
          return
        end
        
        vim.notify("Branch pushed successfully", vim.log.levels.INFO)
        callback()
      end
    )
  else
    -- Branch is already pushed, proceed
    callback()
  end
end

-- Create a pull request
function M.create_pr()
  if not validate() then
    return
  end
  
  local current_branch = gh.get_current_branch()
  vim.notify("Preparing to create PR from branch: " .. current_branch, vim.log.levels.INFO)
  
  -- Prepare branch (handle uncommitted changes and push)
  prepare_branch_for_pr(function()
    -- Show PR creation form
    ui.create_pr_form(function(form_data)
      vim.notify("Creating pull request...", vim.log.levels.INFO)
      
      local opts = {
        title = form_data.title,
        body = form_data.body,
        draft = form_data.draft,
      }
      
      local success, result = gh.create_pr(opts)
      
      if success then
        vim.notify("Pull request created successfully!\n" .. result, vim.log.levels.INFO)
      else
        vim.notify("Failed to create pull request:\n" .. result, vim.log.levels.ERROR)
      end
    end)
  end)
end

-- List pull requests
function M.list_prs(opts)
  if not validate() then
    return
  end
  
  vim.notify("Fetching pull requests...", vim.log.levels.INFO)
  
  local prs, err = gh.list_prs(opts)
  
  if err then
    vim.notify("Failed to fetch pull requests:\n" .. err, vim.log.levels.ERROR)
    return
  end
  
  ui.show_pr_list(prs)
end

-- View a specific PR
function M.view_pr(number)
  if not validate() then
    return
  end
  
  if not number then
    vim.ui.input({ prompt = "Enter PR number: " }, function(input)
      if input then
        M.view_pr(tonumber(input))
      end
    end)
    return
  end
  
  vim.notify("Fetching PR #" .. number .. "...", vim.log.levels.INFO)
  
  local pr, err = gh.get_pr(number)
  
  if err then
    vim.notify("Failed to fetch PR:\n" .. err, vim.log.levels.ERROR)
    return
  end
  
  ui.show_pr_details(pr)
end

-- Show PR status
function M.pr_status()
  if not validate() then
    return
  end
  
  vim.notify("Fetching PR status...", vim.log.levels.INFO)
  
  local status, err = gh.get_pr_status()
  
  if err then
    vim.notify("Failed to fetch PR status:\n" .. err, vim.log.levels.ERROR)
    return
  end
  
  -- Display status information
  local lines = {}
  
  if status.currentBranch and #status.currentBranch > 0 then
    table.insert(lines, "Current Branch PRs:")
    for _, pr in ipairs(status.currentBranch) do
      table.insert(lines, string.format("  #%d - %s", pr.number, pr.title))
    end
  else
    table.insert(lines, "No PR associated with current branch")
  end
  
  if status.createdBy and #status.createdBy > 0 then
    table.insert(lines, "")
    table.insert(lines, "Created by you:")
    for _, pr in ipairs(status.createdBy) do
      table.insert(lines, string.format("  #%d - %s", pr.number, pr.title))
    end
  end
  
  if status.needsReview and #status.needsReview > 0 then
    table.insert(lines, "")
    table.insert(lines, "Needs your review:")
    for _, pr in ipairs(status.needsReview) do
      table.insert(lines, string.format("  #%d - %s", pr.number, pr.title))
    end
  end
  
  local message = table.concat(lines, "\n")
  vim.notify(message, vim.log.levels.INFO)
end

-- Show PR checks
function M.pr_checks(number)
  if not validate() then
    return
  end
  
  if not number then
    vim.ui.input({ prompt = "Enter PR number: " }, function(input)
      if input then
        M.pr_checks(tonumber(input))
      end
    end)
    return
  end
  
  vim.notify("Fetching PR checks for #" .. number .. "...", vim.log.levels.INFO)
  
  local checks = gh.get_pr_checks(number)
  ui.show_pr_checks(checks)
end

-- Checkout a PR
function M.checkout_pr(number)
  if not validate() then
    return
  end
  
  if not number then
    vim.ui.input({ prompt = "Enter PR number to checkout: " }, function(input)
      if input then
        M.checkout_pr(tonumber(input))
      end
    end)
    return
  end
  
  vim.notify("Checking out PR #" .. number .. "...", vim.log.levels.INFO)
  
  local success, result = gh.checkout_pr(number)
  
  if success then
    vim.notify("Successfully checked out PR #" .. number .. "\n" .. result, vim.log.levels.INFO)
  else
    vim.notify("Failed to checkout PR:\n" .. result, vim.log.levels.ERROR)
  end
end

return M

