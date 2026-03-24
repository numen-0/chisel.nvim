local M = {}

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
---@param  s string
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
---@return string[]
M.split_preserve = function(text)
    local result = {}

    for part, sep in text:gmatch("([%w%._%-%/]+)([^%w%._%-%/]*)") do
        table.insert(result, { word = part, sep = sep })
    end

    return result
end

---@param t table
---@param cb fun(key:string, value:any)
M.foreach = function(t, cb)
    for key, value in pairs(t) do
        cb(key, value)
    end
end

---@param  str string
---@return boolean
M.is_ascii = function(str)
    return not str:find("[\128-\255]")
end

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

return M
