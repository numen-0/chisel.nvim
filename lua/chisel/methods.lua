local M = {}
local utils = require("chisel.utils")

-- api ------------------------------------------------------------------------

-- example: "fooBar_foo We-Boo" -> {"foo", "bar", "foo", "we", "boo"}
---@param  str string
---@return string[]
M.parts = function(str)
    local tokens = {}

    -- split on basic separators
    for piece in str:gmatch("[^_%-%./]+") do -- Note: we join separators
        local start = 1
        local len = #piece

        for i = 2, len do -- camelCase + PascalCase like boundaries
            local prev = piece:sub(i - 1, i - 1)
            local curr = piece:sub(i, i)

            if utils.is_boundary(prev, curr) then
                table.insert(tokens, piece:sub(start, i - 1):lower())
                start = i
            end
        end

        table.insert(tokens, piece:sub(start):lower())
    end

    return tokens
end

-- methods --------------------------------------------------------------------

---@type Chisel.Method
local to_camel = function(str)
    local p = M.parts(str)
    if #p == 0 then return "" end
    local out = { p[1] } -- first stays lowercase
    for i = 2, #p do out[i] = utils.cap(p[i]) end
    return table.concat(out, "")
end

---@type Chisel.Method
local to_pascal = function(str)
    local p = M.parts(str)
    for i = 1, #p do p[i] = utils.cap(p[i]) end
    return table.concat(p, "")
end

---@type Chisel.Method
local to_snake = function(str)
    local p = M.parts(str)
    return table.concat(p, "_")
end

---@type Chisel.Method
local to_upper = function(str)
    local p = M.parts(str)
    return table.concat(p, "_"):upper()
end

---@type Chisel.Method
local to_kebab = function(str)
    local p = M.parts(str)
    return table.concat(p, "-"):lower()
end

---@type Chisel.Method
local to_dot = function(str)
    local p = M.parts(str)
    return table.concat(p, "."):lower()
end

---@type Chisel.Method
local to_path = function(str)
    local p = M.parts(str)
    return table.concat(p, "/")
end

---@type Chisel.Method
local to_space = function(str)
    local p = M.parts(str)
    return table.concat(p, " ")
end

---@type Chisel.Method
local to_n12e = function(str)
    if #str <= 2 then return str end
    return str:sub(1, 1) .. (#str - 2) .. str:sub(#str, #str)
end

-- TODO:
-- use vim.fn.toupper and vim.fn.tolower to also up non ascii chars
-- Title_Case
-- Phrase_case
-- comma,case
-- add some variants for
--      - Title-Case  | Title Case
--      - Phrase-case | Phrase case
-- also some should preserve the Case like:
--      - path/Case


-- setup ----------------------------------------------------------------------

---@type table<string, Chisel.Method>
M.built_in = {
    ["camel"]  = to_camel,
    ["pascal"] = to_pascal,
    ["snake"]  = to_snake,
    ["upper"]  = to_upper,
    ["kebab"]  = to_kebab,
    ["dot"]    = to_dot,
    ["path"]   = to_path,
    ["space"]  = to_space,
    ["n12e"]   = to_n12e,
}

return M
