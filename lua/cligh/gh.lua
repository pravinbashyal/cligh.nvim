-- GitHub CLI wrapper functions
local M = {}

-- Check if gh CLI is installed
function M.is_installed()
  return vim.fn.executable("gh") == 1
end

-- Check if user is authenticated
function M.is_authenticated()
  local handle = io.popen("gh auth status 2>&1")
  local result = handle:read("*a")
  handle:close()
  return result:match("Logged in") ~= nil
end

-- Check if current directory is a git repository
function M.is_git_repo()
  local handle = io.popen("git rev-parse --is-inside-work-tree 2>&1")
  local result = handle:read("*a")
  handle:close()
  return result:match("true") ~= nil
end

-- Get current branch name
function M.get_current_branch()
  local handle = io.popen("git branch --show-current 2>&1")
  local result = handle:read("*a")
  handle:close()
  return vim.trim(result)
end

-- Create a pull request
function M.create_pr(opts)
  local cmd = {"gh", "pr", "create"}
  
  if opts.title then
    table.insert(cmd, "--title")
    table.insert(cmd, opts.title)
  end
  
  if opts.body then
    table.insert(cmd, "--body")
    table.insert(cmd, opts.body)
  end
  
  if opts.draft then
    table.insert(cmd, "--draft")
  end
  
  if opts.base then
    table.insert(cmd, "--base")
    table.insert(cmd, opts.base)
  end
  
  local result = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0
  
  return success, result
end

-- List pull requests
function M.list_prs(opts)
  opts = opts or {}
  local limit = opts.limit or 30
  
  local cmd = string.format("gh pr list --json number,title,state,author,headRefName,isDraft,url --limit %d", limit)
  
  local handle = io.popen(cmd .. " 2>&1")
  local result = handle:read("*a")
  handle:close()
  
  if vim.v.shell_error ~= 0 then
    return nil, result
  end
  
  local ok, prs = pcall(vim.json.decode, result)
  if not ok then
    return nil, "Failed to parse JSON response"
  end
  
  return prs, nil
end

-- Get PR details
function M.get_pr(number)
  local cmd = string.format(
    "gh pr view %d --json number,title,body,state,author,headRefName,baseRefName,isDraft,url,mergeable,reviewDecision",
    number
  )
  
  local handle = io.popen(cmd .. " 2>&1")
  local result = handle:read("*a")
  handle:close()
  
  if vim.v.shell_error ~= 0 then
    return nil, result
  end
  
  local ok, pr = pcall(vim.json.decode, result)
  if not ok then
    return nil, "Failed to parse JSON response"
  end
  
  return pr, nil
end

-- Get PR checks/status
function M.get_pr_checks(number)
  local cmd = string.format("gh pr checks %d 2>&1", number)
  
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  
  return result
end

-- Checkout a PR
function M.checkout_pr(number)
  local cmd = string.format("gh pr checkout %d 2>&1", number)
  
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  
  local success = vim.v.shell_error == 0
  return success, result
end

-- Get PR status (for current branch)
function M.get_pr_status()
  local cmd = "gh pr status --json currentBranch,createdBy,needsReview 2>&1"
  
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  
  if vim.v.shell_error ~= 0 then
    return nil, result
  end
  
  local ok, status = pcall(vim.json.decode, result)
  if not ok then
    return nil, "Failed to parse JSON response"
  end
  
  return status, nil
end

return M

