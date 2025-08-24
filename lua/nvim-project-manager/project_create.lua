local popup = require("nui.popup")
local layout = require("nui.layout")
local input = require("nui.input")
local trim_str = require("nvim-project-manager.utils").trim_str

---@type project
local project = { title = "", root_dir = "" }

---This functions takes the submited value from the prompt and the project creation stage, then stores the data inside a single project variable, which will then be saved to disk
---@param value string The string that was typed into the prompt
---@param project_create_stage number This parameters indicates what field of the project structure the value will be stored in
local function handle_input(value, project_create_stage)

    -- check if we are editing the `title` field
    if project_create_stage == 1 then
        project.title = value
    -- check if we are editing the `description` field
    elseif project_create_stage == 2 then
        project.description = trim_str(value, { " "})
    -- check if we are editing the `used_technologies` field
    elseif project_create_stage == 3 then

        local str_i = 1
        local i = 1

        ---@type string[]
        local values = {}

        while true do
            if i >= string.len(value) then
                if i > str_i then
                    local val = string.sub(value, str_i, i)
                    val = trim_str(val, { ",", " "})
                    if string.len(val) > 0 then
                        table.insert(values, val)
                    end
                end

                break
            end

            local ch = string.sub(value, i, i)

            if ch == ',' then
                local val = string.sub(value, str_i, i)
                val = trim_str(val, { ",", " "})
                if string.len(val) > 0 then
                    table.insert(values, val)
                end
                str_i = i
            end

            i = i + 1
        end
        project.used_technologies = values

    -- check if we are editing the `root_dir` field
    elseif project_create_stage == 6 then
        value = trim_str(value, {" "})
        project.root_dir = value
    end


    -- write the data to a json file

    local file = io.open("foo.json", "w")
    if file == nil then
        print("ERROR::FAILED TO SAVE PROJECT TO FILE\n")
        return
    end

    local json_str = vim.json.encode(project, {})

    file:write(json_str)

    file:close()
end

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

---Returns the field of a `project` structure based on the creation stage
---@param create_stage number
---@param proj project
local function get_project_field(create_stage, proj)
    if create_stage == 1 then
        return proj.title
    end

    if create_stage == 2 then
        return proj.description
    end


    if create_stage == 3 then
        if proj.used_technologies == nil or #proj.used_technologies == 0 then
            return ""
        end

        local str_val = ""

        for _, v in pairs(proj.used_technologies) do
            str_val = str_val .. v .. ", "
        end

        return str_val
    end

    if create_stage == 4 then
        return proj.commands
    end

    if create_stage == 5 then
        return proj.dependencies
    end


    if create_stage == 6 then
        return proj.root_dir
    end
end

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
        handle_input(value, project_create_stage)
    end,
    on_change = function (value)
    end
})

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
        handle_input(value, project_create_stage)

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

render_input()
