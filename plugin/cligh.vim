" Vim command definitions for cligh.nvim

if exists('g:loaded_cligh')
  finish
endif
let g:loaded_cligh = 1

" Create PR
command! ClighPRCreate lua require('cligh.commands').create_pr()

" List PRs
command! ClighPRList lua require('cligh.commands').list_prs()

" View PR
command! -nargs=? ClighPRView lua require('cligh.commands').view_pr(<args>)

" PR Status
command! ClighPRStatus lua require('cligh.commands').pr_status()

" PR Checks
command! -nargs=? ClighPRChecks lua require('cligh.commands').pr_checks(<args>)

" Checkout PR
command! -nargs=? ClighPRCheckout lua require('cligh.commands').checkout_pr(<args>)

