local M = {}
local U = require("chisel.utils")

-- api ------------------------------------------------------------------------

---@type table<string, Chisel.Method>
M.built_in = {}

-- sugar ----------------------------------------------------------------------

-- register method into M.built_in
---@param  name string
---@param  func Chisel.Method
---@return Chisel.Method: func
local register = function(name, func)
    M.built_in[name] = func
    return func
end

-- methods --------------------------------------------------------------------

---@type Chisel.Method
local to_title = register("title", function(str)
    local p = U.parts(str)
    for i = 1, #p do p[i] = U.cap(p[i]) end
    return table.concat(p, "_")
end)

---@type Chisel.Method
local to_phrase = register("phrase", function(str)
    local p = U.parts(str)
    if #p == 0 then return "" end
    p[1] = U.cap(p[1])
    for i = 2, #p do p[i] = U.lower(p[i]) end
    return table.concat(p, " ")
end)

---@type Chisel.Method
local to_comma = register("comma", function(str)
    local p = U.parts(str)
    return table.concat(p, ",")
end)

---@type Chisel.Method
local to_camel = register("camel", function(str)
    local p = U.parts(str)
    if #p == 0 then return "" end
    local out = { U.lower(p[1]) } -- first stays lowercase
    for i = 2, #p do table.insert(out, U.cap(p[i])) end
    return table.concat(out, "")
end)

---@type Chisel.Method
local to_pascal = register("pascal", function(str)
    local p = U.parts(str)
    for i = 1, #p do p[i] = U.cap(p[i]) end
    return table.concat(p, "")
end)

---@type Chisel.Method
local to_snake = register("snake", function(str)
    local p = U.parts(str)
    return U.lower(table.concat(p, "_"))
end)

---@type Chisel.Method
local to_upper = register("upper", function(str)
    local p = U.parts(str)
    return U.upper(table.concat(p, "_"))
end)

---@type Chisel.Method
local to_kebab = register("kebab", function(str)
    local p = U.parts(str)
    return U.lower(table.concat(p, "-"))
end)

---@type Chisel.Method
local to_dot = register("dot", function(str)
    local p = U.parts(str)
    return table.concat(p, ".")
end)

---@type Chisel.Method
local to_path = register("path", function(str)
    local p = U.parts(str)
    return table.concat(p, "/")
end)

---@type Chisel.Method
local to_space = register("space", function(str)
    local p = U.parts(str)
    return table.concat(p, " ")
end)

---@type Chisel.Method
local to_n12e = register("n12e", function(str)
    local len = U.utf8len(str)
    if len <= 2 then return str end
    return U.utf8sub(str, 1, 1) .. (len - 2) .. U.utf8sub(str, len, len)
end)

-------------------------------------------------------------------------------

return M
