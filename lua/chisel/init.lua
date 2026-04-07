-------------------------------------------------------------------------------
-- chisel.nvim ----------------------------------------------------------------

-- types ----------------------------------------------------------------------

---@class Chisel.Config
---@field methods table<string, Chisel.Method>

---@alias Chisel.Method fun(str: string): string

-- modules --------------------------------------------------------------------

local M = {}
local U = require("chisel.utils")

-- state ----------------------------------------------------------------------

---@type Chisel.Config
M.config = {
    methods = require("chisel.methods").built_in(),
}

-- api ------------------------------------------------------------------------

---@param func Chisel.Method
---@param name string
M.register = function(name, func)
    M.config.methods[name] = func
end

---@param method string|Chisel.Method
---@param str string
---@return string
M.apply = function(method, str)
    local fn = nil
    if type(method) == "string" then
        fn = M.config.methods[method]
    elseif type(method) == "function" then
        fn = method
    else
        error(string.format(
            "Invalid type for `method`, expected string or function, got %s (%s)",
            type(method), tostring(method)))
    end

    if fn == nil then
        vim.notify(string.format("Chisel: unknown method '%s'", method),
            vim.log.levels.ERROR)
        return str
    end

    return fn(str)
end

---@param method string|Chisel.Method
M.current_word = function(method)
    local word = vim.fn.expand("<cword>")
    local new = M.apply(method, word)

    vim.cmd("normal! ciw" .. new)
end

---@param method string|Chisel.Method
M.visual = function(method)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local srow, scol = start_pos[2] - 1, start_pos[3] - 1
    local erow, ecol = end_pos[2] - 1, end_pos[3]

    local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ""
    if ecol > #line then ecol = #line end

    local lines = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
    local text = table.concat(lines, "\n")

    local new = ""

    if U.is_identifier(text) then
        new = M.apply(method, text)
    else
        local parts = U.split_preserve(text)

        for _, p in ipairs(parts) do
            p.word = M.apply(method, p.word)
        end

        local out = {}
        for _, p in ipairs(parts) do
            table.insert(out, p.word .. p.sep)
        end

        new = table.concat(out)
    end

    vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, vim.split(new, "\n"))
end

-- setup ----------------------------------------------------------------------

---@param opts Chisel.Config?
M.setup = function(opts)
    opts = opts or {}

    for k, v in pairs(opts) do
        if type(v) ~= "table" then
            M.config[k] = v
        else
            M.config[k] = vim.tbl_extend("force", M.config[k], v)
        end
    end
end

-------------------------------------------------------------------------------

return M
