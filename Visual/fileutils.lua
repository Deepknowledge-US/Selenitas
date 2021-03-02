------------------
-- Class for file handling functions
-- @module
-- fileutils

local fileutils = {}

------------------
-- Checks whether the specified file or directory exists
-- @function exists
-- @param path Path of the file or directory to check
-- @return status Whether the file or directory exists
function fileutils.exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

------------------
-- Copies file.
-- @function copy
-- @param srcpath Path of the file to be copied.
-- @param dstpath Path of the copy destination.
function fileutils.copy(srcpath, dstpath)
    local infile = io.open(srcpath, "r")
    local content = infile:read("*a")
    infile:close()
    local outfile = io.open(dstpath, "w")
    outfile:write(content)
    outfile:close()
end


------------------
-- Copies file to Love2D save directory.
-- @function copy
-- @param src Path of the file to be copied. Must be accesible by Love2D, meaning it must be a child of project's root directory.
-- @param dst Path of the copy destination, relative to the save directory.
-- @return err error in copy if any.
function fileutils.copy_to_save_dir(src, dst)
    local info = love.filesystem.getInfo(src)
    local contents, size = love.filesystem.read(src, info.size)
    local _, err = love.filesystem.write(dst, contents, size)
    return err
end

------------------
-- Opens file in system's default text editor
-- @function open_in_editor
-- @param path path of the file to be opened in external editor
function fileutils.open_in_editor(path)
    local os_str = love.system.getOS()
    if os_str == "Windows" then
        os.execute("start " .. path)
    elseif os_str == "Linux" then
        os.execute("xdg-open " .. path)
    elseif os_str == "OS X" then
        os.execute("open " .. path)
    end
end

------------------
-- Gets the filename of an specified path: path/to/my/file.lua -> file.lua
-- @function open_in_editor
-- @param path path to get filename from
function fileutils.get_filename_from_path(path)
    local split = {}
    local sep = "/"
    for str in string.gmatch(path, "([^"..sep.."]+)") do
        table.insert(split, str)
    end
    return split[#split] -- last item is filename
end

------------------
-- Loads model file
-- @function load_model_file
-- @param file_path model file to load
-- @return err error if an error happened when loading the file
function fileutils.load_model_file(file_path)
    local file, err = loadfile(file_path)
    if file then
        file()
    end
    return err
end

return fileutils