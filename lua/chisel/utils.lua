local M = {}

-- string ---------------------------------------------------------------------

M.upper = vim.fn.toupper
M.lower = vim.fn.tolower

---@param str string
---@return string: head first character
---@return string: tail rest of characters
M.chop_head = function(str)
    local head = M.utf8sub(str, 1, 1)
    local tail  = M.utf8sub(str, 2)
    return head, tail
end

-- capitalize
---@param  str string
---@return string
M.cap = function(str)
    local head, tail = M.chop_head(str)
    return M.upper(head) .. M.lower(tail)
end

---@param  text string
---@return boolean
M.is_identifier = function(text)
    return text:match("^[%w%._%-%/]+$") ~= nil
end

-- detect token boundaries
---@param  prev string: previous char
---@param  curr string: current char
---@return boolean
M.is_boundary = function(prev, curr)
    return (prev:match("%l") and curr:match("%u"))   -- fooBar
        or (prev:match("%a") and curr:match("%d"))   -- bar42
        or (prev:match("%d") and curr:match("%a"))   -- 42Test
end

---@param  text string
---@return { word: string, sep: string }[]
M.split_preserve = function(text)
    local result = {}

    for part, sep in text:gmatch("([%w%._%-%/]+)([^%w%._%-%/]*)") do
        table.insert(result, { word = part, sep = sep })
    end

    return result
end

---@param  str string
---@return boolean
M.is_ascii = function(str)
    return not str:find("[\128-\255]")
end

-- from: https://github.com/blitmap/lua-utf8-simple/tree/master
---@param  str string
---@return integer
M.utf8len = function(str)
	return select(2, str:gsub('[^\128-\193]', ''))
end

---@param  str   string
---@param  width integer
---@return string
M.pad_utf8 = function(str, width)
    local len = M.utf8len(str)
    if len < width then
        return str .. string.rep(" ", width - len)
    else
        return str
    end
end

---@param  str string
---@param  i   integer|nil: from character (1-based index), if nil set to 1
---@param  j   integer|nil: to character (inclusive), if nil set to -1
---@return string
M.utf8sub = function(str, i, j)
    i = i or 1
    j = j or -1

    local chars = {}
    for uchar in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end

    if j < 0 then j = #chars + j + 1 end

    i = math.max(i, 1)
    j = math.min(j, #chars)

    local out = {}
    for k = i, j do table.insert(out, chars[k]) end

    return table.concat(out)
end

-- split string into parts conserving case
-- example: "fooBar_foo We-Boo" -> {"foo", "Bar", "foo", "We", "Boo"}
---@param  str string
---@return string[]
M.parts = function(str)
    local tokens = {}

    -- split on basic separators
    for piece in str:gmatch("[^_%-%./ ]+") do -- Note: we join adjacent gliphs
        local start = 1
        local len = M.utf8len(piece)

        for i = 2, len do -- camelCase + PascalCase like boundaries
            local prev = M.utf8sub(piece, i - 1, i - 1)
            local curr = M.utf8sub(piece, i, i)

            if M.is_boundary(prev, curr) then
                table.insert(tokens, M.utf8sub(piece, start, i - 1))
                start = i
            end
        end

        table.insert(tokens, M.utf8sub(piece, start))
    end

    return tokens
end

-- table ----------------------------------------------------------------------

---@param  t table<string, any[]>
---@return any[]
M.flatten = function(t)
    local flat = {}
    for _, list in pairs(t) do
        for _, item in ipairs(list) do
            table.insert(flat, item)
        end
    end
    return flat
end

---@param  t table
---@return table
M.clone = function(t)
    return vim.tbl_extend("force", {}, t)
end

-------------------------------------------------------------------------------

return M
