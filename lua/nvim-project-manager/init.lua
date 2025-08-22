local telescope = require("telescope")
local pickers = require"telescope.pickers"
local finders = require"telescope.finders"
local conf = require"telescope.config".values
local actions = require"telescope.actions"
local action_state = require"telescope.actions.state"

---@class shell_cmd
---@field cmd_name? string The title of the command(not what gets executed). When not present, the actual command will be displayed
---@field cmd_string string The actual command that will be run

---@class project
---@field title string
---@field description string?
---@field used_technologies string[]?
---@field commands shell_cmd[]?
---@field dependencies string[]?
---@field root_dir string


---@type shell_cmd
local build_cmd = {
    cmd_name = "Print message",
    cmd_string = "echo hello world",
}

---@type project
local project = {
    title = "C++ HTTP Server",
    used_technologies = {"C++", "linux syscalls"},
    dependencies = {"linux api"},
    root_dir = "~/Programming/C++/HTTP-Server",
    commands = {build_cmd},
}

---@type project[]
local projects = {
    project,
}

pickers.new(require"telescope.themes".get_dropdown(), {
    prompt_title = "Open Project",
    finder = finders.new_table {
        results = projects,

        -- this functions get executed for each value inside `results`
        ---@param entry project
        entry_maker = function (entry)
            return {
                value = entry,
                display = entry.title,
                ordinal = entry.title,
            }
        end,
    },
    sorter = conf.generic_sorter(),
    attach_mappings = function (prompt_bufnr, map)
        actions.select_default:replace(function ()
            actions.close(prompt_bufnr)

            ---@type project
            local entry = action_state.get_selected_entry().value
            vim.cmd("cd " .. entry.root_dir)
        end)
        return true
    end
}):find()
