local popup = require("nui.popup")
local layout = require("nui.layout")

local popup1 = popup({
    enter = true,
    -- border = "double",
    border = {
        style = "rounded",
        text = {
            top = "Project title"
        },
        enter = true,
        focusable = false,
    },
    buf_options = {
        modifiable = true,
    }
})

local layout1 = layout(
    {
        position = "50%",
        size = {
            width = 20,
            height = 3
        },
    },
    layout.Box({
        layout.Box(popup1, { size = 50})
    })
)


layout1:mount()

local prompt_bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set({"n", "i", "v"}, "<CR>", function ()
    -- vim.api.nvim_buf_delete(prompt_bufnr, { force = true})
    -- save the entered value, then create a new tab for it(but don't show it)
    -- also change the title
end, { buffer = prompt_bufnr})
