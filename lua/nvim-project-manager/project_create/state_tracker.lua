-- Whether or not there is currently a project being created
-- local is_creating_project = false

-----@type project
--local project = { title = "", root_dir = vim.uv.cwd() }


local trim_str = require("nvim-project-manager.utils").trim_str


-- this will track the value that we are currently asking for with the input
-- project_create_stage = 1 => we are currently asking for the title
-- project_create_stage = 2 => we are currently asking for the description
-- project_create_stage = 3 => we are currently asking for the used technologies
-- ... and so on will all the other fields of the `project`data structure
-- local project_create_stage = 1



---This functions takes the submited value from the prompt and the project creation stage, then stores the data inside a single project variable, which will then be saved to disk
---@param project project The structure that holds information about the project that is currently being created/edited
---@param value string The string that was typed into the prompt
---@param project_create_stage number This parameters indicates what field of the project structure the value will be stored in
local function handle_input(project, value, project_create_stage)

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

---Returns the field of a `project` structure based on the creation stage
---@param create_stage number
---@param proj project
local function get_project_field(proj, create_stage)
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


return { is_creating_project = is_creating_project }
