local plenary = require('plenary')

local util = {}

-- Local Variables
local height = 10
local width = 60
local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

-- Run Individual Test Case
-- @param case - Current Test Case
-- @param folder - Current Working Folder
-- @return case and success
local run_test = function(case, folder)

    local output = vim.fn.readfile("./testcases/answer-" .. folder .. "." .. case)
    local expected, outcome, errors = {}, {}, {}
    local success = false

    for i, val in ipairs(output) do
        expected[i] = " " .. val
    end

    local function on_stdout(_, data, _)
        for i, val in ipairs(data) do
            data[i] = " " .. val
        end

        vim.list_extend(outcome, data)

        if outcome[#outcome] == " " then
            outcome[#outcome] = nil
        end
    end

    local function on_stderr(_, data, _)
        for i, val in ipairs(data) do
            data[i] = " " .. val
        end

        vim.list_extend(errors, data)
        errors[#errors] = nil
    end

    local function on_exit(_, exit_code, _)
        if exit_code == 0 then
            if (table.concat(expected) == table.concat(outcome)) then
                success = true
            else
                success = false
            end
        else
            success = false
        end
    end

    -- Run executable
    local job_id = vim.fn.jobstart("java " .. util._current_file, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
        data_buffered = true,
    })

    vim.fn.chansend(job_id, vim.list_extend(vim.fn.readfile("./testcases/input-" .. util._folder .. "." .. case), { "" }))

    -- Wait till `timeout`
    local len = vim.fn.jobwait({ job_id }, 5000)
    if len[1] == -1 then
        vim.fn.jobstop(job_id)
    end


    return case, success
end

-- Open Test Results Window
-- @param title - Window Title
-- @return table
util.open_window = function(title)
    local bufnr = vim.api.nvim_create_buf(false, false)
    local TestCases_cmd_win_id, _ = plenary.popup.create(bufnr, {
        title = title,
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    return {
        bufnr = bufnr,
        win_id = TestCases_cmd_win_id
    }
end

-- Setup Test Cases
-- @return nil
util.setup_tests = function()
    util._current_file = vim.fn.expand("%:t")
    util._folder = string.match(vim.fn.getcwd(), "(%d+)/?$")
end

-- Iterate and run test cases
-- @return results and title
util.run_tests = function()
    local results = {}
    local passed_cases, total_cases = 0, 0
    local title = "TestCases"

    for i, _ in ipairs(plenary.scandir.scan_dir('./testcases', {
        search_pattern = "input-",
        depth = 1,
    })) do
        local case, success = run_test(i, util._folder)

        if success then
            passed_cases = passed_cases + 1
        end
        total_cases = total_cases + 1

        table.insert(results, "Test Case #" .. case .. ": " .. (success and "Passed" or "Failed"))
    end

    -- Setup Title
    if passed_cases == total_cases then
        title = "Passed All Tests"
    else
        title = "Passed " .. passed_cases .. "/" .. total_cases
    end

    return results, title
end

return util
