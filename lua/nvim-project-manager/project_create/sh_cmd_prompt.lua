local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Input = require("nui.input")
local Tree = require("nui.tree")


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

local function create_layout()
    ---@type string[]

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

    local node1 = Tree.Node({ text = "build"}, { Tree.Node({ text = "make build"})})
    local node2 = Tree.Node({ text = "run"}, { Tree.Node({ text = "make run"})})
    local node3 = Tree.Node({ text = "debug"}, { Tree.Node({ text = "make debug"})})
    local nodes = {
        node1,
        node2,
        node3,
    }

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
        Layout.Box(popup1, { size = { width = "80%", height = 10} }),
        -- layout.Box(input1, input_options),
        -- layout.Blox(popup2, { size = "50%"})
    }


    local layout_comp = Layout(
        {
            position = {
                -- col = (win_width - popup1_options.size.width)/2,
                col = "50%",
                row = 0,
            },
            -- This `size` field is required, but doesn't seem to change anything when I set the sizes of components at creation moment
            size = 40,
        },

        -- NOTE: the `grow` field determines if the components inside the layout will grow to fill the available space. If we set grow to 0, then the components will keep their original size
        Layout.Box(layout_boxes, { size = "100%", dir = "col"} )
    )



    popup1:map("n", "a", function ()
        -- here we want to:
        -- create two inputs
        --      - one containing the command name(map <CR> and <C-l> to switching the cursor to the next input)
        --      - the other one containing the actual shell command
        -- use layout:update() to append the inputs, since it can take any valid nui component as argument
        -- TODO: extract the popup with the command names to a variable and keep it inside every update of the layout. Place the two inputs below this popup. Organize this stuff a little, so it's not a huge mess

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

            local layout_opts = {
                position = {
                    col = 0,
                    row = 0,
                },
                size = {
                    width = win_width,
                    height = 100,
                }
            }

            -- NOTE: each component is its own window, with a different window ID

            layout_comp:update(
                layout_opts,
                Layout.Box(
                    {
                        Layout.Box(popup1, { size = { width = "30%", height = #lines + 2} }),


                        Layout.Box(
                            {
                                Layout.Box(
                                    -- cmd_title_input, { size = cmd_title_input_opt.size }),
                                    cmd_title_input, { size = { height = "50%", width = "100%"} }
                                ),


                                Layout.Box(
                                    cmd_content_input, { size = { height = "50%", width = "100%"} })
                                },
                                { dir = "col", size = {width = "60%", height = 10 } }
                            ),
                            },

                            {
                                dir = "row",
                                -- size = { height = 10, width = "100%"}
                            }
                        )
                    )

end, {})


    layout_comp:mount()

    -- highlight the currently selected option
    vim.api.nvim_win_set_hl_ns(0, ns)
    vim.hl.range(popup1.bufnr, ns, high_group, { 1, 0}, { 1, -1}, { })

end

return {
    create_layout = create_layout
}
