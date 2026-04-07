local M = {}
local U = require("chisel.utils")

-- api ------------------------------------------------------------------------

---@type table<string, fun(str: string): string>
M.cases = {
    cap   = U.cap,
    lower = U.lower,
    upper = U.upper,
}

---@type table<string, string>
M.separators = {
    comma      = ",", -- part,part
    dash       = "-", -- part-part
    dot        = ".", -- part.part
    none       = "",  -- partpart
    slash      = "/", -- part/part
    space      = " ", -- part part
    underscore = "_", -- part_part
}

-- generate a Chisel.Method according to paramns
---@param  case_head string|fun(str:string): string ; str must be in `M.cases`
---@param  case_tail nil|string|fun(str:string): string ; if nil use `case_head`
---@param  separator string ; if not in `M.separators`, use the string as one
---@return Chisel.Method
M.generic = function(case_head, case_tail, separator)
    local sep = M.separators[separator]
    if sep == nil then sep = separator end

    local ch, ct = nil, nil
    if type(case_head) == "string" then
        ch = M.cases[case_head]
        if ch == nil then
            vim.api.nvim_err_writeln("Unknown case: " .. case_head)
        end
    elseif type(case_head) == "function" then
        ch = case_head
    end

    if not ch then
        error(string.format(
            "Invalid type for `case_head`, expected string or function, got %s (%s)",
            type(case_head), tostring(case_head)))
    end

    if case_tail == nil then
        ct = ch
    elseif type(case_tail) == "string" then
        ct = M.cases[case_tail]
        if ct == nil then
            vim.api.nvim_err_writeln("Unknown case: " .. case_tail)
        end
    elseif type(case_tail) == "function" then
        ct = case_tail
    end

    if not ct then
        error(string.format(
            "Invalid type for `case_tail`, expected nil, string or function, got %s (%s)",
            type(case_tail), tostring(case_tail)))
    end

    return function(str)
        local p = U.parts(str)
        if #p == 0 then return "" end
        local out = { ch(p[1]) }
        for i = 2, #p do out[i] = ct(p[i]) end
        return table.concat(out, sep)
    end
end

---@return table<string, Chisel.Method>
M.built_in = function()
    return {
        ["title"] = function(str)
            local p = U.parts(str)
            for i = 1, #p do p[i] = U.cap(p[i]) end
            return table.concat(p, "_")
        end,
        ["phrase"] = function(str)
            local p = U.parts(str)
            if #p == 0 then return "" end
            p[1] = U.cap(p[1])
            for i = 2, #p do p[i] = U.lower(p[i]) end
            return table.concat(p, " ")
        end,
        ["comma"] = function(str)
            local p = U.parts(str)
            return table.concat(p, ",")
        end,
        ["camel"] = function(str)
            local p = U.parts(str)
            if #p == 0 then return "" end
            local out = { U.lower(p[1]) } -- first stays lowercase
            for i = 2, #p do out[i] = U.cap(p[i]) end
            return table.concat(out, "")
        end,
        ["pascal"] = function(str)
            local p = U.parts(str)
            for i = 1, #p do p[i] = U.cap(p[i]) end
            return table.concat(p, "")
        end,
        ["snake"] = function(str)
            local p = U.parts(str)
            return U.lower(table.concat(p, "_"))
        end,
        ["upper"] = function(str)
            local p = U.parts(str)
            return U.upper(table.concat(p, "_"))
        end,
        ["kebab"] = function(str)
            local p = U.parts(str)
            return U.lower(table.concat(p, "-"))
        end,
        ["Train-Case"] = function(str)
            local p = U.parts(str)
            for i = 1, #p do p[i] = U.cap(p[i]) end
            return table.concat(p, "-")
        end,
        ["dot"] = function(str)
            local p = U.parts(str)
            return table.concat(p, ".")
        end,
        ["path"] = function(str)
            local p = U.parts(str)
            return table.concat(p, "/")
        end,
        ["space"] = function(str)
            local p = U.parts(str)
            return table.concat(p, " ")
        end,
        ["n12e"] = function(str)
            local len = U.utf8len(str)
            if len <= 2 then return str end
            return U.utf8sub(str, 1, 1) .. (len - 2) .. U.utf8sub(str, len, len)
        end,
    }
end

-------------------------------------------------------------------------------

return M
