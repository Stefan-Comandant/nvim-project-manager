local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Input = require("nui.input")
local Tree = require("nui.tree")
local trim_str = require("nvim-project-manager.utils").trim_str

---@type project
local cur_project = {title = "", root_dir = "", commands = {}}


local lines = {
    "build", "run", "debug",
    "",
    "Press <a> to add a command",
    "Press <d> to delete command",
    "Press <e> to edit command",
    "Press <e> to edit command",
    "Press <e> to edit command",
    "Press <e> to edit command",
    "Press <e> to edit command",
    "Press <e> to edit command",
    "Press <e> to edit command",
}

local function create_cmd_display_box()
    local popup1_options = { size = { width = 30, height = 2 + #lines}, border = { text = { top =  "Shell Commands:"} , style = "double" }, enter = true, buf_options = { modifiable = false} }

    local popup1 = Popup(popup1_options)



    local box = Layout.Box()

    return box
end

local function expand_layout_with_prompt(cmd_display_popup, win_width, tree)
    -- here we want to:
    -- create two inputs
    --      - one containing the command name(map <CR> and <C-l> to switching the cursor to the next input)
    --      - the other one containing the actual shell command
    -- use layout:update() to append the inputs, since it can take any valid nui component as argument
    -- TODO: extract the popup with the command names to a variable and keep it inside every update of the layout. Place the two inputs below this popup. Organize this stuff a little, so it's not a huge mess
    -- 

    local cur_win_index = 1
    local windows = {vim.api.nvim_get_current_win()}

    local input_options_common = {
        size =
        {
            height = "90%",
            width = "80%",
        }
    }


    local cmd_title_input_opt = input_options_common
    cmd_title_input_opt.border = { style = "rounded", text = { top = "Command Title:"}}
    local cmd_title_input = Input(
        cmd_title_input_opt,
        {
            prompt = "",
            default_value = ""
        }
    )


    -- note: this copies the reference to the table. NOT THE VALUE
    local cmd_content_input_opt = input_options_common
    cmd_content_input_opt.border = { style = "rounded", text = { top = "Shell Command to run:"}}

    local cmd_content_input = Input(
        cmd_content_input_opt,
        {
            prompt = "$ ",
            default_value = ""
        }
    )

    cmd_title_input:on("WinEnter", function ()
        cur_win_index = 2
        windows[2] = vim.api.nvim_get_current_win()
        -- print("New win: " .. windows[2] .. '\n')
    end)


    cmd_content_input:on("WinEnter", function ()
        cur_win_index = 3
        windows[3] = vim.api.nvim_get_current_win()
        -- print("New win: " .. windows[3] .. '\n')
    end)


    local layout_opts = {
        relative = "editor",
        position = {
            col = "5%",
            row = 0,
        },
        size = {
            width = "30%",
            height = 10,
        }
    }

    -- NOTE: each component is its own window, with a different window ID
    -- Layout.Box(popup1, { size = { width = "30%", height = #lines + 2} }),

    local input_layout = Layout({
        size = { height = 10, width = "50%"},
        anchor = "NW",
        position = {
            -- the percentages are out of width and height of the layout
            col = 0.5 * win_width,
            row = 0,
        },
        relative = "editor",
    },

    Layout.Box(
        {


            Layout.Box(
                {
                    Layout.Box(
                        -- cmd_title_input, { size = cmd_title_input_opt.size }),
                        cmd_title_input, { size = { height = "50%", width = "100%"} }
                    ),


                    Layout.Box(
                        cmd_content_input, { size = { height = "50%", width = "100%"} })
                    },
                    { dir = "col", size = {width = "80%", height = "100%" } }
                ),
            },

            {
                dir = "row",
                size = { height = 10, width = "100%"}
            }
        )
    )


    cmd_title_input:map("i", "<C-h>", function ()
        cur_win_index = cur_win_index - 1
        vim.api.nvim_set_current_win(windows[cur_win_index])
        input_layout:unmount()
    end)

    cmd_content_input:map("i", "<C-h>", function ()
        cur_win_index = cur_win_index - 1
        vim.api.nvim_set_current_win(windows[cur_win_index])
    end)


    cmd_title_input:map("i", "<C-l>", function ()
        cur_win_index = cur_win_index + 1
        vim.api.nvim_set_current_win(windows[cur_win_index])
    end)

    cmd_content_input:map("i", "<C-l>", function ()
        if cur_win_index < #windows then
            cur_win_index = cur_win_index + 1
            vim.api.nvim_set_current_win(windows[cur_win_index])
        end
    end)

    cmd_display_popup:map("i", "<C-l>", function ()
        if cur_win_index < #windows then
            cur_win_index = cur_win_index + 1
            vim.api.nvim_set_current_win(windows[cur_win_index])
        end
    end)

    cmd_title_input:map("i", "<CR>", function ()
        -- check if the two fields were filled in properly. If so, trim both values, store them inside the project and then update the display of commands
        local cmd_title = trim_str(vim.api.nvim_buf_get_lines(cmd_title_input.bufnr, 0, 1, false)[1], {" "})
        local cmd_content = trim_str(vim.api.nvim_buf_get_lines(cmd_content_input.bufnr, 0, 1, false)[1], {" "})
        cmd_content = cmd_content:sub(3, #cmd_content)

        if cur_project.commands ~= nil then
            table.insert(cur_project.commands, {cmd_name = cmd_title, cmd_string = cmd_content})
        else
            cur_project.commands = {cmd_name = cmd_title, cmd_string = cmd_content}
            -- cur_project.commands 
            -- table.insert(cur_project.commands, {cmd_name = cmd_content, cmd_string = cmd_content})
        end
        -- local cmd_content = vim.api.nvim_buf_get_lines(cmd_content_input.bufnr, 0, 1, false)[1]
        -- cmd_title_input = trim

        -- print("Hello world\n")
        -- cmd_title = "build"
        -- cmd_content = "make build"

        tree:add_node(Tree.Node({ text = cmd_title}, { Tree.Node({ text = cmd_content})}))


        tree:render()
        -- cmd_display_popup:render()

        -- local nodes = {}


        -- if project.commands ~= nil then
        --     for _, v in pairs(project.commands) do
        --         nodes:insert(Tree.Node({ text = v.cmd_name}, { Tree.Node({ text = v.cmd_string})})
        --     )
        -- end
    -- end

        -- local tree1 = Tree({
        --     bufnr = popup1.bufnr,
        --     nodes = nodes,
        -- })

        tree:render()

    end)

    input_layout:mount()

    cmd_display_popup:update_layout(layout_opts)

end

---comment
---@param project project
local function create_layout(project)
    ---@type string[]
    cur_project = project

    local popup1_options = {
        -- size = {
        --     -- NOTE: the size field is required for nui to not give an error, but it is completely ignored.
        --     -- NOTE: when setting the `grow` field of the layout that contains this component to 0, the value that I input here actually does something
        --     width = "20%",
        --     height = 2 + #lines
        -- },
        border = {
            text = {
                top =  "Shell Commands:"
            } ,
            style = "double"
        },
        enter = true,
        buf_options = {
            modifiable = false,
        }
    }

    local popup1 = Popup(popup1_options)
    -- local popup2 = popup({ border = "double", })

    local win_width = vim.api.nvim_win_get_width(0)

    local ns = vim.api.nvim_create_namespace("btn-high-ns")
    local high_group = "btn-high-group"

    vim.api.nvim_set_hl(ns, high_group, { reverse = true, bold = true })

    -- project.commands

    local nodes = {}


    if project.commands ~= nil then
        for _, v in pairs(project.commands) do
            nodes:insert(Tree.Node({ text = v.cmd_name}, { Tree.Node({ text = v.cmd_string})})
        )
    end
end

    -- local node1 = Tree.Node({ text = "build"}, { Tree.Node({ text = "make build"})})
    -- local node2 = Tree.Node({ text = "run"}, { Tree.Node({ text = "make run"})})
    -- local node3 = Tree.Node({ text = "debug"}, { Tree.Node({ text = "make debug"})})
    -- local nodes = {
    --     node1,
    --     node2,
    --     node3,
    -- }

    local tree1 = Tree({
        bufnr = popup1.bufnr,
        nodes = nodes,
    })

    tree1:render()

    --[[
    -- TODO:
    -- add a keymapping for a(add cmd), e(edit cmd), v(view cmd, since we will only show a part of the cmd if it is long), d(delete cmd)
    --]]
    popup1:on("CursorMoved", function ()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        nodes = tree1:get_nodes()

        for _, v in ipairs(nodes) do
            v:collapse()
        end

        if cursor_pos[1] <= #nodes then
            nodes[cursor_pos[1]]:expand()
        end

        tree1:render()
        vim.api.nvim_buf_clear_namespace(popup1.bufnr, ns, 0, -1)
        vim.api.nvim_win_set_hl_ns(0, ns)

        vim.hl.range(popup1.bufnr, ns, high_group, { cursor_pos[1] - 1, 0}, { cursor_pos[1] - 1, -1}, { })
    end, { once = false})



    local layout_boxes = {
        -- Layout.Box(popup1, { size = popup1_options.size }),
        -- NOTE: setting the `size` values for the poup here instead of the actual popup component makes the layout `size` field work
        Layout.Box(popup1, { size = { width = "100%", height = 10} }),
        -- layout.Box(input1, input_options),
        -- layout.Blox(popup2, { size = "50%"})
    }


    local layout_comp = Layout(
        {
            position = {
                col = "50%",
                row = 0,
            },
            -- This `size` field is required, but doesn't seem to change anything when I set the sizes of components at creation moment
            size = {
                height = 10, width = "30%"
            },
        },

        -- NOTE: the `grow` field determines if the components inside the layout will grow to fill the available space. If we set grow to 0, then the components will keep their original size
        Layout.Box(layout_boxes, { grow = 0, dir = "col"} )
    )



    popup1:map("n", "a", function ()
        -- local cmd_title = "build"
        -- local cmd_content = "make build"

        -- tree1:add_node(Tree.Node({ text = cmd_title}, { Tree.Node({ text = cmd_content})}))


        -- tree1:render()
        -- cmd_display_popup:render()

        expand_layout_with_prompt(popup1, win_width, tree1)

        --[[


        -- here we want to:
        -- create two inputs
        --      - one containing the command name(map <CR> and <C-l> to switching the cursor to the next input)
        --      - the other one containing the actual shell command
        -- use layout:update() to append the inputs, since it can take any valid nui component as argument
        -- TODO: extract the popup with the command names to a variable and keep it inside every update of the layout. Place the two inputs below this popup. Organize this stuff a little, so it's not a huge mess



        local cur_win_index = 1
        local windows = {vim.api.nvim_get_current_win()}

        local input_options_common = {
                -- border = {
                --     style="rounded",
                --     text = {
                --         top = "Command Title:"
                --     }
                -- },
                position =
                {
                    row = 200,
                    col = 100,
                },

                size =
                {
                    height = "90%",
                    width = "80%",
                }
            }


            local cmd_title_input_opt = input_options_common
            cmd_title_input_opt.border = { style = "rounded", text = { top = "Command Title:"}}
            local cmd_title_input = Input(
                cmd_title_input_opt,
                {
                    prompt = "",
                    default_value = ""
                }
            )


            -- note: this copies the reference to the table. NOT THE VALUE
            local cmd_content_input_opt = input_options_common
            cmd_content_input_opt.border = { style = "rounded", text = { top = "Shell Command to run:"}}

            local cmd_content_input = Input(
                cmd_content_input_opt,
                {
                    prompt = "$ ",
                    default_value = ""
                }
            )

            cmd_title_input:on("WinEnter", function ()
                cur_win_index = 2
                windows[2] = vim.api.nvim_get_current_win()
                print("New win: " .. windows[2] .. '\n')
            end)


            cmd_content_input:on("WinEnter", function ()
                cur_win_index = 3
                windows[3] = vim.api.nvim_get_current_win()
                print("New win: " .. windows[3] .. '\n')
            end)

            cmd_title_input:map("i", "<C-h>", function ()
                cur_win_index = cur_win_index - 1
                vim.api.nvim_set_current_win(windows[cur_win_index])
            end)
            cmd_content_input:map("i", "<C-h>", function ()
                cur_win_index = cur_win_index - 1
                vim.api.nvim_set_current_win(windows[cur_win_index])
            end)

            local layout_opts = {
                position = {
                    col = "5%",
                    row = 0,
                },
                size = {
                    width = "30%",
                    height = 10,
                }
            }

            -- NOTE: each component is its own window, with a different window ID
            -- Layout.Box(popup1, { size = { width = "30%", height = #lines + 2} }),

            local input_layout = Layout({
                size = { height = 10, width = "50%"},
                anchor = "NW",
                position = {
                    -- the percentages are out of width and height of the layout
                    col = 0.5 * win_width,
                    row = 1,
                },
                relative = "editor",
            },

            Layout.Box(
                {


                    Layout.Box(
                        {
                            Layout.Box(
                                -- cmd_title_input, { size = cmd_title_input_opt.size }),
                                cmd_title_input, { size = { height = "50%", width = "100%"} }
                            ),


                            Layout.Box(
                                cmd_content_input, { size = { height = "50%", width = "100%"} })
                            },
                            { dir = "col", size = {width = "80%", height = "100%" } }
                        ),
                    },

                    {
                        dir = "row",
                        size = { height = 10, width = "100%"}
                    }
                )
            )


            input_layout:mount()

            layout_comp:update(
                layout_opts)
                -- layout_opts<
            --     Layout.Box(
            --         {


            --             Layout.Box(
            --                 {
            --                     Layout.Box(
            --                         -- cmd_title_input, { size = cmd_title_input_opt.size }),
            --                         cmd_title_input, { size = { height = "50%", width = "100%"} }
            --                     ),


            --                     Layout.Box(
            --                         cmd_content_input, { size = { height = "50%", width = "100%"} })
            --                     },
            --                     { dir = "col", size = {width = "60%", height = 10 } }
            --                 ),
            --                 },


            --                     dir = "row",
            --                     -- size = { height = 10, width = "100%"}
            --                 }
            --             )
            --         )

            


            --]]
end, {})


    layout_comp:mount()

    -- highlight the currently selected option
    vim.api.nvim_win_set_hl_ns(0, ns)
    vim.hl.range(popup1.bufnr, ns, high_group, { 1, 0}, { 1, -1}, { })

end

return {
    create_layout = create_layout
}
