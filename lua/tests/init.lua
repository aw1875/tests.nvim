local util = require('tests.util')

local M = {}

-- Setup
-- @param opts - Setup options
-- @return nil
M.setup = function(opts)
    -- TODO Implement
    P(opts)
end

-- Highlight Results
-- @return nil
local highlight = function()
    local highlights = {
        ["Passed"] = "DiffAdd",
        ["Failed"] = "Error",
    }

    for match, group in pairs(highlights) do
        vim.fn.matchadd(group, match)
    end
end


-- Run test cases
-- @return nil
M.run_tests = function()
    -- Setup Test Cases
    util.setup_tests()

    -- Get Results
    local results, title = util.run_tests()

    -- Create Window
    local win_info = util.open_window(title)

    -- Window Setup
    vim.api.nvim_buf_set_option(win_info.bufnr, "filetype", "Results")
    vim.api.nvim_buf_set_option(win_info.bufnr, "bufhidden", "delete")
    vim.api.nvim_buf_set_lines(win_info.bufnr, 0, -1, true, results)
    vim.api.nvim_buf_set_option(win_info.bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(win_info.bufnr, "filetype", "Results")

    -- Close Window Keymaps
    vim.api.nvim_buf_set_keymap(win_info.bufnr, "n", "q", ":q!<CR>", { silent = true, noremap = true })
    vim.api.nvim_buf_set_keymap(win_info.bufnr, "n", "<esc>", ":q!<CR>", { silent = true, noremap = true })

    -- Highlight results
    highlight()
end

return M
