local M = {}
local U = require("chisel.utils")

-- api ------------------------------------------------------------------------

-- example: "fooBar_foo We-Boo" -> {"foo", "bar", "foo", "we", "boo"}
---@param  str string
---@return string[]
M.parts = function(str)
    local tokens = {}

    -- split on basic separators
    for piece in str:gmatch("[^_%-%./]+") do -- Note: we join separators
        local start = 1
        local len = U.utf8len(piece)

        for i = 2, len do -- camelCase + PascalCase like boundaries
            local prev = U.utf8sub(piece, i - 1, i - 1)
            local curr = U.utf8sub(piece, i, i)

            if U.is_boundary(prev, curr) then
                table.insert(tokens, U.lower(U.utf8sub(piece, start, i - 1)))
                start = i
            end
        end

        table.insert(tokens, U.lower(U.utf8sub(piece, start)))
    end

    return tokens
end

-- methods --------------------------------------------------------------------

---@type Chisel.Method
local to_camel = function(str)
    local p = M.parts(str)
    if #p == 0 then return "" end
    local out = { p[1] } -- first stays lowercase
    for i = 2, #p do out[i] = U.cap(p[i]) end
    return table.concat(out, "")
end

---@type Chisel.Method
local to_pascal = function(str)
    local p = M.parts(str)
    for i = 1, #p do p[i] = U.cap(p[i]) end
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
    return U.upper(table.concat(p, "_"))
end

---@type Chisel.Method
local to_kebab = function(str)
    local p = M.parts(str)
    return U.lower(table.concat(p, "-"))
end

---@type Chisel.Method
local to_dot = function(str)
    local p = M.parts(str)
    return U.lower(table.concat(p, "."))
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
    local len = M.utf8len(str)
    if len <= 2 then return str end
    return U.utf8sub(str, 1, 1) .. (len - 2) .. U.utf8sub(str, len, len)
end

-- TODO:
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
