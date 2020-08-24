------------------
-- @module
-- strings_and_files

local utl_sf = {}

------------------
-- This function checks if a file exists 
-- @function file_exists
-- @param file The path to the file to check
-- @return Boolean, true if file exists
-- @usage file_exists(a_file_path)
local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

------------------
-- Each line in a file will be added to a table, this function returns the table with all lines in a file.
-- @function lines_from
-- @param file The path to the file to read
-- @return Table of strings, a string per line in the file.
-- @usage my_table = lines_from(path_to_file)
function utl_sf.lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
      lines[#lines + 1] = line
    end
    return lines
end

------------------
-- Split a string ("pString") using "pPattern" as splitter. eg: split("hello,world!", ",") -> {"hello" , "world!"}
-- @function split
-- @param pString The string to split.
-- @param pPattern String to specify the pattern where we must split the string.
-- @return Table of strings, as much as the pattern has splitted
-- @usage my_table = split('hello, world!', ',')
-- print(my_table)
-- {"hello","world!"}
function utl_sf.split(pString, pPattern)
    local Table = {}
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
        table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end


return utl_sf