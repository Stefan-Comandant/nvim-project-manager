local pickers = require"telescope.pickers"
local finders = require"telescope.finders"
local actions = require"telescope.actions"
local action_state = require"telescope.actions.state"
local conf = require"telescope.config".values

--- Open up a telescope dropdown floating window to search through projects
---@param projects project[]
local function open_project_search_float(projects)
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
        attach_mappings = function (prompt_bufnr, _)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)

                ---@type project
                local entry = action_state.get_selected_entry().value
                vim.cmd("cd " .. entry.root_dir)

                local _, err = io.open("Session.vim", "r")
                if err == nil then
                    vim.cmd("source " .. "Session.vim")
                end
            end)
            return true
        end
    }):find()

end


return { open_project_search_float = open_project_search_float }
