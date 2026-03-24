local chisel = require("chisel")

vim.api.nvim_create_user_command(
    "Chisel",
    function(opts)
        local mode = vim.api.nvim_get_mode().mode

        if opts.range > 0 then
            chisel.visual(opts.args)
        else
            chisel.current_word(opts.args)
        end
    end, {
        nargs = 1,
        range = true,
        complete = function()
            return vim.tbl_keys(chisel.config.methods)
        end,
        desc = "Chisel the current word or selection",
    }
)
