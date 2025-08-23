local popup = require("nui.popup")
local layout = require("nui.layout")
local input = require("nui.input")
local trim_str = require("nvim-project-manager.utils").trim_str

---@type project
local project = { title = "", root_dir = "" }


local str = "   ,bar,   "
local new_str = trim_str(str, { " ", ","})

print('a' .. new_str .. 'a' .. '\n')

--

-- local str = "hello"

-- local startp, endp = string.find(str, "a", 1, true)
-- print(startp)

---This functions takes the submited value from the prompt and the project creation stage, then stores the data inside a single project variable, which will then be saved to disk
---@param value string The string that was typed into the prompt
---@param project_create_stage number This parameters indicates what field of the project structure the value will be stored in
local function handle_input(value, project_create_stage)

    -- check if we are editing the `title` field
    if project_create_stage == 1 then
        project.title = value
    -- check if we are editing the `description` field
    elseif project_create_stage == 2 then
        project.description = value
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
    end

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
local project_create_stage = 3

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

input1:mount()
