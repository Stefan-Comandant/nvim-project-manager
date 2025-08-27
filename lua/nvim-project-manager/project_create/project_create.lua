local popup = require("nui.popup")
local input = require("nui.input")

local utils = require("nvim-project-manager.project_create.utils")
local handle_input = utils.handle_input
local get_project_field = utils.get_project_field
local trim_str = utils.trim_str

---@type project
local project = { title = "", root_dir = vim.uv.cwd() }

local popup_options = {
    position = {
        row = 1,
        col = 0
    },
    relative = "cursor",
    size = 30,
    border = {
        style = "double",
        text = {
            top = "hello"
        }
    },
    win_options = {
        winhighlight = "Normal:Normal"
    }
}

-- this will track the value that we are currently asking for with the input
-- project_create_stage = 1 => we are currently asking for the title
-- project_create_stage = 2 => we are currently asking for the description
-- project_create_stage = 3 => we are currently asking for the used technologies
-- ... and so on will all the other fields of the `project`data structure
local project_create_stage = 1


local function create_input()
    return
end

local project_fields = { "Title", "Description", "Useed Technologies", "Shell Commands", "Dependencies", "Root Directory"}

local input1 = input(popup_options, {
    prompt = "",
    default_value = "",
    on_close = function ()
    end,
    on_submit = function (value)
        handle_input(project, value, project_create_stage)
    end,
    on_change = function (value)
    end
})

local sh_cmd_prompt = require("nvim-project-manager.project_create.sh_cmd_prompt")

sh_cmd_prompt.create_layout()

local function create_input_component()
    return input(
        {
            position = {
                row = 1,
                col = 0
            },
            relative = "cursor",
            size = 30,
            border = {
                style = "double",
                text = {
                    top = project_fields[project_create_stage]
                }
            },
            win_options = {
                winhighlight = "Normal:Normal"
            }
        },
        {
            prompt = "",
            default_value = get_project_field(project_create_stage , project),
            -- on_close = function ()
            -- end,
            -- on_submit = function (value)
            --     handle_input(value, project_create_stage)
            -- end,
            -- on_change = function (value)
            -- end
        })
end


-- update the input1 variable with a new input component, do the keymaps, then mount the component
local function render_input()
    input1 = create_input_component()

    input1:map("i", "<CR>", function ()
        local value = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        value = trim_str(value, { " ", "\n", "\r"})
        handle_input(project, value, project_create_stage)

        input1:unmount()

        project_create_stage = project_create_stage + 1
        render_input()

        input1:mount()
    end, { noremap = true })

    input1:map("i", "<C-h>", function ()
        if project_create_stage > 1 then
            project_create_stage = project_create_stage - 1
            input1:unmount()
            render_input()
        end
    end, { noremap = true })

    input1:map("i", "<C-l>", function ()
        if project_create_stage < 6 then
            project_create_stage = project_create_stage + 1
            input1:unmount()
            render_input()
        end
    end, { noremap = true })


    input1:mount()
end

-- render_input()
