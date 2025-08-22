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

require("nvim-project-manager.project_search").open_project_search_float(projects)
